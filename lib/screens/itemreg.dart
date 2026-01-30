import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' hide Uint8List;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as hiveBox;
import 'package:image_picker/image_picker.dart';
import 'package:kologsoft/providers/routes.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart' hide Barcode;
import '../models/itemregmodel.dart';
import '../providers/Datafeed.dart';


class ItemRegPage extends StatefulWidget {
  final String? docId;
  final ItemModel? item;

  const ItemRegPage({Key? key, this.docId, this.item}) : super(key: key);

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

  final _wholesaleMinQtyController = TextEditingController();
  final _supplierMinQtyController = TextEditingController();
  Map<String, TextEditingController> stockingControllers = {};
  // Local search for cached items
  final _searchController = TextEditingController();
  String? _productType;
  String? _productCategory;

  bool _loading = false;
  bool _imageExpanded = false;
  Uint8List? _logoBytes;
  File? _logoFile;
  String? _existingLogoUrl;

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  // ================= UNIFIED VALIDATION METHOD =================
  String? _validateField(String fieldName, String? value) {
    if (value == null || value.isEmpty) {
      if (fieldName == 'supplierMinQty') return null; // Optional field
      return 'Required';
    }

    switch (fieldName) {
      case 'retailPrice':
        double retailPrice = double.tryParse(value) ?? 0;
        double unitCost = double.tryParse(_costController.text) ?? 0;
        double boxPrice = double.tryParse(_wholesalePriceController.text) ?? 0;
        double supplierPrice =double.tryParse(_supplierPriceController.text) ?? 0;
        double boxQty = double.tryParse(_boxQtyController.text) ?? 1;
        double boxunitprice = boxPrice / boxQty;

        if (retailPrice <= 0) return 'Enter a valid retail price';
        if (boxQty == 1) {

        }
        if (unitCost > 0 && retailPrice < unitCost) {
          return 'Retail price GHS$retailPrice must be greater than\n Unit Cost which is GHS${boxPrice / boxQty}';
        }

        if (boxQty > 1) {
          if (retailPrice < boxunitprice) {
            return 'Retail price GHS$retailPrice must be equal to \n or greater than Box unit Price GHS${boxPrice / boxQty}';
          }

          if (supplierPrice > 0 && retailPrice < (supplierPrice / boxQty)) {
            return 'Unit retail price GHS$retailPrice must be equal \n to or greater than Supplier Price ${supplierPrice / boxQty}';
          }

          if (retailPrice < unitCost) {
            return 'Retail price GHS$retailPrice must be greater than\n or equal to Unit Cost GHS$unitCost';
          }
        }
        return null;

      case 'costPrice':
        final costPrice = double.tryParse(value) ?? 0;
        final retailPrice = double.tryParse(_retail_price.text) ?? 0;

        if (retailPrice > 0 && costPrice > retailPrice) {
          return 'Unit Cost Price GHS$costPrice must be less than Retail Price GHS$retailPrice';
        }
        return null;

      case 'boxQty':
        final boxQty = int.tryParse(value) ?? 0;
        if (boxQty < 1) {
          return 'Box quantity must be at least 1';
        }
        return null;

      case 'boxPrice':
        final boxQty = double.tryParse(_boxQtyController.text) ?? 0;
       // if (boxQty == 1) return null;

        double boxPrice = double.tryParse(value) ?? 0;
        double boxQtyVal = double.tryParse(_boxQtyController.text) ?? 1;
        double pricePerUnit = boxQtyVal > 0 ? boxPrice / boxQtyVal : 0;
        double retailPrice = double.tryParse(_retail_price.text) ?? 0;
        double costPrice = double.tryParse(_costController.text) ?? 0;

        if (boxQty == 1) {
          // if (supplierPrice != boxPrice || supplierPrice != retailPrice) {
          //   return 'Prices should be equal because Box Qty is 1,';
          // }
          if(costPrice > boxPrice){
            return 'Cost price  GHS$costPrice \n is more than Box Price GHS$boxPrice';
          }
          if(boxPrice > retailPrice){
            return 'Box price  GHS$boxPrice \n can more than Retail Price GHS$retailPrice';
          }
          return null;
        }

        if (pricePerUnit > retailPrice) {
          return 'Price per unit which is GHS${boxPrice / boxQtyVal} \n Qty cannot be less than Retail Price';
        }

        if (pricePerUnit < costPrice) {
          return 'Price per unit which is GHS${boxPrice / boxQtyVal} \n Qty cannot be less than Unit Cost Price';
        }
        return null;

      case 'supplierPrice':
        final boxQty = double.tryParse(_boxQtyController.text) ?? 0;
        if (boxQty <= 0) return null;

        final supplierPrice = double.tryParse(value) ?? 0;
        final unitCost = double.tryParse(_costController.text) ?? 0;
        final boxPrice = double.tryParse(_wholesalePriceController.text) ?? 0;
        final retailPrice = double.tryParse(_retail_price.text) ?? 0;
        double costPrice = double.tryParse(_costController.text) ?? 0;
        if (boxQty == 1) {
          if(costPrice > supplierPrice){
            return 'Cost price  GHS$costPrice \n is more than Supplier Price GHS$supplierPrice';
          }
          if(supplierPrice > retailPrice){
            return 'Supplier price  GHS$supplierPrice \n is more than Retail Price GHS$retailPrice';
          }
          return null;
        }

        final minSupplierPrice = unitCost * boxQty;
        if (supplierPrice < minSupplierPrice) {
          return 'Supplier Price GHS$supplierPrice must be more\n or equal to  (${minSupplierPrice.toStringAsFixed(2)})';
        }

        if (supplierPrice > boxPrice) {
          return 'Supplier Price must be less than \n or equal to Box Price';
        }
        return null;

      case 'supplierMinQty':
        final supplierQty = int.tryParse(value) ?? 0;
        if (supplierQty == 1) return null;
        return null;

      case 'halfBoxQty':
        final halfBoxQty = int.tryParse(value) ?? 0;
        final boxQty = int.tryParse(_boxQtyController.text) ?? 0;

        if (boxQty == 0) return null;

        final requiredHalfQty = (boxQty / 2).ceil();
        if (halfBoxQty > boxQty) {
          return 'Half Box Qty cannot exceed Box Qty';
        }
        if (halfBoxQty < requiredHalfQty) {
          return 'Half Box Qty must be at least $requiredHalfQty';
        }
        return null;

      case 'halfBoxPrice':
        final halfBoxPrice = double.tryParse(value) ?? 0;
        final boxPrice = double.tryParse(_wholesalePriceController.text) ?? 0;
        if (boxPrice == 0) return null;

        final requiredHalfPrice = boxPrice / 2;
        if (halfBoxPrice > boxPrice) {
          return 'Half Box Price cannot exceed Box Price';
        }
        if (halfBoxPrice < requiredHalfPrice) {
          return 'Half Box Price must be at least ${requiredHalfPrice.toStringAsFixed(2)}';
        }
        return null;

      case 'quarterQty':
        final quarterQty = int.tryParse(value) ?? 0;
        final boxQty = int.tryParse(_boxQtyController.text) ?? 0;
        final halfQty = int.tryParse(_halfboxqty_controller.text) ?? 0;
        final packQty = int.tryParse(_packQtyController.text) ?? 0;

        if (boxQty == 0) return null;

        final requiredQuarterQty = (boxQty / 4).ceil();
        if (quarterQty > boxQty) {
          return 'Quarter Qty cannot exceed Box Qty';
        }
        if (quarterQty < requiredQuarterQty) {
          return 'Quarter Qty must be at least $requiredQuarterQty';
        }
        if (halfQty > 0 && quarterQty >= halfQty) {
          return 'Quarter Qty must be less than Half Qty';
        }
        if (packQty > 0 && quarterQty <= packQty) {
          return 'Quarter Qty must be greater than Pack Qty';
        }
        return null;

      case 'quarterPrice':
        final quarterPrice = double.tryParse(value) ?? 0;
        final boxPrice = double.tryParse(_wholesalePriceController.text) ?? 0;
        final halfBoxPrice =
            double.tryParse(_halfboxprice_controller.text) ?? 0;

        if (boxPrice == 0) return null;

        final requiredQuarterPrice = boxPrice / 4;
        if (quarterPrice > boxPrice) {
          return 'Quarter Price cannot exceed Box Price';
        }
        if (quarterPrice < requiredQuarterPrice) {
          return 'Quarter Price must be at least ${requiredQuarterPrice.toStringAsFixed(2)}';
        }
        if (halfBoxPrice > 0 && quarterPrice >= halfBoxPrice) {
          return 'Quarter Price must be less than Half Box Price';
        }
        return null;

      case 'packQty':
        if (!_enableBoxPricing) return null;

        final packQty = int.tryParse(value) ?? 0;
        final boxQty = int.tryParse(_boxQtyController.text) ?? 0;
        final halfQty = int.tryParse(_halfboxqty_controller.text) ?? 0;
        final quarterQty = int.tryParse(_quarterqty_controller.text) ?? 0;

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

        final packUnitPrice = double.tryParse(_packprice_controller.text) ?? 0;
        final unitCost = double.tryParse(_costController.text) ?? 0;
        final totalPackPrice = packUnitPrice * boxQty;
        final totalUnitCost = unitCost * boxQty;

        if (totalPackPrice < totalUnitCost) {
          return 'Pack unit price × Box Qty must be ≥ Unit Cost × Box Qty';
        }
        return null;

      case 'packPrice':
        final packPrice = double.tryParse(value) ?? 0;
        final boxPrice = double.tryParse(_wholesalePriceController.text) ?? 0;
        final boxQty = double.tryParse(_boxQtyController.text) ?? 0;
        final packQty = double.tryParse(_packQtyController.text) ?? 0;
        final retailprice = double.tryParse(_retail_price.text) ?? 0;
        final unitcostprice =
            int.tryParse(_costController.text.toString()) ?? 0;

        if (boxQty == 0 || packQty == 0 || boxPrice == 0) return null;

        double unitboxprice = boxPrice / boxQty;
        final requiredPackPrice = packPrice / packQty;

        if (requiredPackPrice > retailprice ||
            requiredPackPrice < unitcostprice ||
            requiredPackPrice < unitboxprice) {
          return 'Please check Unit(box/cost/retail) price';
        }
        return null;

      default:
        return null;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {

      context.read<Datafeed>().fetchproductcategory();
    });

    if (widget.item  != null) {
      final d = widget.item !;
      // Basic fields
      _existingLogoUrl = d.imageurl;
      _nameController.text = d.name ?? '';
      _barcodeController.text = d.barcode ?? '';
      _costController.text = d.cp ?? '';
      _productCategory = d.productcategory;
      _productType = d.producttype;
      _costController.text = d.cp;
      _supplierMinQtyController.text = d.sminqty;

      // Enable box pricing switch
      _enableBoxPricing = d.modemore == true;

      // ----- LOAD MODES -----
      final modes = d.modes as Map<String, dynamic>? ?? {};

      // Single
      final single = modes['single'] ?? {};
      _retail_price.text = single['rp'] ?? '';

      // Pack
      final pack = modes['pack'] ?? {};
      _packQtyController.text = pack['qty'] ?? '';
      _packprice_controller.text = pack['wp'] ?? '';

      // Quarter
      final quarter = modes['quarter'] ?? {};
      _quarterqty_controller.text = quarter['qty'] ?? '';
      _quarterprice_controller.text = quarter['wp'] ?? '';

      // Half
      final half = modes['half'] ?? {};
      _halfboxqty_controller.text = half['qty'] ?? '';
      _halfboxprice_controller.text = half['wp'] ?? '';

      // Carton (Full Box)
      final carton = modes['carton'] ?? {};
      _boxQtyController.text = carton['qty'] ?? '';
      _supplierPriceController.text = carton['sp'] ?? '';
      _wholesalePriceController.text = carton['wp'] ?? '';
      final int boxQty = int.tryParse(_boxQtyController.text) ?? 0;
      final double boxPrice =
          double.tryParse(_wholesalePriceController.text) ?? 0;
      if (boxQty > 1 && boxPrice > 0) {
        // quantities
        final int halfQty = (boxQty / 2).ceil();
        final int quarterQty = (boxQty / 4).ceil();

        // prices
        final double halfPrice = boxPrice / 2;
        final double quarterPrice = boxPrice / 4;

        _halfboxqty_controller.text = halfQty.toString();
        _quarterqty_controller.text = quarterQty.toString();

        _halfboxprice_controller.text = halfPrice.toStringAsFixed(2);
        _quarterprice_controller.text = quarterPrice.toStringAsFixed(2);
      }
      // pricingStep: 0 = none, 1 = half, 2 = quarter, 3 = pack
      int step = 0;
      if (modes.containsKey('half')) step = 1;
      if (modes.containsKey('quarter')) step = 2;
      if (modes.containsKey('pack')) step = 3;
      pricingStep = step;

      _enableBoxPricing =
          modes.isNotEmpty &&
          (modes.containsKey('carton') ||
              modes.containsKey('half') ||
              modes.containsKey('quarter') ||
              modes.containsKey('pack'));
      _showBoxPricingSwitch = _enableBoxPricing;

      try {
        final boxQtyVal = int.tryParse(_boxQtyController.text) ?? 0;
        if (boxQtyVal == 1) {
          final retail = _retail_price.text;
          _wholesalePriceController.text = retail;
          _supplierPriceController.text = retail;
        }
      } catch (_) {}
    }
  }

