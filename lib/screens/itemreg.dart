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
import 'dart:ui' as ui;
import 'package:pdf/pdf.dart';

import '../providers/Datafeed.dart';

class ItemRegPage extends StatefulWidget {
  final String? docId;
  final Map<String, dynamic>? data;

  const ItemRegPage({Key? key, this.docId, this.data}) : super(key: key);

  @override
  State<ItemRegPage> createState() => _ItemRegPageState();
}
  Future<Uint8List?> generateBarcodeImage(String barcode) async {
    try {
      final barcodeWidget = BarcodeWidget(
        barcode: Barcode.code128(),
        data: barcode,
        width: 200,
        height: 80,
      );
      return await _captureWidget(barcodeWidget);
    } catch (e) {
      print('Error generating barcode: $e');
      return null;
    }
  }

  Future<Uint8List?> generateQRCodeImage(String data) async {
    try {
      // QR code generation via widget capture is complex
      // For now, return null and handle in UI
      print('QR code generation stub - platform-specific implementation needed');
      return null;
    } catch (e) {
      print('Error generating QR code: $e');
      return null;
    }
  }

  Future<Uint8List?> _captureWidget(Widget widget) async {
    try {
      print('Note: Widget capture requires platform-specific implementation');
      return null;
    } catch (e) {
      print('Error capturing widget: $e');
      return null;
    }
  }

  Future<String?> uploadBarcodeImage(String itemId, Uint8List imageBytes, String type) async {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('items')
          .child('$itemId/$type.png');

      await ref.putData(
        imageBytes,
        SettableMetadata(contentType: 'image/png'),
      );
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error uploading $type image: $e');
      return null;
    }
  }

class _ItemRegPageState extends State<ItemRegPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _costController = TextEditingController();

  bool _enableBoxPricing = false;
  bool _showBoxPricingSwitch = false;
  final _boxQtyController = TextEditingController();
  final _retailPriceController = TextEditingController();
  final _wholesalePriceController = TextEditingController();
  final _supplierPriceController = TextEditingController();

// Half prices (auto)
  final _halfQtyController = TextEditingController();
  final _halfRetailController = TextEditingController();
  final _halfWholesaleController = TextEditingController();
  final _halfSupplierController = TextEditingController();

// Quarter prices (auto)
  final _quarterQtyController = TextEditingController();
  final _quarterRetailController = TextEditingController();
  final _quarterWholesaleController = TextEditingController();
  final _quarterSupplierController = TextEditingController();

