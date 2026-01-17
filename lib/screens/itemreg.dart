import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/itemregmodel.dart';
import '../providers/Datafeed.dart';
import 'package:provider/provider.dart';

enum PriceMode {
  retailPercent,
  retailAbsolute,
  wholesalePercent,
  wholesaleAbsolute,
}

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

  final _retailMarkupController = TextEditingController();
  final _retailAbsoluteController = TextEditingController();

  final _wholesaleMarkupController = TextEditingController();
  final _wholesaleAbsoluteController = TextEditingController();

  final _openingStockController = TextEditingController();

  String? _productType;
  String? _pricingMode;
  String? _productCategory;
  String? _warehouse;

  bool _loading = false;

  PriceMode? _activeMode;

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<Datafeed>().fetchWarehouses();
    });
    if (widget.data != null) {
      final d = widget.data!;

      _nameController.text = d['name'] ?? '';
      _barcodeController.text = d['barcode'] ?? '';
      _costController.text = d['costprice'] ?? '';

      _retailMarkupController.text = d['retailmarkup'] ?? '';
      _retailAbsoluteController.text = d['retailabsolute'] ?? '';

      _wholesaleMarkupController.text = d['wholesalemarkup'] ?? '';
      _wholesaleAbsoluteController.text = d['wholesaleabsolute'] ?? '';

      _openingStockController.text = d['openingstock'] ?? '';

      _productType = d['producttype'];
      _pricingMode = d['pricingmode'];
      _productCategory = d['productcategory'];
      _warehouse = d['warehouse'];

      if (_retailMarkupController.text.isNotEmpty) {
        _activeMode = PriceMode.retailPercent;
      } else if (_retailAbsoluteController.text.isNotEmpty) {
        _activeMode = PriceMode.retailAbsolute;
      } else if (_wholesaleMarkupController.text.isNotEmpty) {
        _activeMode = PriceMode.wholesalePercent;
      } else if (_wholesaleAbsoluteController.text.isNotEmpty) {
        _activeMode = PriceMode.wholesaleAbsolute;
      }
    }
  }

  // ================= PRICE CALCULATION =================

  String calcRetailPrice() {
    final cost = double.tryParse(_costController.text) ?? 0;

    if (_activeMode == PriceMode.retailPercent) {
      final percent = double.tryParse(_retailMarkupController.text) ?? 0;
      return (cost + (cost * percent / 100)).toStringAsFixed(2);
    }

    if (_activeMode == PriceMode.retailAbsolute) {
      final value = double.tryParse(_retailAbsoluteController.text) ?? cost;
      return value.toStringAsFixed(2);
    }

    return cost.toStringAsFixed(2);
  }

  String calcWholesalePrice() {
    final cost = double.tryParse(_costController.text) ?? 0;

    if (_activeMode == PriceMode.wholesalePercent) {
      final percent = double.tryParse(_wholesaleMarkupController.text) ?? 0;
      return (cost + (cost * percent / 100)).toStringAsFixed(2);
    }

    if (_activeMode == PriceMode.wholesaleAbsolute) {
      final value = double.tryParse(_wholesaleAbsoluteController.text) ?? cost;
      return value.toStringAsFixed(2);
    }

    return cost.toStringAsFixed(2);
  }

  // =====================================================

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final formWidth = screenWidth > 900 ? screenWidth * 0.6 : screenWidth * 0.95;

    return Consumer<Datafeed>(
      builder: (context, datafeed, child) {

        final companyType = datafeed.companytype;

        final bool showRetail = companyType == "retail" || companyType == "both";

        final bool showWholesale =  companyType == "wholesale" || companyType == "both";

        return Scaffold(
          backgroundColor: const Color(0xFF101624),
          appBar: AppBar(
            title: Text(widget.docId == null ? "Register Item" : "Edit Item"),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 20),
            child: Align(
              alignment: Alignment.topCenter,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: Container(
                    width: formWidth,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B263B),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildField(_nameController, "Item Name", Icons.label),
                          const SizedBox(height: 14),
                          _buildField(_barcodeController, "Barcode", Icons.qr_code),
                          const SizedBox(height: 14),
                          _buildField(_costController, "Cost Price", Icons.attach_money, isNumber: true),
                          const SizedBox(height: 14),

                          // ================= RETAIL =================
                          if (showRetail) ...[
                            _priceField(
                              controller: _retailMarkupController,
                              label: "Retail Mark Up %",
                              icon: Icons.percent,
                              active: _activeMode == PriceMode.retailPercent,
                              onActivate: () => setState(() {
                                _activeMode = PriceMode.retailPercent;
                              }),
                            ),
                            const SizedBox(height: 14),

                            _priceField(
                              controller: _retailAbsoluteController,
                              label: "Retail Price (Absolute)",
                              icon: Icons.attach_money,
                              active: _activeMode == PriceMode.retailAbsolute,
                              onActivate: () => setState(() {
                                _activeMode = PriceMode.retailAbsolute;
                              }),
                            ),
                            const SizedBox(height: 14),
                          ],

                          // ================= WHOLESALE =================
                          if (showWholesale) ...[
                            _priceField(
                              controller: _wholesaleMarkupController,
                              label: "Wholesale Mark Up %",
                              icon: Icons.percent,
                              active: _activeMode == PriceMode.wholesalePercent,
                              onActivate: () => setState(() {
                                _activeMode = PriceMode.wholesalePercent;
                              }),
                            ),
                            const SizedBox(height: 14),

                            _priceField(
                              controller: _wholesaleAbsoluteController,
                              label: "Wholesale Price (Absolute)",
                              icon: Icons.attach_money,
                              active: _activeMode == PriceMode.wholesaleAbsolute,
                              onActivate: () => setState(() {
                                _activeMode = PriceMode.wholesaleAbsolute;
                              }),
                            ),
                            const SizedBox(height: 14),
                          ],

                          _buildField(_openingStockController, "Opening Stock", Icons.inventory, isNumber: true),
                          const SizedBox(height: 14),

                          DropdownButtonFormField<String>(
                            style: TextStyle(color: Colors.white70),
                            decoration: _buildDropdownDecoration("Product Type"),
                            value: _productType,
                            items: const [
                              DropdownMenuItem(value: "product", child: Text("Product")),
                              DropdownMenuItem(value: "service", child: Text("Service")),
                            ],
                            onChanged: (val) => setState(() => _productType = val),
                            validator: (val) => val == null ? "Please select a product type" : null,
                          ),
                          const SizedBox(height: 14),

                          DropdownButtonFormField<String>(
                            style: TextStyle(color: Colors.white70),
                            decoration: _buildDropdownDecoration("Pricing Mode"),
                            value: _pricingMode,
                            items: const [
                              DropdownMenuItem(value: "retail", child: Text("Retail")),
                              DropdownMenuItem(value: "wholesale", child: Text("Wholesale")),
                            ],
                            onChanged: (val) => setState(() => _pricingMode = val),
                            validator: (val) => val == null ? "Please select pricing mode" : null,
                          ),
                          const SizedBox(height: 14),

                          DropdownButtonFormField<String>(
                            style: TextStyle(color: Colors.white70),
                            decoration: _buildDropdownDecoration("Product Category"),
                            value: _productCategory,
                            items: const [
                              DropdownMenuItem(value: "category1", child: Text("Category 1")),
                              DropdownMenuItem(value: "category2", child: Text("Category 2")),
                            ],
                            onChanged: (val) => setState(() => _productCategory = val),
                            validator: (val) => val == null ? "Please select product category" : null,
                          ),
                          const SizedBox(height: 14),


                          Consumer<Datafeed>(
                            builder: (context, datafeed, _) {
                              if (datafeed.loadingWarehouses) {
                                return const Center(child: CircularProgressIndicator());
                              }

                              return DropdownButtonFormField<String>(
                                style: const TextStyle(color: Colors.white70),
                                decoration: _buildDropdownDecoration("Warehouse"),
                                value: _warehouse,
                                items: datafeed.warehouses.map((w) {
                                  return DropdownMenuItem<String>(
                                    value: w.name,
                                    child: Text(w.name),
                                  );
                                }).toList(),
                                onChanged: (val) => setState(() => _warehouse = val),
                                validator: (val) =>
                                val == null ? "Please select warehouse" : null,
                              );
                            },
                          ),
                          const SizedBox(height: 25),

                          SizedBox(
                            width: 200,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF415A77),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: _loading ? null : () async {
                                if (!_formKey.currentState!.validate()) return;

                                setState(() => _loading = true);
                                final staff = datafeed.staff;

                                try {
                                  if (widget.docId != null) {
                                    await _db.collection('items').doc(widget.docId).update({
                                      'name': _nameController.text.trim(),
                                      'barcode': _barcodeController.text.trim(),
                                      'costprice': _costController.text.trim(),

                                      'retailmarkup': _retailMarkupController.text.trim(),
                                      'retailabsolute': _retailAbsoluteController.text.trim(),

                                      'wholesalemarkup': _wholesaleMarkupController.text.trim(),
                                      'wholesaleabsolute': _wholesaleAbsoluteController.text.trim(),

                                      'retailprice': calcRetailPrice(),
                                      'wholesaleprice': calcWholesalePrice(),

                                      'openingstock': _openingStockController.text.trim(),
                                      'producttype': _productType,
                                      'pricingmode': _pricingMode,
                                      'productcategory': _productCategory,
                                      'warehouse': _warehouse,
                                      'updatedAt': DateTime.now(),
                                      'updatedBy': staff,
                                    });
                                  } else {
                                    final name =_nameController.text.trim();
                                    final id =
                                    '${datafeed.companyid}_${_warehouse}_${name}'
                                        .trim()
                                        .toLowerCase()
                                        .replaceAll(RegExp(r'[^a-z0-9 ]'), '')
                                        .replaceAll(RegExp(r'\s+'), '_');
                                    final model = ItemModel(
                                      id: id,
                                      no: id,
                                      name: _nameController.text.trim(),
                                      barcode: _barcodeController.text.trim(),
                                      costprice: _costController.text.trim(),

                                      retailmarkup: _retailMarkupController.text.trim(),
                                      wholesalemarkup: _wholesaleMarkupController.text.trim(),

                                      retailprice: calcRetailPrice(),
                                      wholesaleprice: calcWholesalePrice(),

                                      openingstock: _openingStockController.text.trim(),
                                      producttype: _productType!,
                                      pricingmode: _pricingMode!,
                                      productcategory: _productCategory!,
                                      warehouse: _warehouse!,
                                      company: datafeed.company,
                                      companyid: datafeed.companyid,
                                      createdAt: DateTime.now(),
                                      updatedAt: DateTime.now(),
                                      updatedBy: staff,
                                    );
                           await _db.collection('items').doc(id).set(model.toMap());

                                  }

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(widget.docId == null
                                          ? "Item Registered Successfully"
                                          : "Item Updated Successfully"),
                                    ),
                                  );

                                  Navigator.pop(context);
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(e.toString())),
                                  );
                                }

                                setState(() => _loading = false);
                              },
                              child: _loading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : Text(widget.docId == null ? "Register" : "Update",
                                  style: const TextStyle(color: Colors.white70)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ================= UI HELPERS =================

  Widget _priceField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool active,
    required VoidCallback onActivate,
  }) {
    return GestureDetector(
      onDoubleTap: onActivate,
      child: TextFormField(
        controller: controller,
        enabled: active,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: TextStyle(color: active ? Colors.white70 : Colors.white38),
        validator: (v) => active && (v == null || v.isEmpty) ? "Required" : null,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          prefixIcon: Icon(icon, color: Colors.white70),
          fillColor: const Color(0xFF22304A),
          filled: true,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: active ? Colors.white24 : Colors.white12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.blue),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildDropdownDecoration(String label) {
    return InputDecoration(

      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white24),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      fillColor: const Color(0xFF22304A),
      filled: true,
    );
  }

  TextFormField _buildField(
      TextEditingController controller,
      String label,
      IconData icon, {
        bool isNumber = false,
      }) {
    return TextFormField(
      controller: controller,
      keyboardType:
      isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      style: const TextStyle(color: Colors.white70),
      validator: (v) => v == null || v.isEmpty ? "Required" : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue),
        ),
        fillColor: const Color(0xFF22304A),
        filled: true,
      ),
    );
  }
}
