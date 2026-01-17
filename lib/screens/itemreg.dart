import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/itemregmodel.dart';
import '../providers/Datafeed.dart';
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
  final _retailMarkupController = TextEditingController();
  final _wholesaleMarkupController = TextEditingController();
  final _openingStockController = TextEditingController();

  String? _productType;
  String? _pricingMode;
  String? _productCategory;
  String? _warehouse;

  bool _loading = false;

  // ACTIVE FIELDS
  bool _isRetailActive = true;
  bool _isWholesaleActive = false;

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    if (widget.data != null) {
      final d = widget.data!;
      _nameController.text = d['name'] ?? '';
      _barcodeController.text = d['barcode'] ?? '';
      _costController.text = d['costprice'] ?? '';
      _retailMarkupController.text = d['retailmarkup'] ?? '';
      _wholesaleMarkupController.text = d['wholesalemarkup'] ?? '';
      _openingStockController.text = d['openingstock'] ?? '';
      _productType = d['producttype'];
      _pricingMode = d['pricingmode'];
      _productCategory = d['productcategory'];
      _warehouse = d['warehouse'];

      // Determine active field
      _isRetailActive = (_retailMarkupController.text.isNotEmpty || _wholesaleMarkupController.text.isEmpty);
      _isWholesaleActive = !_isRetailActive;
    }
  }

  // MARKUP CALCULATION LOGIC
  String calcRetailPrice() {
    double cost = double.tryParse(_costController.text) ?? 0;
    double markup = double.tryParse(_retailMarkupController.text) ?? 0;

    if (!_isRetailActive || markup == 0) return cost.toStringAsFixed(2);

    if (markup <= 100) return (cost + cost * markup / 100).toStringAsFixed(2);

    return (cost + markup).toStringAsFixed(2);
  }

  String calcWholesalePrice() {
    double cost = double.tryParse(_costController.text) ?? 0;
    double markup = double.tryParse(_wholesaleMarkupController.text) ?? 0;

    if (!_isWholesaleActive || markup == 0) return cost.toStringAsFixed(2);

    if (markup <= 100) return (cost + cost * markup / 100).toStringAsFixed(2);

    return (cost + markup).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final formWidth = screenWidth > 900 ? screenWidth * 0.6 : screenWidth * 0.95;

    return Consumer<Datafeed>(
      builder: (context, datafeed, child) {
        return Scaffold(
          backgroundColor: const Color(0xFF101624),
          appBar: AppBar(
            title: Text(widget.docId == null ? "Register Item" : "Edit Item"),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            child: Align(
              alignment: Alignment.topCenter,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 40),
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

                          // RETAIL MARKUP
                          GestureDetector(
                            onDoubleTap: () {
                              setState(() {
                                _isRetailActive = true;
                                _isWholesaleActive = false;
                              });
                            },
                            child: TextFormField(
                              controller: _retailMarkupController,
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                              style: TextStyle(
                                color: _isRetailActive ? Colors.white70 : Colors.white38,
                              ),
                              enabled: _isRetailActive,
                              validator: (v) => _isRetailActive && (v == null || v.isEmpty) ? "Required" : null,
                              decoration: InputDecoration(
                                labelText: "Retail Markup",
                                prefixIcon: const Icon(Icons.percent, color: Colors.white70),
                                fillColor: const Color(0xFF22304A),
                                filled: true,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: _isRetailActive ? Colors.white24 : Colors.white12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Colors.blue),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // WHOLESALE MARKUP
                          GestureDetector(
                            onDoubleTap: () {
                              setState(() {
                                _isRetailActive = false;
                                _isWholesaleActive = true;
                              });
                            },
                            child: TextFormField(
                              controller: _wholesaleMarkupController,
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                              style: TextStyle(
                                color: _isWholesaleActive ? Colors.white70 : Colors.white38,
                              ),
                              enabled: _isWholesaleActive,
                              validator: (v) => _isWholesaleActive && (v == null || v.isEmpty) ? "Required" : null,
                              decoration: InputDecoration(
                                labelText: "Wholesale Markup",
                                prefixIcon: const Icon(Icons.percent, color: Colors.white70),
                                fillColor: const Color(0xFF22304A),
                                filled: true,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: _isWholesaleActive ? Colors.white24 : Colors.white12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Colors.blue),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),

                          _buildField(_openingStockController, "Opening Stock", Icons.inventory, isNumber: true),
                          const SizedBox(height: 14),

                          // PRODUCT TYPE
                          DropdownButtonFormField<String>(
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

                          // PRICING MODE
                          DropdownButtonFormField<String>(
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

                          // PRODUCT CATEGORY
                          DropdownButtonFormField<String>(
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

                          // WAREHOUSE
                          DropdownButtonFormField<String>(
                            decoration: _buildDropdownDecoration("Warehouse"),
                            value: _warehouse,
                            items: const [
                              DropdownMenuItem(value: "warehouse1", child: Text("Warehouse 1")),
                              DropdownMenuItem(value: "warehouse2", child: Text("Warehouse 2")),
                            ],
                            onChanged: (val) => setState(() => _warehouse = val),
                            validator: (val) => val == null ? "Please select warehouse" : null,
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
                                    // EDIT MODE
                                    await _db.collection('items').doc(widget.docId).update({
                                      'name': _nameController.text.trim(),
                                      'barcode': _barcodeController.text.trim(),
                                      'costprice': _costController.text.trim(),
                                      'retailmarkup': _retailMarkupController.text.trim(),
                                      'wholesalemarkup': _wholesaleMarkupController.text.trim(),
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
                                    // NEW ITEM
                                    await _db.runTransaction((tx) async {
                                      final counterRef = _db.collection('counters').doc('item_ids');
                                      final counterSnap = await tx.get(counterRef);
                                      int last = counterSnap.exists ? (counterSnap['last'] ?? 0) : 0;
                                      final next = last + 1;
                                      tx.set(counterRef, {'last': next});
                                      final newNo = "KS00$next";

                                      final model = ItemModel(
                                        id: newNo,
                                        no: newNo,
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

                                      tx.set(_db.collection('items').doc(newNo), model.toMap());
                                    });
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
        borderSide: const BorderSide(color: Colors.blue),
      ),
      fillColor: const Color(0xFF22304A),
      filled: true,
    );
  }

  TextFormField _buildField(TextEditingController controller, String label, IconData icon,
      {bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
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
