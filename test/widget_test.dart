import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' hide Uint8List;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kologsoft/providers/Datafeed.dart';
import 'package:provider/provider.dart';


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
        }
      }

      final data = {
        'name': _nameController.text.trim(),
        'barcode': _barcodeController.text.trim(),
        'costprice': _costController.text.trim(),
        'producttype': _productType,
        'pricingmode': _pricingMode,
        'productcategory': _productCategory,
        'imageurl': imageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
        'boxPricingEnabled': _enableBoxPricing,
        'boxQty': _boxQtyController.text,
        'retailBoxPrice': _retail_price.text,
        'wholesaleBoxPrice': _wholesalePriceController.text,
        'supplierBoxPrice': _supplierPriceController.text,
        'wholesaleMinQty': _wholesaleMinQtyController.text,
        'supplierMinQty': _supplierMinQtyController.text,
      };

      if (widget.docId == null) {
        data['createdAt'] = FieldValue.serverTimestamp();
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

                    SizedBox(height: 10,),
                    _buildField(_retail_price, 'Retail Price', Icons.attach_money, isNumber: true),
                    SizedBox(height: 10,),
                    const SizedBox(height: 10),
                    _buildField(_boxQtyController, 'Box quantity', Icons.attach_money, isNumber: true,
                      onChanged: (value) {
                        final qty = double.tryParse(value) ?? 0;
                        if (qty > 1) {
                          setState(() {
                            _halfboxqty_controller.text = (qty / 2).ceil().toString();
                            _quarterqty_controller.text = (qty / 4).ceil().toString();
                            _enableBoxPricing = true;
                            _showBoxPricingSwitch = true;
                          });

                        } else {
                          setState(() {
                            _enableBoxPricing = false;
                            _showBoxPricingSwitch = false;
                          });

                        }

                      },
                    ),
                    SizedBox(height: 10,),
                    Row(
                      children: [
                        Expanded(
                          child: _buildField(
                            onChanged: (val){
                              final qty = double.tryParse(val) ?? 0;
                              _halfboxprice_controller.text = (qty / 2).toStringAsFixed(2);
                              _quarterprice_controller.text = (qty / 4).toStringAsFixed(2);

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
                              if (v == null || v.isEmpty) return 'Required';

                              final wholesaleQty = int.tryParse(v) ?? 0;
                              final supplierQty =
                                  int.tryParse(_supplierMinQtyController.text) ?? 0;

                              if (supplierQty > 0 && wholesaleQty > supplierQty) {
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
                      Row(
                        children: [
                          Expanded(
                            child: _buildField(
                                _halfboxqty_controller,
                                'Half Box Qty',
                                Icons.inventory,
                                isNumber: true,
                                onChanged: (v) {

                                },
                                validator: (v) => v == null || v.isEmpty ? 'Required' : null
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildField(
                                _halfboxprice_controller,
                                'Half Box Price',
                                Icons.attach_money,
                                isNumber: true,
                                onChanged: (v) {

                                },
                                validator: (v) => v == null || v.isEmpty ? 'Required' : null
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Expanded(
                            child: _buildField(
                              _quarterqty_controller,
                              'Quarter Quantity',
                              Icons.attach_money,
                              isNumber: true,
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

                        ],
                      ),

                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _buildField(
                              validator: (v) {
                                final qty = double.tryParse(v!) ?? 0;
                                double mo=qty%2;
                                if(mo>0){

                                  return 'Pack Qty must be divisible by box qty';
                                }
                                //  _packprice_controller.text = (qty * (double.tryParse(_retail_price.text) ?? 0)).toStringAsFixed(2);
                              },
                              _packQtyController,
                              'Pack Qty',
                              Icons.inventory,
                              isNumber: true,
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