// Pack
  final _packQtyController = TextEditingController();
  final _packRetailController = TextEditingController();
  final _packWholesaleController = TextEditingController();
  final _packSupplierController = TextEditingController();


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


  Future<void> saveItem() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final docRef = widget.docId == null
          ? _db.collection('items').doc()
          : _db.collection('items').doc(widget.docId);

      final imageUrl = await uploadLogo(docRef.id);
      if (_enableBoxPricing) {
        final wMin = int.tryParse(_wholesaleMinQtyController.text) ?? 0;
        final sMin = int.tryParse(_supplierMinQtyController.text) ?? 0;

        if (wMin >= sMin) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Wholesale min qty must be less than supplier min qty")),
          );
          setState(() => _loading = false);
          return;

              // Generate barcode and QR code
              String? barcodeUrl;
              String? qrCodeUrl;
      
              final barcodeInput = _barcodeController.text.trim();
              if (barcodeInput.isNotEmpty) {
                final barcodeImage = await generateBarcodeImage(barcodeInput);
                if (barcodeImage != null) {
                  barcodeUrl = await uploadBarcodeImage(docRef.id, barcodeImage, 'barcode');
                }
        
                final qrImage = await generateQRCodeImage(barcodeInput);
                if (qrImage != null) {
                  qrCodeUrl = await uploadBarcodeImage(docRef.id, qrImage, 'qrcode');
                }
              }
        }
      }

      // Build pricing structure
      final boxQty = int.tryParse(_boxQtyController.text) ?? 0;
      final retailPrice = _retailPriceController.text;
      final wholesalePrice = _wholesalePriceController.text;
      final supplierPrice = _supplierPriceController.text;
      
      final pricingData = {
        'carton': {
          'qty': boxQty,
          'retail': retailPrice,
          'wholesale': wholesalePrice,
          'supplier': supplierPrice,
        }
      };

      // Add half pricing if enabled
      if (_enableBoxPricing && _halfQtyController.text.isNotEmpty) {
        pricingData['half'] = {
          'qty': _halfQtyController.text,
          'retail': _halfRetailController.text,
          'wholesale': _halfWholesaleController.text,
          'supplier': _halfSupplierController.text,
        };
      }

      // Add quarter pricing if enabled
      if (_enableBoxPricing && _quarterQtyController.text.isNotEmpty) {
        pricingData['quarter'] = {
          'qty': _quarterQtyController.text,
          'retail': _quarterRetailController.text,
          'wholesale': _quarterWholesaleController.text,
          'supplier': _quarterSupplierController.text,
        };
      }


      if (_enableBoxPricing && _packQtyController.text.isNotEmpty) {
        pricingData['pack'] = {
          'qty': _packQtyController.text,
          'retail': _packRetailController.text,
          'wholesale': _packWholesaleController.text,
          'supplier': _packSupplierController.text,
        };
      }

      final data = {
        'name': _nameController.text.trim(),
        'barcode': _barcodeController.text.trim(),
        'costprice': _costController.text.trim(),
        'producttype': _productType,
        'pricingmode': _pricingMode,
        'productcategory': _productCategory,
        'imageurl': imageUrl,
        'updatedat': FieldValue.serverTimestamp(),
        'boxpricingenabled': _enableBoxPricing,
        'boxqty': boxQty,
        'boxretailprice': retailPrice,
        'boxwholesalesprice': wholesalePrice,
        'boxsupplierprice': supplierPrice,
        'pricing': pricingData,
        'wholesaleminqty': _wholesaleMinQtyController.text,
        'supplierminqty': _supplierMinQtyController.text,
        // if (barcodeUrl != null) 'barcodeurl': barcodeUrl,
        // if (qrCodeUrl != null) 'qrcodeurl': qrCodeUrl,
      };

      if (widget.docId == null) {
        data['createdat'] = FieldValue.serverTimestamp();
        await docRef.set(data);
      } else {
        await docRef.update(data);
      }

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }

    setState(() => _loading = false);
  }


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
                    const SizedBox(height: 10),
                    _buildField(
                      _boxQtyController,
                      'Box quantity',
                      Icons.attach_money,
                      isNumber: true,
                      onChanged: (value) {
                        final qty = int.tryParse(value) ?? 0;
                        if (qty == 1) {
                          // When box qty is 1, disable box pricing
                          _enableBoxPricing = false;
                          _showBoxPricingSwitch = false;

                          _halfQtyController.clear();
                          _quarterQtyController.clear();
                          _halfRetailController.clear();
                          _halfWholesaleController.clear();
                          _halfSupplierController.clear();
                          _quarterRetailController.clear();
                          _quarterWholesaleController.clear();
                          _quarterSupplierController.clear();
                          _packQtyController.clear();
                          _packRetailController.clear();
                          _packWholesaleController.clear();
                          _packSupplierController.clear();
                        } else if (qty > 1) {
                          _enableBoxPricing = true;
                          _showBoxPricingSwitch = true;

                          // Auto calculate quantities (half and quarter)
                          final halfQty = (qty / 2).floor();
                          final quarterQty = (qty / 4).floor();

                          _halfQtyController.text = halfQty.toString();
                          _quarterQtyController.text = quarterQty.toString();

                          // Clear pack if box qty changed
                          _packQtyController.clear();
                        } else {
                          _enableBoxPricing = false;
                          _showBoxPricingSwitch = false;

                          _wholesalePriceController.clear();
                          _retailPriceController.clear();
                          _supplierPriceController.clear();
                          _halfQtyController.clear();
                          _quarterQtyController.clear();
                          _halfRetailController.clear();
                          _halfWholesaleController.clear();
                          _halfSupplierController.clear();
                          _quarterRetailController.clear();
                          _quarterWholesaleController.clear();
                          _quarterSupplierController.clear();
                          _packQtyController.clear();
                          _packRetailController.clear();
                          _packWholesaleController.clear();
                          _packSupplierController.clear();
                        }

                        // Trigger rebuild after updating controllers
                        setState(() {});
                        
                        // Validate form after updating
                        _formKey.currentState?.validate();
                      },
                    ),
                    SizedBox(height: 10,),
                   _buildField(
                     _retailPriceController,
                     'Retail Price',
                     Icons.attach_money,
                     isNumber: true,
                     validator: (v) {
                       if (v == null || v.isEmpty) return 'Required';
                       
                       final retailPrice = double.tryParse(v) ?? 0;
                       final wholesalePrice = double.tryParse(_wholesalePriceController.text) ?? 0;
                       
                       if (wholesalePrice > 0 && retailPrice < wholesalePrice) {
                         return 'Retail must be >= Wholesale';
                       }
                       return null;
                     },
                     onChanged: (v) {
                       // When box qty is 1, auto-sync wholesale to retail
                       if (int.tryParse(_boxQtyController.text) == 1) {
                         _wholesalePriceController.text = v;
                       }
                       _formKey.currentState?.validate();
                     },
                   ),
                    SizedBox(height: 10,),

                    Row(
                      children: [
                        Expanded(
                          child: _buildField(
                            _wholesalePriceController,
                            'Wholesale Price',
                            Icons.attach_money,
                            isNumber: true,
                            enabled: int.tryParse(_boxQtyController.text) != 1,
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Required';
                              
                              final wholesalePrice = double.tryParse(v) ?? 0;
                              final supplierPrice = double.tryParse(_supplierPriceController.text) ?? 0;
                              final retailPrice = double.tryParse(_retailPriceController.text) ?? 0;
                              
                              if (supplierPrice > 0 && wholesalePrice <= supplierPrice) {
                                return 'Wholesale must be > Supplier';
                              }
                              if (retailPrice > 0 && wholesalePrice > retailPrice) {
                                return 'Wholesale must be <= Retail';
                              }
                              return null;
                            },
                            onChanged: (v) => _formKey.currentState?.validate(),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildField(
                            _supplierPriceController,
                            'Supplier Price',
                            Icons.attach_money,
                            isNumber: true,
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Required';
                              
                              final supplierPrice = double.tryParse(v) ?? 0;
                              final wholesalePrice = double.tryParse(_wholesalePriceController.text) ?? 0;
                              
                              if (wholesalePrice > 0 && supplierPrice >= wholesalePrice) {
                                return 'Supplier must be < Wholesale';
                              }
                              return null;
                            },
                            onChanged: (v) => _formKey.currentState?.validate(),
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
                              if (v == null || v.isEmpty) return 'Required';

                              final wholesaleQty = int.tryParse(v) ?? 0;
                              final supplierQty =
                                  int.tryParse(_supplierMinQtyController.text) ?? 0;

                              if (supplierQty > 0 && wholesaleQty >= supplierQty) {
                                return 'Wholesale Min must be < Supplier Min';
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
                          ),
                        ),
                      ],
                    ),
                    if (_showBoxPricingSwitch)
                      SwitchListTile(
                        title: const Text(
                          "Enable Box Pricing",
                          style: TextStyle(color: Colors.white70),
                        ),
                        value: _enableBoxPricing,
                        onChanged: (v) {
                          setState(() => _enableBoxPricing = v);
                        },
                      ),

                    if (_enableBoxPricing) ...[
                      // =========== HALF QTY SECTION ===========
                      Row(
                        children: [
                          Expanded(
                            child: _buildField(
                              _halfQtyController,
                              'Half Qty',
                              Icons.inventory,
                              isNumber: true,
                              readOnly: true,
                              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildField(
                              _halfRetailController,
                              'Half Retail Price',
                              Icons.attach_money,
                              isNumber: true,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildField(
                              _halfWholesaleController,
                              'Half Wholesale Price',
                              Icons.attach_money,
                              isNumber: true,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildField(
                              _halfSupplierController,
                              'Half Supplier Price',
                              Icons.attach_money,
                              isNumber: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      // =========== QUARTER QTY SECTION ===========
                      Row(
                        children: [
                          Expanded(
                            child: _buildField(
                              _quarterQtyController,
                              'Quarter Qty',
                              Icons.inventory,
                              isNumber: true,
                              readOnly: true,
                              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildField(
                              _quarterRetailController,
                              'Quarter Retail Price',
                              Icons.attach_money,
                              isNumber: true,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildField(
                              _quarterWholesaleController,
                              'Quarter Wholesale Price',
                              Icons.attach_money,
                              isNumber: true,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildField(
                              _quarterSupplierController,
                              'Quarter Supplier Price',
                              Icons.attach_money,
                              isNumber: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      // =========== PACK QTY SECTION ===========
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
                                
                                final packQty = int.tryParse(v) ?? 0;
                                final boxQty = int.tryParse(_boxQtyController.text) ?? 0;
                                final halfQty = int.tryParse(_halfQtyController.text) ?? 0;
                                final quarterQty = int.tryParse(_quarterQtyController.text) ?? 0;
                                
                                // Check if pack qty is less than box qty
                                if (boxQty > 0 && packQty >= boxQty) {
                                  return 'Pack must be < Box Qty ($boxQty)';
                                }
                                
                                // Check if pack qty is less than half
                                if (halfQty > 0 && packQty >= halfQty) {
                                  return 'Pack must be < Half Qty ($halfQty)';
                                }
                                
                                // Check if pack qty is less than quarter
                                if (quarterQty > 0 && packQty >= quarterQty) {
                                  return 'Pack must be < Quarter Qty ($quarterQty)';
                                }
                                
                                // Check if pack qty is divisible by 2
                                if (packQty % 2 != 0) {
                                  return 'Pack must be divisible by 2';
                                }
                                
                                return null;
                              },
                              onChanged: (v) => _formKey.currentState?.validate(),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildField(
                              _packRetailController,
                              'Pack Retail Price',
                              Icons.attach_money,
                              isNumber: true,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildField(
                              _packWholesaleController,
                              'Pack Wholesale Price',
                              Icons.attach_money,
                              isNumber: true,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildField(
                              _packSupplierController,
                              'Pack Supplier Price',
                              Icons.attach_money,
                              isNumber: true,
                            ),
                          ),
                        ],
                      ),
                      ],
                    SizedBox(height: 10,),

                    _buildField(_costController, 'Cost Price', Icons.attach_money, isNumber: true),
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
                          foregroundColor: Colors.white70, // text color
                          backgroundColor: Colors.white60,     // button color (optional)
                        ),
                        onPressed: _loading ? null : saveItem,
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

  TextFormField _buildField(TextEditingController controller, String label, IconData icon,{bool isNumber = false,  Function(String)? onChanged,String? Function(String?)? validator, bool enabled = true, bool readOnly = false}) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      readOnly: readOnly,
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





