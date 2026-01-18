import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' hide Uint8List;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';

import '../providers/Datafeed.dart';

class ItemRegPage extends StatefulWidget {
  final String? docId;
  final Map<String, dynamic>? data;

  const ItemRegPage({Key? key, this.docId, this.data}) : super(key: key);

  @override
  State<ItemRegPage> createState() => _ItemRegPageState();
}

class _ItemRegPageState extends State<ItemRegPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _costController = TextEditingController();
  int pricingStep = 0;
  bool _enableBoxPricing = false;
  bool _showBoxPricingSwitch = false;
  final _boxQtyController = TextEditingController();
  final _halfboxqty_controller = TextEditingController();
  final _quarterqty_controller = TextEditingController();
  final _retail_price = TextEditingController();
  final _packQtyController = TextEditingController();

  final _supplierPriceController = TextEditingController();
  final _wholesalePriceController = TextEditingController();
  final _halfboxprice_controller = TextEditingController();
  final _quarterprice_controller = TextEditingController();
  final _packprice_controller = TextEditingController();
  final _cartonQtyController = TextEditingController();
  final _cartonSupplierController = TextEditingController();
  final _quarterRetailController = TextEditingController();
  final _quarterWholesaleController = TextEditingController();
  final _quarterSupplierController = TextEditingController();