  void _clearAllFields() {
    // Reset form validation
    _formKey.currentState?.reset();
    setState(() {
      _nameController.clear();
      _barcodeController.clear();
      _costController.clear();
      _boxQtyController.clear();
      _halfboxqty_controller.clear();
      _quarterqty_controller.clear();
      _retail_price.clear();
      _packQtyController.clear();
      _supplierPriceController.clear();
      _wholesalePriceController.clear();
      _halfboxprice_controller.clear();
      _quarterprice_controller.clear();
      _packprice_controller.clear();
      _wholesaleMinQtyController.clear();
      _supplierMinQtyController.clear();

      // Reset dropdown values
      _productType = null;
      _productCategory = null;

      // Reset pricing options
      pricingStep = 0;
      _enableBoxPricing = false;
      _showBoxPricingSwitch = false;

      // Clear image
      _logoBytes = null;
      _logoFile = null;
      _existingLogoUrl = null;
    });
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
      return _existingLogoUrl;
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

  Future<void> _scanBarcode() async {
    try {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const BarcodeScannerScreen()),
      );

      if (result != null && result is String) {
        setState(() {
          _barcodeController.text = result;
        });
        _formKey.currentState?.validate();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening scanner: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Datafeed>(
      builder: (context, datafeed, child) {
        final companyType = datafeed.companytype;

        return Scaffold(
          backgroundColor: const Color(0xFF101624),
          appBar: AppBar(
            title: Text(widget.docId == null ? 'Register Item' : 'Edit Item'),
          ),
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
                      _buildField(
                        _nameController,
                        'Item Name',
                        Icons.label,
                        onChanged: (v) {
                          _formKey.currentState!.validate();
                        },
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _buildField(
                              _barcodeController,
                              'Barcode',
                              Icons.qr_code,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            height: 56,
                            decoration: BoxDecoration(
                              color: const Color(0xFF22304A),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.qr_code_scanner,
                                color: Colors.white70,
                              ),
                              onPressed: _scanBarcode,
                              tooltip: 'Scan Barcode/QR Code',
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      SizedBox(
                        child: _buildField(
                          _retail_price,
                          'Retail Price',
                          Icons.attach_money,
                          isNumber: true,
                          validator: (v) => _validateField('retailPrice', v),
                          onChanged: (value) {
                            final boxQty = double.tryParse(_boxQtyController.text) ?? 0;
                            if (boxQty == 1) {
                              //_enableBoxPricing
                              setState(() {
                                _wholesalePriceController.text = value;
                                _supplierPriceController.text = value;
                              });
                            }
                            _formKey.currentState?.validate();
                          },
                        ),
                      ),
                      SizedBox(height: 10),

                      SizedBox(
                        child: _buildField(
                          _costController,
                          'Unit Cost Price',
                          Icons.attach_money,
                          isNumber: true,
                          onChanged: (_) {
                            _formKey.currentState?.validate();
                          },
                          validator: (v) => _validateField('costPrice', v),
                        ),
                      ),

                      SizedBox(height: 10),
                      _buildField(
                        _boxQtyController,
                        'Box quantity',
                        Icons.attach_money,
                        isNumber: true,
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
                          _formKey.currentState!.validate();
                        },
                        validator: (v) => _validateField('boxQty', v),
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _buildFieldWithEnabled(
                              onChanged: (val) {
                                final price = double.tryParse(val) ?? 0;
                                _halfboxprice_controller.text = (price / 2).toStringAsFixed(2);
                                _quarterprice_controller.text = (price / 4).toStringAsFixed(2);
                                _formKey.currentState?.validate();
                              },
                              _wholesalePriceController,
                              'Box Price',
                              Icons.attach_money,
                              isNumber: true,
                             // enabled: double.tryParse(_boxQtyController.text) != 1,
                              validator: (v) => _validateField('boxPrice', v),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildFieldWithEnabled(
                              _supplierPriceController,
                              'Supplier Price',
                              Icons.attach_money,
                              isNumber: true,
                              onChanged: (v) {
                                _formKey.currentState!.validate();
                              },
                              validator: (v) => _validateField('supplierPrice', v),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),
                      SizedBox(
                        child: _buildField(
                          _supplierMinQtyController,
                          'Supplier Min Qty',
                          Icons.numbers,
                          isNumber: true,
                          onChanged: (value) {
                            _formKey.currentState?.validate();
                          },
                          validator: (v) =>
                              _validateField('supplierMinQty', v),
                        ),
                      ),
                      if (_enableBoxPricing) ...[
                        const SizedBox(height: 15),

                        /// HALF ROW
                        if (pricingStep >= 1)
                          Row(
                            children: [
                              Expanded(
                                child: _buildField(
                                  enabled: false,
                                  _halfboxqty_controller,
                                  'Half Box Qty',
                                  Icons.inventory,
                                  isNumber: true,
                                  validator: (v) =>
                                      _validateField('halfBoxQty', v),
                                  onChanged: (value) {
                                    //final qty = double.tryParse(value) ?? 0;
                                    _formKey.currentState?.validate();
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
                                  validator: (v) =>
                                      _validateField('halfBoxPrice', v),
                                  onChanged: (value) {
                                    _formKey.currentState?.validate();
                                  },
                                ),
                              ),
                              SizedBox(width: 10,),
                              Container(
                                height: 30,
                                width: 30,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF22304A),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.white24),
                                ),
                                child: IconButton(
                                  tooltip: 'Remove half pricing',
                                  padding: EdgeInsets.zero,
                                  splashRadius: 20,
                                  constraints: const BoxConstraints(),
                                  icon: const Icon(
                                    Icons.remove_circle,
                                    size: 20,
                                    color: Colors.white70,
                                  ),
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (context) => AlertDialog(
                                        backgroundColor: const Color(0xFF182232),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        title: const Text('Confirm removal', style: TextStyle(color: Colors.white)),
                                        content: const Text(
                                          'Remove half-box pricing for this item? This cannot be undone.',
                                          style: TextStyle(color: Colors.white70),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, false),
                                            child: const Text('Cancel'),
                                          ),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                            onPressed: () => Navigator.pop(context, true),
                                            child: const Text('Remove', style: TextStyle(color: Colors.white)),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirm != true) return;

                                    setState(() {
                                      pricingStep = 0;

                                      _halfboxqty_controller.clear();
                                      _halfboxprice_controller.clear();

                                      _quarterqty_controller.clear();
                                      _quarterprice_controller.clear();

                                      _packQtyController.clear();
                                      _packprice_controller.clear();
                                    });

                                    if (widget.docId != null) {
                                      try {
                                        await _db.collection('itemsreg').doc(widget.docId).update({'modes.half': FieldValue.delete(),});
                                        if (mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Half pricing removed'), backgroundColor: Colors.green, duration: Duration(seconds: 2)),
                                          );
                                        }
                                      } catch (e) {
                                        if (mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Failed to remove half pricing: $e'), backgroundColor: Colors.red),
                                          );
                                        }
                                      }
                                    }
                                  },
                                ),
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
                                  enabled: false,
                                  _quarterqty_controller,
                                  'Quarter Qty',
                                  Icons.inventory,
                                  isNumber: true,
                                  validator: (v) =>
                                      _validateField('quarterQty', v),
                                  onChanged: (value) {
                                    _formKey.currentState?.validate();
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
                                  validator: (v) {
                                    if (v == null || v.isEmpty)
                                      return 'Required';
                                    final quarterPrice =
                                        double.tryParse(v) ?? 0;
                                    final boxPrice =
                                        double.tryParse(
                                          _wholesalePriceController.text,
                                        ) ??
                                        0;
                                    final halfBoxPrice = double.tryParse(
                                          _halfboxprice_controller.text,
                                        ) ?? 0;

                                    if (boxPrice == 0) return null;

                                    final requiredQuarterPrice = boxPrice / 4;
                                    if (quarterPrice > boxPrice) {
                                      return 'Quarter Price cannot exceed Box Price';
                                    }
                                    if (quarterPrice < requiredQuarterPrice) {
                                      return 'Quarter Price must be at least ${requiredQuarterPrice.toStringAsFixed(2)}';
                                    }
                                    if (halfBoxPrice > 0 &&
                                        quarterPrice >= halfBoxPrice) {
                                      return 'Quarter Price must be less than Half Box Price';
                                    }
                                    return null;
                                  },
                                  onChanged: (value) {
                                    _formKey.currentState?.validate();
                                  },
                                ),
                              ),
                              SizedBox(width: 10,),
                              Container(
                                height: 30,
                                width: 30,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF22304A),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.white24),
                                ),
                                child: IconButton(
                                  tooltip: 'Remove quarter pricing',
                                  padding: EdgeInsets.zero,
                                  splashRadius: 20,
                                  constraints: const BoxConstraints(),
                                  icon: const Icon(
                                    Icons.remove_circle,
                                    size: 20,
                                    color: Colors.white70,
                                  ),
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (context) => AlertDialog(
                                        backgroundColor: const Color(0xFF182232),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        title: const Text('Confirm removal', style: TextStyle(color: Colors.white)),
                                        content: const Text(
                                          'Remove quarter pricing for this item? This cannot be undone.',
                                          style: TextStyle(color: Colors.white70),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, false),
                                            child: const Text('Cancel'),
                                          ),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                            onPressed: () => Navigator.pop(context, true),
                                            child: const Text('Remove', style: TextStyle(color: Colors.white)),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirm != true) return;

                                    setState(() {
                                      pricingStep = 1;
                                      _quarterqty_controller.clear();
                                      _quarterprice_controller.clear();
                                      _packQtyController.clear();
                                      _packprice_controller.clear();
                                    });

                                    if (widget.docId != null) {
                                      try {
                                        await _db.collection('itemsreg').doc(widget.docId).update({'modes.quarter': FieldValue.delete(),});

                                        if (mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Quarter pricing removed'), backgroundColor: Colors.green, duration: Duration(seconds: 2)),
                                          );
                                        }
                                      } catch (e) {
                                        if (mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Failed to remove quarter pricing: $e'), backgroundColor: Colors.red),
                                          );
                                        }
                                      }
                                    }
                                  },
                                ),
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
                                    if (v == null || v.isEmpty)
                                      return 'Required';
                                    if (!_enableBoxPricing) return null;

                                    final packQty = int.tryParse(v) ?? 0;
                                    final boxQty =
                                        int.tryParse(_boxQtyController.text) ??
                                        0;
                                    final halfQty =
                                        int.tryParse(
                                          _halfboxqty_controller.text,
                                        ) ??
                                        0;
                                    final quarterQty =
                                        int.tryParse(
                                          _quarterqty_controller.text,
                                        ) ??
                                        0;

                                    // Quantity rules
                                    if (boxQty > 0 &&
                                        packQty > 0 &&
                                        boxQty % packQty != 0) {
                                      return 'Box Qty must be divisible by Pack Qty';
                                    }

                                    if (boxQty > 0 && packQty > boxQty) {
                                      return 'Pack Qty cannot exceed Box Qty';
                                    }

                                    if (halfQty > 0 && packQty >= halfQty) {
                                      return 'Pack Qty must be less than Half Qty';
                                    }

                                    if (quarterQty > 0 &&
                                        packQty >= quarterQty) {
                                      return 'Pack Qty must be less than Quarter Qty';
                                    }

                                    // Price rule: pack unit price * total box qty ≥ unit cost * box qty
                                    final packUnitPrice =
                                        double.tryParse(
                                          _packprice_controller.text,
                                        ) ??
                                        0;
                                    final unitCost =
                                        double.tryParse(_costController.text) ??
                                        0;

                                    final totalPackPrice =
                                        packUnitPrice *
                                        boxQty; // total revenue from pack
                                    final totalUnitCost =
                                        unitCost *
                                        boxQty; // total cost for the box

                                    if (totalPackPrice < totalUnitCost) {
                                      return 'Pack unit price × Box Qty must be ≥ Unit Cost × Box Qty';
                                    }

                                    return null; // valid
                                  },
                                  onChanged: (v) {
                                    _formKey.currentState!.validate();
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
                                  validator: (v) {
                                    if (v == null || v.isEmpty)
                                      return 'Required';

                                    final packPrice = double.tryParse(v) ?? 0;
                                    final boxPrice =
                                        double.tryParse(
                                          _wholesalePriceController.text,
                                        ) ??
                                        0;
                                    final boxQty =
                                        double.tryParse(
                                          _boxQtyController.text,
                                        ) ??
                                        0;
                                    final packQty =
                                        double.tryParse(
                                          _packQtyController.text,
                                        ) ??
                                        0;
                                    final retailprice =
                                        double.tryParse(_retail_price.text) ??
                                        0;
                                    final unitcostprice =
                                        int.tryParse(
                                          _costController.text.toString(),
                                        ) ??
                                        0;

                                    if (boxQty == 0 ||
                                        packQty == 0 ||
                                        boxPrice == 0)
                                      return null;

                                    final packsPerBox = boxQty / packQty;
                                    final totalFromPacks =
                                        packsPerBox * packPrice;
                                    double unitboxprice = boxPrice / boxQty;

                                    final requiredPackPrice =
                                        packPrice / packQty;

                                    if (requiredPackPrice > retailprice ||
                                        requiredPackPrice < unitcostprice ||
                                        requiredPackPrice < unitboxprice) {
                                      return 'Please check Unit(box/cost/retail) price ';
                                    }

                                    return null;
                                  },
                                  onChanged: (value) {
                                    _formKey.currentState?.validate();
                                  },
                                ),
                              ),
                              SizedBox(width: 10,),
                              Container(
                                height: 30,
                                width: 30,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF22304A),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.white24),
                                ),
                                child: IconButton(
                                  tooltip: 'Remove pack pricing',
                                  padding: EdgeInsets.zero,
                                  splashRadius: 20,
                                  constraints: const BoxConstraints(),
                                  icon: const Icon(
                                    Icons.remove_circle,
                                    size: 20,
                                    color: Colors.white70,
                                  ),
                                  onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) => AlertDialog(
                                      backgroundColor: const Color(0xFF182232),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      title: const Text('Confirm removal', style: TextStyle(color: Colors.white)),
                                      content: const Text(
                                        'Remove pack pricing for this item? This cannot be undone.',
                                        style: TextStyle(color: Colors.white70),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, false),
                                          child: const Text('Cancel'),
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                          onPressed: () => Navigator.pop(context, true),
                                          child: const Text('Remove', style: TextStyle(color: Colors.white)),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirm != true) return;

                                  setState(() {
                                    pricingStep = 2;
                                    _packQtyController.clear();
                                    _packprice_controller.clear();
                                  });

                                  if (widget.docId != null) {
                                    try {
                                      await _db.collection('itemsreg').doc(widget.docId).update({
                                        'modes.pack': FieldValue.delete(),
                                      });

                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Pack pricing removed'),
                                            backgroundColor: Colors.green,
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Failed to remove pack pricing: $e'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    }
                                  }
                                  },
                                ),
                              ),
                            ],
                          ),
                      ],

                      const SizedBox(height: 10),

                      DropdownButtonFormField<String>(
                        initialValue: _productType,
                        dropdownColor: Color(0xFF1B263B),
                        style: TextStyle(color: Colors.white70),
                        decoration: _buildDropdownDecoration('Product Type'),
                        items: const [
                          DropdownMenuItem(
                            value: 'product',
                            child: Text('Product'),
                          ),
                          DropdownMenuItem(
                            value: 'service',
                            child: Text('Service'),
                          ),
                        ],
                        onChanged: (v) => setState(() {
                          _productType = v;
                          _formKey.currentState?.validate();
                        }),
                        validator: (v) =>
                            v == null ? 'Select product type' : null,
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
                            style: TextStyle(color: Colors.white70),
                            dropdownColor: Color(0xFF1B263B),
                            decoration: _buildDropdownDecoration(
                              'Product category',
                            ),
                            items: datafeed.productcategory
                                .map(
                                  (w) => DropdownMenuItem<String>(
                                    value: w.productname,
                                    child: Text(w.productname),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) => setState(() {
                              _productCategory = v;
                              _formKey.currentState?.validate();
                            }),
                            validator: (v) =>
                                v == null ? 'Select product category' : null,
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
                            backgroundColor: Colors.blue,
                          ),
                          onPressed: _loading ? null
                           : () async {
                                  if (!_formKey.currentState!.validate())
                                  return;
                                  setState(() => _loading = true);
                                  try {
                                    final datafeed = context.read<Datafeed>();
                                    final companyId = datafeed.companyid;
                                    final itemName = _nameController.text.trim();
                                    final barcode = _barcodeController.text.trim();

                                    if (widget.docId == null) {
                                      final nameQuery = await _db.collection('itemsreg')
                                          .where('companyid',isEqualTo: companyId, ).where('name', isEqualTo: itemName).limit(1)
                                          .get();

                                      if (nameQuery.docs.isNotEmpty) {
                                        if (mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'An item with name "$itemName" already exists for this company',
                                              ),
                                              backgroundColor: Colors.red,
                                              duration: const Duration(
                                                seconds: 4,
                                              ),
                                            ),
                                          );
                                        }
                                        setState(() => _loading = false);
                                        return;
                                      }

                                      // Check for duplicate barcode with same companyid
                                      final barcodeQuery = await _db
                                          .collection('itemsreg')
                                          .where(
                                            'companyid',
                                            isEqualTo: companyId,
                                          )
                                          .where('barcode', isEqualTo: barcode)
                                          .limit(1)
                                          .get();

                                      if (barcodeQuery.docs.isNotEmpty) {
                                        if (mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'An item with barcode "$barcode" already exists for this company',
                                              ),
                                              backgroundColor: Colors.red,
                                              duration: const Duration(
                                                seconds: 4,
                                              ),
                                            ),
                                          );
                                        }
                                        setState(() => _loading = false);
                                        return;
                                      }
                                    }

                                    String sanitize(String input) {
                                      return input
                                          .trim()
                                          .toLowerCase()
                                          .replaceAll(RegExp(r'\s+'), '')
                                          .replaceAll(
                                            RegExp(r'[^a-z0-9_]'),
                                            '',
                                          );
                                    }

                                    final docId =
                                        widget.docId ??
                                        '${sanitize(companyId)}_${sanitize(itemName)}';
                                    final docRef = _db
                                        .collection('itemsreg')
                                        .doc(docId);
                                    final imageUrl = await uploadLogo(docId);



                                 Map<String, dynamic> modesMap = Map<String, dynamic>.from(widget.item?.modes ?? {});
                                    modesMap["single"] = {
                                      'name': 'Single',
                                      'sp': _retail_price.text.trim(),
                                      'wp': _retail_price.text.trim(),
                                      'rp': _retail_price.text.trim(),
                                      'qty': '1',
                                    };

                                    double boxqty = _boxQtyController.text.isNotEmpty
                                        ? double.parse(_boxQtyController.text)
                                        : 0;
                                    if (boxqty >= 2) {
                                      modesMap["carton"] = {
                                        'name': 'carton',
                                        'sp': _supplierPriceController.text.trim(),
                                        'wp': _wholesalePriceController.text.trim(),
                                        'rp': _wholesalePriceController.text.trim(),
                                        'qty': _boxQtyController.text.trim(),
                                      };
                                    } else {
                                      modesMap.remove("carton");
                                    }

                                    if (_enableBoxPricing) {
                                      // HALF
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
                                      } else {
                                        modesMap.remove("half");
                                      }

                                      // QUARTER
                                      if (pricingStep >= 2 &&
                                          _quarterqty_controller.text.isNotEmpty &&
                                          _quarterprice_controller.text.isNotEmpty) {
                                        modesMap["quarter"] = {
                                          'name': 'Quarter carton',
                                          'sp': _quarterprice_controller.text.trim(),
                                          'wp': _quarterprice_controller.text.trim(),
                                          'rp': _retail_price.text.trim(),
                                          'qty': _quarterqty_controller.text.trim(),
                                        };
                                      } else {
                                        modesMap.remove("quarter");
                                      }

                                      // PACK
                                      if (pricingStep >= 3 &&
                                          _packQtyController.text.isNotEmpty &&
                                          _packprice_controller.text.isNotEmpty) {
                                        modesMap["pack"] = {
                                          'name': 'Pack',
                                          'sp': _packprice_controller.text.trim(),
                                          'wp': _packprice_controller.text.trim(),
                                          'rp': _retail_price.text.trim(),
                                          'qty': _packQtyController.text.trim(),
                                        };
                                      } else {
                                        modesMap.remove("pack");
                                      }
                                    } else {
                                      modesMap.remove("half");
                                      modesMap.remove("quarter");
                                      modesMap.remove("pack");
                                    }

                                    final item = ItemModel(
                                        id: docId,
                                        no: docId,
                                        name: itemName,
                                        barcode: _barcodeController.text.trim(),
                                        cp: _costController.text.trim(),
                                        retailmarkup: '',
                                        wholesalemarkup: '',
                                        retailprice: '',
                                        wholesaleprice: '',
                                        producttype: _productType ?? '',
                                        pricingmode: '',
                                        productcategory: _productCategory?? '',
                                        warehouse: '',
                                        openingstock: '',
                                        company: datafeed.company,
                                        companyid: datafeed.companyid,
                                        imageurl: imageUrl?? '',
                                        modes: modesMap,
                                      createdat: DateTime.now(),
                                      updatedby: null,
                                      updatedat: null,
                                      wminqty: _wholesaleMinQtyController.text,
                                      sminqty: _supplierMinQtyController.text,
                                      staff: datafeed.staff,
                                      modemore: _enableBoxPricing,
                                      deletedat: null,
                                      deletedby: null,
                                    );
                                    final data = item.toMap();
                                    if (widget.docId == null) {
                                      data['createdat'] =  FieldValue.serverTimestamp();
                                    }
                                    await docRef.set(data, SetOptions(merge: true),
                                    );
                                   // print(modesMap.toString());
                                    _clearAllFields();

                                    if (mounted) {
                                      ScaffoldMessenger.of( context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            widget.docId == null
                                                ? 'Item saved successfully!'
                                                : 'Item updated successfully!',
                                          ),
                                          backgroundColor: Colors.green,
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                      if(widget.docId!=null){
                                        Navigator.pushNamed(context, Routes.itemlist);
                                      }
                                    }

                                  } catch (e) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text('Error: $e'),
                                          backgroundColor: Colors.red,
                                          duration: const Duration(seconds: 4),
                                        ),
                                      );
                                    }
                                  }

                                  setState(() => _loading = false);
                                },
                          child: _loading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text('Save Item'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          floatingActionButton:
              _enableBoxPricing && double.tryParse(_boxQtyController.text) != 1
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
              : null,
        );
      },
    );
  }

  // ================= IMAGE UI =================
  Widget _imagePickerSection() {
    bool hasImage =
        _logoBytes != null ||
        _logoFile != null ||
        (_existingLogoUrl != null && _existingLogoUrl!.isNotEmpty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Compact toggle button
        InkWell(
          onTap: () {
            setState(() => _imageExpanded = !_imageExpanded);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF22304A),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white24),
            ),
            child: Row(
              children: [
                Icon(
                  hasImage ? Icons.image : Icons.add_photo_alternate,
                  color: hasImage ? Colors.green : Colors.white54,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    hasImage
                        ? 'Item Image (tap to change)'
                        : 'Item Image (optional - tap to add)',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ),
                Icon(
                  _imageExpanded ? Icons.expand_less : Icons.expand_more,
                  color: Colors.white54,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        // Expanded content
        if (_imageExpanded) ...[
          const SizedBox(height: 12),
          Center(
            child: GestureDetector(
              onTap: pickLogo,
              child: Container(
                height: 140,
                width: 140,
                decoration: BoxDecoration(
                  color: const Color(0xFF22304A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: hasImage ? Colors.green : Colors.white24,
                    width: hasImage ? 2 : 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Center(
                    child: hasImage
                        ? Stack(
                            children: [
                              if (_logoBytes != null)
                                Image.memory(
                                  _logoBytes!,
                                  fit: BoxFit.cover,
                                  width: 140,
                                  height: 140,
                                )
                              else if (_logoFile != null)
                                Image.file(
                                  _logoFile!,
                                  fit: BoxFit.cover,
                                  width: 140,
                                  height: 140,
                                )
                              else if (_existingLogoUrl != null &&
                                  _existingLogoUrl!.isNotEmpty)
                                Image.network(
                                  _existingLogoUrl!,
                                  fit: BoxFit.cover,
                                  width: 140,
                                  height: 140,
                                ),
                            ],
                          )
                        : const Icon(
                            Icons.add_photo_alternate,
                            size: 50,
                            color: Colors.white38,
                          ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                onPressed: pickLogo,
                icon: Icon(hasImage ? Icons.edit : Icons.upload, size: 18),
                label: Text(hasImage ? 'Change' : 'Select Image'),
                style: TextButton.styleFrom(foregroundColor: Colors.blue),
              ),
              if (hasImage) ...[
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _logoBytes = null;
                      _logoFile = null;
                      _existingLogoUrl = null;
                    });
                  },
                  icon: const Icon(Icons.delete, size: 18),
                  label: const Text('Remove'),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }

  // ================= FIELDS =================
  Widget _priceField(
    TextEditingController controller,
    String label,
    IconData icon,
  ) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(color: Colors.white70),
      decoration: _inputDecoration(label, icon),
    );
  }

  TextFormField _buildField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool enabled = true,
    bool isNumber = false,
    Function(String)? onChanged,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      enabled: enabled,
      controller: controller,
      keyboardType: isNumber
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      style: const TextStyle(color: Colors.white70),
      validator: validator ?? (v) => v == null || v.isEmpty ? 'Required' : null,
      decoration: _inputDecoration(label, icon),
      onChanged: onChanged,
    );
  }

  TextFormField _buildFieldWithEnabled(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isNumber = false,
    bool enabled = true,
    Function(String)? onChanged,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: isNumber
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      style: const TextStyle(color: Colors.white70),
      validator: validator ?? (v) => v == null || v.isEmpty ? 'Required' : null,
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

// Barcode Scanner Screen
class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({Key? key}) : super(key: key);

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Scan Barcode/QR Code'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: cameraController,
              builder: (context, value, child) {
                final isFlashOn = value.torchState == TorchState.on;
                return Icon(
                  isFlashOn ? Icons.flash_on : Icons.flash_off,
                  color: Colors.white,
                );
              },
            ),
            onPressed: () => cameraController.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch, color: Colors.white),
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) {
              if (_isProcessing) return;

              final barcodes = capture.barcodes;
              if (barcodes.isEmpty) return;

              final barcode = barcodes.first;
              final String? code = barcode.rawValue;

              if (code != null && code.isNotEmpty) {
                setState(() => _isProcessing = true);
                Navigator.pop(context, code);
              }
            },
          ),
          // Overlay with scanning guide
          Center(
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green, width: 3),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          // Instructions
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              // Only one child property is allowed
              child: const Text(
                'Position the barcode or QR code within the frame',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  backgroundColor: Colors.black54,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}