// Pack

  final _wholesaleMinQtyController = TextEditingController();
  final _supplierMinQtyController = TextEditingController();
  Map<String, TextEditingController> stockingControllers = {};
  String? _productType;
  String? _pricingMode;
  String? _productCategory;

  bool _loading = false;
  Uint8List? _logoBytes;
  File? _logoFile;
  String? _existingLogoUrl;

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<Datafeed>().fetchproductcategory();
    });

    if (widget.data != null) {
      final d = widget.data!;
      _existingLogoUrl = d['imageurl'];
      _nameController.text = d['name'] ?? '';
      _barcodeController.text = d['barcode'] ?? '';
      _costController.text = d['costprice'] ?? '';
      _productType = d['producttype'];
      _productCategory = d['productcategory'];

    }
  }
  Future<void> pickLogo() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (picked == null) return;

    if (kIsWeb) {
      _logoBytes = await picked.readAsBytes();
      _logoFile = null;
    } else {
      _logoFile = File(picked.path);
      _logoBytes = null;
    }

    setState(() {});
  }

  Future<String?> uploadLogo(String itemId) async {
    if (_logoFile == null && _logoBytes == null) {
      return _existingLogoUrl; // unchanged
    }

    final ref = FirebaseStorage.instance
        .ref()
        .child('items')
        .child('$itemId.png');

    UploadTask task;

    if (kIsWeb) {
      task = ref.putData(
        _logoBytes!,
        SettableMetadata(contentType: 'image/png'),
      );
    } else {
      task = ref.putFile(
        _logoFile!,
        SettableMetadata(contentType: 'image/png'),
      );
    }

    final snap = await task;
    return snap.ref.getDownloadURL();
  }

  Future<Map<String, String?>> generateAndUploadBarcodeCodes(String barcode, String itemId) async {
    try {
      final barcodeController = ScreenshotController();
      final qrController = ScreenshotController();

      // Generate barcode image
      final barcodeImage = await barcodeController.captureFromWidget(
        BarcodeWidget(
          data: barcode,
          barcode: Barcode.code128(),
          width: 200,
          height: 80,
          drawText: true,
          style: const TextStyle(fontSize: 12),
        ),
        delay: const Duration(milliseconds: 100),
      );

      // Generate QR code image
      final qrImage = await qrController.captureFromWidget(
        QrImageView(
          data: barcode,
          version: QrVersions.auto,
          size: 200.0,
        ),
        delay: const Duration(milliseconds: 100),
      );

      // Upload barcode image
      final barcodeRef = FirebaseStorage.instance
          .ref()
          .child('items')
          .child('barcodes')
          .child('${itemId}_barcode.png');

      await barcodeRef.putData(
        barcodeImage,
        SettableMetadata(contentType: 'image/png'),
      );
      final barcodeUrl = await barcodeRef.getDownloadURL();

      // Upload QR code image
      final qrRef = FirebaseStorage.instance
          .ref()
          .child('items')
          .child('qrcodes')
          .child('${itemId}_qr.png');

      await qrRef.putData(
        qrImage,
        SettableMetadata(contentType: 'image/png'),
      );
      final qrUrl = await qrRef.getDownloadURL();

      return {
        'barcodeUrl': barcodeUrl,
        'qrUrl': qrUrl,
      };
    } catch (e) {
      debugPrint('Error generating barcode/QR codes: $e');
      return {
        'barcodeUrl': null,
        'qrUrl': null,
      };
    }
  }


  // Future<void> saveItem() async {
  //   if (!_formKey.currentState!.validate()) return;
  //
  //   setState(() => _loading = true);
  //
  //   try {
  //     final docRef = widget.docId == null
  //         ? _db.collection('items').doc()
  //         : _db.collection('items').doc(widget.docId);
  //
  //     final imageUrl = await uploadLogo(docRef.id);
  //     if (_enableBoxPricing) {
  //       final wMin = int.tryParse(_wholesaleMinQtyController.text) ?? 0;
  //       final sMin = int.tryParse(_supplierMinQtyController.text) ?? 0;
  //
  //       if (wMin >= sMin) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(content: Text("Wholesale min qty must be less than supplier min qty")),
  //         );
  //         setState(() => _loading = false);
  //         return;
  //       }
  //     }
  //
  //     final data = {
  //       'name': _nameController.text.trim(),
  //       'barcode': _barcodeController.text.trim(),
  //       'costprice': _costController.text.trim(),
  //       'producttype': _productType,
  //       'pricingmode': _pricingMode,
  //       'productcategory': _productCategory,
  //       'imageurl': imageUrl,
  //       'updatedAt': FieldValue.serverTimestamp(),
  //       'boxPricingEnabled': _enableBoxPricing,
  //       'boxQty': _boxQtyController.text,
  //       'retailBoxPrice': _retail_price.text,
  //       'wholesaleBoxPrice': _wholesalePriceController.text,
  //       'supplierBoxPrice': _supplierPriceController.text,
  //       'wholesaleMinQty': _wholesaleMinQtyController.text,
  //       'supplierMinQty': _supplierMinQtyController.text,
  //     };
  //
  //     if (widget.docId == null) {
  //       data['createdAt'] = FieldValue.serverTimestamp();
  //       await docRef.set(data);
  //     } else {
  //       await docRef.update(data);
  //     }
  //
  //     if (mounted) Navigator.pop(context, true);
  //   } catch (e) {
  //     ScaffoldMessenger.of(context)
  //         .showSnackBar(SnackBar(content: Text('Error: $e')));
  //   }
  //
  //   setState(() => _loading = false);
  // }


  @override
  Widget build(BuildContext context) {
    return Consumer<Datafeed>(builder: (context, datafeed, child) {
      final companyType = datafeed.companytype;

      return Scaffold(
        backgroundColor: const Color(0xFF101624),
        appBar: AppBar(title: Text(widget.docId == null ? 'Register Item' : 'Edit Item')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _imagePickerSection(),
                    const SizedBox(height: 10),
                    _buildField(_nameController, 'Item Name', Icons.label),
                    const SizedBox(height: 10),
                    _buildField(_barcodeController, 'Barcode', Icons.qr_code),

                    SizedBox(height: 10,),
                    _buildField(_retail_price, 'Retail Price', Icons.attach_money, isNumber: true,
                      onChanged: (value) {
                        // When box qty is 1, sync all prices to retail price
                        final boxQty = double.tryParse(_boxQtyController.text) ?? 0;
                        if (_enableBoxPricing && boxQty == 1) {
                          setState(() {
                            _wholesalePriceController.text = value;
                            _supplierPriceController.text = value;
                          });
                        }
                      },
                    ),
                    SizedBox(height: 10,),
                    const SizedBox(height: 10),
                    _buildField(_boxQtyController, 'Box quantity', Icons.attach_money, isNumber: true,
                      onChanged: (value) {
                        final qty = double.tryParse(value) ?? 0;
                        if (qty > 1) {
                          setState(() {
                            _showBoxPricingSwitch = true;
                            _enableBoxPricing = true;

                            // auto calculate quantities
                            _halfboxqty_controller.text = (qty / 2).ceil().toString();
                            _quarterqty_controller.text = (qty / 4).ceil().toString();
                          });
                        } else if (qty == 1) {
                          // When box qty is 1, sync all prices
                          setState(() {
                            _showBoxPricingSwitch = true;
                            _enableBoxPricing = true;
                            
                            // Sync prices: retail = wholesale = supplier
                            final retailPrice = _retail_price.text;
                            _wholesalePriceController.text = retailPrice;
                            _supplierPriceController.text = retailPrice;
                          });
                        } else {
                          setState(() {
                            _showBoxPricingSwitch = false;
                            _enableBoxPricing = false;
                            pricingStep = 0;
                          });
                        }
                      },
                    ),
                    SizedBox(height: 10,),
                    Row(
                      children: [
                        Expanded(
                          child: _buildField(
                            // onChanged: (val){
                            //   final qty = double.tryParse(val) ?? 0;
                            //   _halfboxprice_controller.text = (qty / 2).toStringAsFixed(2);
                            //   _quarterprice_controller.text = (qty / 4).toStringAsFixed(2);
                            //
                            // },
                            onChanged: (val) {
                              final price = double.tryParse(val) ?? 0;

                              _halfboxprice_controller.text = (price / 2).toStringAsFixed(2);
                              _quarterprice_controller.text = (price / 4).toStringAsFixed(2);
                            },
                            _wholesalePriceController,
                            'Box Price',
                            Icons.attach_money,
                            isNumber: true,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildField(
                            _supplierPriceController,
                            'Supplier Price',
                            Icons.attach_money,
                            isNumber: true,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: _buildField(
                            _wholesaleMinQtyController,
                            'Wholesale Min Qty',
                            onChanged: (value) {
                              _formKey.currentState?.validate();
                            },
                            validator: (v) {
                              // If wholesale is empty, always pass
                              if (v == null || v.isEmpty) return null;

                              final wholesaleQty = int.tryParse(v) ?? 0;
                              final supplierText = _supplierMinQtyController.text.trim();
                              
                              // If supplier is empty, always pass
                              if (supplierText.isEmpty) return null;
                              
                              final supplierQty = int.tryParse(supplierText) ?? 0;

                              // Skip validation when either is 1
                              if (wholesaleQty == 1 || supplierQty == 1) return null;

                              if (wholesaleQty > supplierQty) {
                                return 'Cannot exceed Supplier Min Qty';
                              }

                              return null;
                            },
                            Icons.numbers,
                            isNumber: true,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildField(
                            _supplierMinQtyController,
                            'Supplier Min Qty',
                            Icons.numbers,
                            isNumber: true,
                            onChanged: (value) {
                              _formKey.currentState?.validate();
                            },
                            validator: (v) {
                              // If supplier is empty, always pass
                              if (v == null || v.isEmpty) return null;

                              final supplierQty = int.tryParse(v) ?? 0;
                              final wholesaleText = _wholesaleMinQtyController.text.trim();
                              
                              // If wholesale is empty, always pass
                              if (wholesaleText.isEmpty) return null;
                              
                              final wholesaleQty = int.tryParse(wholesaleText) ?? 0;

                              // Skip validation when either is 1
                              if (supplierQty == 1 || wholesaleQty == 1) return null;

                              if (supplierQty <= wholesaleQty) {
                                return 'Must be greater than Wholesale Min Qty';
                              }

                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    // if (_showBoxPricingSwitch)
                    //   Switch(
                    //     value: _enableBoxPricing,
                    //     activeColor: Colors.green,
                    //     onChanged: (v) {
                    //       setState(() => _enableBoxPricing = v);
                    //     },
                    //   ),

                    if (_enableBoxPricing) ...[
                      const SizedBox(height: 15),

                      /// HALF ROW
                      if (pricingStep >= 1)
                        Row(
                          children: [
                            Expanded(
                              child: _buildField(
                                _halfboxqty_controller,
                                'Half Box Qty',
                                Icons.inventory,
                                isNumber: true,
                                validator: (v) {
                                  if (v == null || v.isEmpty) return 'Required';
                                  
                                  final halfQty = int.tryParse(v) ?? 0;
                                  final boxQty = int.tryParse(_boxQtyController.text) ?? 0;
                                  
                                  if (boxQty > 0 && halfQty > boxQty) {
                                    return 'Half Qty cannot exceed Box Qty';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildField(
                                _halfboxprice_controller,
                                'Half Box Price',
                                Icons.attach_money,
                                isNumber: true,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.remove_circle, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  pricingStep = 0;
                                  _halfboxqty_controller.clear();
                                  _halfboxprice_controller.clear();
                                  _quarterqty_controller.clear();
                                  _quarterprice_controller.clear();
                                  _packQtyController.clear();
                                  _packprice_controller.clear();
                                });
                              },
                            ),
                          ],
                        ),

                      if (pricingStep >= 1) const SizedBox(height: 15),

                      /// QUARTER ROW
                      if (pricingStep >= 2)
                        Row(
                          children: [
                            Expanded(
                              child: _buildField(
                                _quarterqty_controller,
                                'Quarter Qty',
                                Icons.inventory,
                                isNumber: true,
                                validator: (v) {
                                  if (v == null || v.isEmpty) return 'Required';
                                  
                                  final quarterQty = int.tryParse(v) ?? 0;
                                  final boxQty = int.tryParse(_boxQtyController.text) ?? 0;
                                  final halfQty = int.tryParse(_halfboxqty_controller.text) ?? 0;
                                  final packQty = int.tryParse(_packQtyController.text) ?? 0;
                                  
                                  if (boxQty > 0 && quarterQty > boxQty) {
                                    return 'Quarter Qty cannot exceed Box Qty';
                                  }
                                  
                                  if (halfQty > 0 && quarterQty >= halfQty) {
                                    return 'Quarter Qty must be less than Half Qty';
                                  }
                                  
                                  if (packQty > 0 && quarterQty <= packQty) {
                                    return 'Quarter Qty must be greater than Pack Qty';
                                  }
                                  
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildField(
                                _quarterprice_controller,
                                'Quarter Price',
                                Icons.attach_money,
                                isNumber: true,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.remove_circle, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  pricingStep = 1;
                                  _quarterqty_controller.clear();
                                  _quarterprice_controller.clear();
                                  _packQtyController.clear();
                                  _packprice_controller.clear();
                                });
                              },
                            ),
                          ],
                        ),

                      if (pricingStep >= 2) const SizedBox(height: 15),

                      /// PACK ROW
                      if (pricingStep >= 3)
                        Row(
                          children: [
                            Expanded(
                              child: _buildField(
                                _packQtyController,
                                'Pack Qty',
                                Icons.inventory,
                                isNumber: true,
                                validator: (v) {
                                  if (v == null || v.isEmpty) return 'Required';
                                  
                                  if (!_enableBoxPricing) return null;
                                  
                                  final packQty = int.tryParse(v) ?? 0;
                                  final boxQty = int.tryParse(_boxQtyController.text) ?? 0;
                                  final halfQty = int.tryParse(_halfboxqty_controller.text) ?? 0;
                                  final quarterQty = int.tryParse(_quarterqty_controller.text) ?? 0;
                                  
                                  // Box Qty must be divisible by Pack Qty
                                  if (boxQty > 0 && packQty > 0 && boxQty % packQty != 0) {
                                    return 'Box Qty must be divisible by Pack Qty';
                                  }
                                  
                                  if (boxQty > 0 && packQty > boxQty) {
                                    return 'Pack Qty cannot exceed Box Qty';
                                  }
                                  
                                  if (halfQty > 0 && packQty >= halfQty) {
                                    return 'Pack Qty must be less than Half Qty';
                                  }
                                  
                                  if (quarterQty > 0 && packQty >= quarterQty) {
                                    return 'Pack Qty must be less than Quarter Qty';
                                  }
                                  
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildField(
                                _packprice_controller,
                                'Pack Price',
                                Icons.attach_money,
                                isNumber: true,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.remove_circle, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  pricingStep = 2;
                                  _packQtyController.clear();
                                  _packprice_controller.clear();
                                });
                              },
                            ),
                          ],
                        ),
                    ],

                    SizedBox(height: 10,),

                    _buildField(_costController, 'Unit Cost Price', Icons.attach_money, isNumber: true),
                    const SizedBox(height: 10),

                    DropdownButtonFormField<String>(
                      value: _productType,
                      decoration: _buildDropdownDecoration('Product Type'),
                      items: const [
                        DropdownMenuItem(value: 'product', child: Text('Product')),
                        DropdownMenuItem(value: 'service', child: Text('Service')),
                      ],
                      onChanged: (v) => setState(() => _productType = v),
                      validator: (v) => v == null ? 'Select product type' : null,
                    ),
                    const SizedBox(height: 10),
                    Consumer<Datafeed>(
                      builder: (context, datafeed, _) {

                        if (datafeed.loadingproductcategory) {
                          return const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (datafeed.productcategory.isEmpty) {
                          return const Text(
                            "No product categories found",
                            style: TextStyle(color: Colors.white54),
                          );
                        }

                        return DropdownButtonFormField<String>(
                          value: _productCategory,
                          decoration: _buildDropdownDecoration('Product category'),
                          items: datafeed.productcategory
                              .map(
                                (w) => DropdownMenuItem<String>(
                              value: w.productname,
                              child: Text(w.productname),
                            ),
                          )
                              .toList(),
                          onChanged: (v) => setState(() => _productCategory = v),
                          validator: (v) => v == null ? 'Select product category' : null,
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white70,
                          backgroundColor: Colors.white60,
                        ),
                        onPressed: _loading ? null : () async {
                          if (!_formKey.currentState!.validate()) return;

                          setState(() => _loading = true);

                          try {
                            // Get companyid from Datafeed provider
                            final datafeed = context.read<Datafeed>();
                            final companyId = datafeed.companyid;
                            final itemName = _nameController.text.trim();

                            String sanitize(String input) {
                              return input.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '').replaceAll(RegExp(r'[^a-z0-9_]'), '');
                            }
                            final docId = '${sanitize(companyId)}_${sanitize(itemName)}';
                            final docRef = _db.collection('itemsreg').doc(docId);

                            final imageUrl = await uploadLogo(docId);

                            // Generate and upload barcode and QR code if barcode is provided
                            String? barcodeUrl;
                            String? qrUrl;
                            final barcodeText = _barcodeController.text.trim();
                            
                            if (barcodeText.isNotEmpty) {
                              final barcodeCodes = await generateAndUploadBarcodeCodes(barcodeText, docId);
                              barcodeUrl = barcodeCodes['barcodeUrl'];
                              qrUrl = barcodeCodes['qrUrl'];
                            }
                            
                            // Validate wholesale and supplier min qty only if both are filled
                            final wholesaleText = _wholesaleMinQtyController.text.trim();
                            final supplierText = _supplierMinQtyController.text.trim();
                            
                            if (wholesaleText.isNotEmpty && supplierText.isNotEmpty) {
                              final wMin = int.tryParse(wholesaleText) ?? 0;
                              final sMin = int.tryParse(supplierText) ?? 0;
                              
                              // Skip validation when either is 1
                              if (wMin != 1 && sMin != 1 && wMin >= sMin) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Wholesale min qty must be less than supplier min qty")),
                                );
                                setState(() => _loading = false);
                                return;
                              }
                            }

                            Map<String, dynamic> modesMap = {
                              "single": {
                                'name': 'Single',
                                'sp': _supplierPriceController.text.trim(),
                                'wp': _wholesalePriceController.text.trim(),
                                'rp': _retail_price.text.trim(),
                                'qty': _boxQtyController.text.trim(),
                              }
                            };


                            if (_enableBoxPricing) {

                              // Half box
                              if (pricingStep >= 1 &&
                                  _halfboxqty_controller.text.isNotEmpty &&
                                  _halfboxprice_controller.text.isNotEmpty) {
                                modesMap["half"] = {
                                  'name': 'Half carton',
                                  'sp': _halfboxprice_controller.text.trim(),
                                  'wp': _halfboxprice_controller.text.trim(),
                                  'rp': _halfboxprice_controller.text.trim(),
                                  'qty': _halfboxqty_controller.text.trim(),
                                };
                              }

                              // Quarter box
                              if (pricingStep >= 2 &&
                                  _quarterqty_controller.text.isNotEmpty &&
                                  _quarterprice_controller.text.isNotEmpty) {
                                modesMap["quarter"] = {
                                  'name': 'Quarter carton',
                                  'sp': _quarterprice_controller.text.trim(),
                                  'wp': _quarterprice_controller.text.trim(),
                                  'rp': _quarterprice_controller.text.trim(),
                                  'qty': _quarterqty_controller.text.trim(),
                                };
                              }

                              // Pack
                              if (pricingStep >= 3 &&
                                  _packQtyController.text.isNotEmpty &&
                                  _packprice_controller.text.isNotEmpty) {
                                modesMap["pack"] = {
                                  'name': 'Pack',
                                  'sp': _packprice_controller.text.trim(),
                                  'wp': _packprice_controller.text.trim(),
                                  'rp': _packprice_controller.text.trim(),
                                  'qty': _packQtyController.text.trim(),
                                };
                              }
                            }

                            final data = {
                              'id': docId,
                              'companyid': datafeed.companyid,
                              'company': datafeed.company,
                              'name': itemName,
                              'barcode': _barcodeController.text.trim(),
                              'barcodeUrl': barcodeUrl,
                              'qrUrl': qrUrl,
                              'cp': _costController.text.trim(),
                              'pcategory': _productCategory,
                              'imageurl': imageUrl,
                              'updatedat': FieldValue.serverTimestamp(),
                              'updatedby':  datafeed.staff,
                              'deletedby': datafeed.staff,
                              'deletedat': FieldValue.serverTimestamp(),
                              'modemore': _enableBoxPricing,
                              'modes': modesMap,
                              'wminqty': _wholesaleMinQtyController.text,
                              'sminqty': _supplierMinQtyController.text,
                            };

                            if (widget.docId == null) {
                              data['createdAt'] = FieldValue.serverTimestamp();
                            }

                            await docRef.set(data, SetOptions(merge: true));

                            if (mounted) Navigator.pop(context, true);
                          } catch (e) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(SnackBar(content: Text('Error: $e')));
                          }

                          setState(() => _loading = false);
                        },
                        child: _loading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Save Item'),
                      ),
                    ),
                  ],
                ),

              ),
            ),
          ),
        ),
        floatingActionButton: _enableBoxPricing
            ? Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FloatingActionButton(
                      mini: true,
                      heroTag: 'add_pricing',
                      backgroundColor: Colors.green,
                      onPressed: () {
                        setState(() {
                          if (pricingStep < 3) pricingStep++;
                        });
                      },
                      child: const Icon(Icons.add),
                    ),
                    const SizedBox(width: 12),
                    FloatingActionButton(
                      mini: true,
                      heroTag: 'toggle_pricing',
                      backgroundColor: Colors.blue,
                      onPressed: () {
                        setState(() => _enableBoxPricing = false);
                      },
                      child: const Icon(Icons.close),
                    ),
                  ],
                ),
              )
            : FloatingActionButton(
                heroTag: 'toggle_pricing',
                backgroundColor: Colors.green,
                onPressed: () {
                  setState(() => _enableBoxPricing = true);
                },
                child: const Icon(Icons.add),
              ),

      );
    });
  }

  // ================= IMAGE UI =================
  Widget _imagePickerSection() {
    Widget preview;

    if (_logoBytes != null) {
      preview = Image.memory(_logoBytes!, fit: BoxFit.cover);
    } else if (_logoFile != null) {
      preview = Image.file(_logoFile!, fit: BoxFit.cover);
    } else if (_existingLogoUrl != null && _existingLogoUrl!.isNotEmpty) {
      preview = Image.network(_existingLogoUrl!, fit: BoxFit.cover);
    } else {
      preview = const Icon(Icons.image, size: 50, color: Colors.white38);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Item Image (optional)', style: TextStyle(color: Colors.white70)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: pickLogo,
          child: Container(
            height: 140,
            width: 140,
            decoration: BoxDecoration(
              color: const Color(0xFF22304A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white24),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Center(child: preview),
            ),
          ),
        ),
        const SizedBox(height: 6),
        TextButton.icon(
          onPressed: pickLogo,
          icon: const Icon(Icons.upload),
          label: const Text('Select Image'),
        ),
      ],
    );
  }

  // ================= FIELDS =================
  Widget _priceField(TextEditingController controller, String label, IconData icon) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(color: Colors.white70),
      decoration: _inputDecoration(label, icon),
    );
  }

  TextFormField _buildField(TextEditingController controller, String label, IconData icon,{bool isNumber = false,  Function(String)? onChanged,String? Function(String?)? validator,}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      style: const TextStyle(color: Colors.white70),
      validator: validator ??  (v) => v == null || v.isEmpty ? 'Required' : null,
      decoration: _inputDecoration(label, icon),
      onChanged: onChanged,
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(icon, color: Colors.white70),
      filled: true,
      fillColor: const Color(0xFF22304A),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white24),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.blue),
      ),
    );
  }

  InputDecoration _buildDropdownDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: const Color(0xFF22304A),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white24),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }


}

