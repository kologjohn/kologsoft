import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kologsoft/providers/Datafeed.dart';
import 'package:pdf/pdf.dart';
import 'package:provider/provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class NewStock extends StatefulWidget {
  final String? docId;
  final Map<String, dynamic>? data;
  const NewStock({super.key,this.docId, this.data});

  @override
  State<NewStock> createState() => _NewStockState();
}

class _NewStockState extends State<NewStock> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _invoicenumberController = TextEditingController();
  final TextEditingController _waybillController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  String? _selectedPurchaseType;
  String? _selectedpaymentaccount;
  bool _loading=false;
  DateTime? _selectedDate;

  late List<String> _purchasTypes = ['Cash', 'Credit','Opening Stock'];
  late List<String> paymentaccount = ['Cash Account', 'Bank Account', 'Mobile Money'];

  bool get isCashPurchase => _selectedPurchaseType == 'Cash';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider= Provider.of<Datafeed>(context, listen: false);
      provider.fetchBranches();
      provider.fetchSuppliers();
      if (widget.data != null)
      {
        final customadata = widget.data!;
        final branchId = customadata['branchId'];
        if (branchId != null && branchId.isNotEmpty) { provider.selectBranch(branchId); }
      }
    });
    if (widget.data != null) {
      final customadata = widget.data!;
      _invoicenumberController.text = customadata['name'] ?? '';
      _contactController.text = customadata['contact'] ?? '';
      final customerType = customadata['customertype'];
      if (_purchasTypes.contains(customerType)) { _selectedPurchaseType = customerType; }
      final paymentDuration = customadata['paymentduration'];
      if (paymentaccount.contains(paymentDuration)) { _selectedpaymentaccount = paymentDuration; }
    }
  }

  @override
  void dispose() {
    _invoicenumberController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Datafeed>(
        builder: (BuildContext context, Datafeed value, Widget? child){
          return Scaffold(
            backgroundColor: const Color(0xFF101A23),
            appBar: AppBar(
              title: Text(widget.docId != null ? "EDIT STOCK ENTRY" : "NEW STOCK ENTRY"),
              backgroundColor: const Color(0xFF0D1A26),
              foregroundColor: Colors.white,
              elevation: 2,
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                      maxWidth: 700
                  ),
                  child: Form(
                      key: _formKey,
                      child: ListView(
                        children: [
                          Card(
                            color: const Color(0xFF182232),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 16.0, top: 20, right: 16, bottom: 20),
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: _invoicenumberController,
                                    style: TextStyle(color: Colors.white),
                                    decoration: InputDecoration(
                                      labelText: 'Invoice Number',
                                      labelStyle: const TextStyle(
                                        color: Colors.white70,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: Colors.white24,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: Colors.blue,
                                        ),
                                      ),
                                      fillColor: const Color(0xFF22304A),
                                      filled: true,
                                    ),

                                  ),
                                  SizedBox(height: 14),
                                  TextFormField(
                                    controller: _waybillController,
                                    style: TextStyle(color: Colors.white),
                                    decoration: InputDecoration(
                                      labelText: 'Waybill Number',
                                      labelStyle: const TextStyle(
                                        color: Colors.white70,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: Colors.white24,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: Colors.blue,
                                        ),
                                      ),
                                      fillColor: const Color(0xFF22304A),
                                      filled: true,
                                    ),

                                  ),
                                  SizedBox(height: 14),
                                  DropdownButtonFormField<String>(
                                    value: value.selectedSupplier?.id, // must be one of branch.id
                                    dropdownColor: const Color(0xFF22304A),
                                    style: const TextStyle(color: Colors.white),
                                    decoration: InputDecoration(
                                      labelText: 'Supplier',
                                      labelStyle: const TextStyle(color: Colors.white70),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
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
                                    items: value.suppliers.map((suplier) {
                                      return DropdownMenuItem<String>(
                                        value: suplier.id,
                                        child: Text(suplier.supplier),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      if (val != null) {
                                        value.selectSupplier(val); // call provider method
                                      }
                                    },
                                    validator: (val) =>
                                    val == null ? 'Please select Supplier' : null,
                                  ),
                                  const SizedBox(height: 14),
                                  DropdownButtonFormField<String>(
                                    value: _selectedPurchaseType,
                                    dropdownColor: const Color(0xFF22304A),
                                    style: const TextStyle(color: Colors.white),
                                    decoration: InputDecoration(
                                      labelText: 'Purchase Mode',
                                      labelStyle: const TextStyle(color: Colors.white70),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
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
                                    items: _purchasTypes.map((type) {
                                      return DropdownMenuItem<String>(
                                        value: type,
                                        child: Text(type),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedPurchaseType = value;
                                        if (value != 'Credit') {
                                          _selectedpaymentaccount = null;
                                        }
                                      });
                                    },
                                    validator: (value) =>
                                    value == null ? 'Please select customer type' : null,
                                  ),
                                  SizedBox(height: 14),
                                  if (isCashPurchase) ...[
                                    DropdownButtonFormField<String>(
                                      value: _selectedpaymentaccount,
                                      dropdownColor: const Color(0xFF22304A),
                                      style: const TextStyle(color: Colors.white),
                                      decoration: InputDecoration(
                                        labelText: 'Payment Account',
                                        labelStyle: const TextStyle(color: Colors.white70),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
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
                                      items: paymentaccount.map((type) {
                                        return DropdownMenuItem<String>(
                                          value: type,
                                          child: Text(type),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() => _selectedpaymentaccount = value);
                                      },
                                      validator: (value) {
                                        if (!isCashPurchase) return null;
                                        return value == null ? 'Please select payment duration' : null;
                                      },
                                    ),
                                  ],
                                  SizedBox(height: 14),
                                  DropdownButtonFormField<String>(
                                    value: value.selectedBranch?.id, // must be one of branch.id
                                    dropdownColor: const Color(0xFF22304A),
                                    style: const TextStyle(color: Colors.white),
                                    decoration: InputDecoration(
                                      labelText: 'Branch',
                                      labelStyle: const TextStyle(color: Colors.white70),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
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
                                    items: value.branches.map((branch) {
                                      return DropdownMenuItem<String>(
                                        value: branch.id,
                                        child: Text(branch.branchname),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      if (val != null) {
                                        value.selectBranch(val); // call provider method
                                      }
                                    },
                                    validator: (val) =>
                                    val == null ? 'Please select branch' : null,
                                  ),
                                  const SizedBox(height: 14),
                                  TextFormField(
                                    controller: _dateController,
                                    readOnly: true,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: InputDecoration(
                                      labelText: 'Date',
                                      labelStyle: const TextStyle(color: Colors.white70),
                                      hintText: 'yyyy-mm-dd',
                                      hintStyle: const TextStyle(color: Colors.white54),
                                      suffixIcon: const Icon(
                                        Icons.calendar_today,
                                        color: Colors.white70,
                                        size: 18,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
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
                                    onTap: () async {
                                      DateTime? picked = await showDatePicker(
                                        context: context,
                                        initialDate: _selectedDate ?? DateTime.now(),
                                        firstDate: DateTime(2020),
                                        lastDate: DateTime(2100),
                                        builder: (context, child) {

                                          return Theme(
                                            data: Theme.of(context).copyWith(
                                              colorScheme: const ColorScheme.dark(
                                                primary: Colors.blue,
                                                onPrimary: Colors.white,
                                                surface: Color(0xFF22304A),
                                                onSurface: Colors.white,
                                              ),
                                            ),
                                            child: child!,
                                          );
                                        },
                                      );

                                      if (picked != null) {
                                        setState(() {
                                          _selectedDate = picked;
                                          _dateController.text =
                                          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                                        });
                                      }
                                    },
                                    validator: (value) =>
                                    value == null || value.isEmpty ? 'Select date' : null,
                                  ),
                                  const SizedBox(height: 14),
                                  Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    children: [
                                      // Save button

                                      SizedBox(
                                        width: 200,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF415A77),
                                            padding:
                                            const EdgeInsets.symmetric(vertical: 14),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                          onPressed: _loading
                                              ? null
                                              : () async {
                                            if (!_formKey.currentState!.validate())
                                              return;

                                            setState(() => _loading = true);
                                            String invoicenumber= _invoicenumberController.text.trim();
                                            String waybillnumber= _waybillController.text.trim();
                                            String purchasetype= _selectedPurchaseType!;
                                            DateTime? invoicedate = _selectedDate;
                                            final branchId = value.selectedBranch?.id ?? '';
                                            final branchName = value.selectedBranch?.branchname ?? '';
                                            final docid = value.normalizeAndSanitize("${value.companyid}${DateTime.now().millisecondsSinceEpoch}${branchId}");

                                            final headerData = {
                                              'invoice': invoicenumber,
                                              'invoicedate': invoicedate,
                                              'waybill': waybillnumber,
                                              'supplierid': value.selectedSupplier?.id ?? '',
                                              'suppliername': value.selectedSupplier?.supplier ?? '',
                                              'branchid': branchId,
                                              'branchname': branchName,
                                              'purchasetype': purchasetype!,
                                              'docid': docid,
                                              'createdat': DateTime.now(),
                                              'createdby': value.staff,
                                              'editedby': "",
                                              'editedat': "",
                                              'deletedby': "",
                                              'deletedat': "",
                                              'companyid': value.companyid,
                                              'company': value.company,
                                            };

                                            try {

                                              if (widget.docId != null) {
                                                final id = widget.docId!;


                                              }

                                              else {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) => StockItemsForm(
                                                      transactionId: docid,
                                                      headerData: headerData,
                                                    ),
                                                  ),
                                                );


                                              }

                                            } catch (e) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text(e.toString())),
                                              );
                                            }

                                            if (!mounted) return;
                                            // ✅ check before UI updates
                                            setState(() { _loading = false;
                                            _selectedPurchaseType = null;
                                            });
                                          },
                                          child: _loading
                                              ? const CircularProgressIndicator(
                                              color: Colors.white)
                                              : Text(
                                            widget.docId == null
                                                ? "Proceed"
                                                : "Update",
                                            style: const TextStyle(
                                                color: Colors.white70),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      )
                  ),
                ),
              ),
            ),
          );
        }
    );
  }
}



class StockItemsForm extends StatefulWidget {
  final String transactionId;
  final Map<String, dynamic> headerData;

  const StockItemsForm({super.key, required this.transactionId, required this.headerData});

  @override
  State<StockItemsForm> createState() => _StockItemsFormState();
}

class _StockItemsFormState extends State<StockItemsForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _barcodeController = TextEditingController();
  final TextEditingController _itemController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _taxValueController = TextEditingController();

  String? _selectedStockMode;
  List<String> _stockMode = [];
  String? _selectedPriceMode;
  String? _selectedTaxType;
  final List<String> _taxType = ['No vat','Flat', 'standard'];
  Map<String, dynamic>? _itemModes;
  bool _loading=false;
  List<Map<String, dynamic>> _suggestions = [];
  bool _showSuggestions = false;
  Map<String, dynamic>? _selectedItem;
  String _searchQuery = '';

  final List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    _barcodeController.addListener(_onBarcodeChanged);
    _selectedTaxType = _taxType.first;
    _taxValueController.text = '0';
    _discountController.text = '0';
  }

  @override
  void dispose() {
    _barcodeController.removeListener(_onBarcodeChanged);
    _barcodeController.dispose();
    _itemController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _discountController.dispose();
    _taxValueController.dispose();
    super.dispose();
  }

  void _onBarcodeChanged() {
    setState(() {
      _searchQuery = _barcodeController.text.trim();
      _showSuggestions = _searchQuery.isNotEmpty;
    });
  }

  void _selectItem(Map<String, dynamic> item) {
    setState(() {
      _selectedItem = item;
      _barcodeController.text = item['barcode'] ?? '';
      _itemController.text = item['name'] ?? '';

      // Extract modes from item
      _itemModes = item['modes'] as Map<String, dynamic>?;

      if (_itemModes != null && _itemModes!.isNotEmpty) {
        // Populate sales mode dropdown with available modes
        _stockMode = _itemModes!.keys.map((key) {
          final modeData = _itemModes![key] as Map<String, dynamic>?;
          return modeData?['name'] as String? ?? key;
        }).toList();

        // Set the first mode as default
        if (_stockMode.isNotEmpty) {
          _selectedStockMode = _stockMode.first;
        }
      } else {
        // Fallback to default modes if item doesn't have modes
        _stockMode = ['Single', 'Box'];
        _selectedStockMode = null;
      }

      // Update price based on selected mode
      _updatePrice();

      _showSuggestions = false;
      _suggestions = [];
    });
  }

  void _updatePrice() {
    if (_itemModes == null || _selectedStockMode == null) {
      _priceController.text = '0';
      return;
    }

    // Find the mode data by matching the name
    Map<String, dynamic>? selectedModeData;
    for (var entry in _itemModes!.entries) {
      final modeData = entry.value as Map<String, dynamic>?;
      if (modeData?['name'] == _selectedStockMode) {
        selectedModeData = modeData;
        break;
      }
    }

    if (selectedModeData != null) {
      // Set price based on retail/wholesale selection
      String price = '0';
      if (_selectedPriceMode == 'Retail') {
        price = selectedModeData['rp']?.toString() ?? selectedModeData['retailprice']?.toString() ?? '0';
      } else if (_selectedPriceMode == 'Wholesale') {
        price = selectedModeData['wp']?.toString() ?? selectedModeData['wholesaleprice']?.toString() ?? '0';
      } else {
        // Default to retail price
        price = selectedModeData['rp']?.toString() ?? selectedModeData['retailprice']?.toString() ?? '0';
      }

      _priceController.text = price;
    }
  }

  void _addItem() {
    if (_formKey.currentState!.validate()) {

      setState(() {
        final double quantity = double.tryParse(_quantityController.text.trim()) ?? 0;
        final double price = double.tryParse(_priceController.text.trim())?.toDouble() ?? 0.0;
        final double discount = double.tryParse(_discountController.text.trim())?.toDouble() ?? 0.0;
        final double taxValue = double.tryParse(_taxValueController.text.trim())?.toDouble() ?? 0.0;

        // Determine mode quantity (pieces per selected mode) - default to 1 when missing
        double modeQty = 1;
        if (_itemModes != null && _selectedStockMode != null) {
          Map<String, dynamic>? selectedModeData;
          for (var entry in _itemModes!.entries) {
            final modeData = entry.value as Map<String, dynamic>?;
            if (modeData?['name'] == _selectedStockMode) {
              selectedModeData = modeData;
              break;
            }
          }
          if (selectedModeData != null) {
            // try several common keys for quantity-per-mode
            final dynamic qVal = selectedModeData['qty'] ?? 1;
            modeQty = (double.tryParse(qVal.toString()) ??
                (qVal is double ? qVal.toDouble() : 1.0));

          }
        }

        // pieces = modeQty * entered quantity
        final double pieces = modeQty * quantity;

        // compute line amounts
        final double baseAmount = price * quantity;
        double taxAmount = 0.0;
        if (_selectedTaxType == 'No vat') {
          taxAmount = 0.0;
        } else if (_selectedTaxType == 'Flat') {
          taxAmount = taxValue;
        } else {
          // 'standard' as percentage
          final taxableBase = (baseAmount - discount).clamp(0.0, double.infinity);
          taxAmount = taxableBase * (taxValue / 100.0);
        }
        final double total = (baseAmount - discount) + taxAmount;

        _items.add({
          'item': _itemController.text.trim(),
          'quantity': quantity,
          'price': price,
          'discount': discount,
          'taxtype': _selectedTaxType ?? '',
          'taxvalue': taxValue,
          'taxamount': taxAmount,
          'total': total,
          'stockingmode': _selectedStockMode ?? '',
          'modeqty': modeQty,
          'pieces': pieces,
          'barcode': _barcodeController.text.trim(),
          'itemid': _selectedItem != null ? _selectedItem!['id'] ?? '' : '',
        });

        // Clear item and quantity for next entry (keeping price/mode/tax if desired)
        _itemController.clear();
        _quantityController.clear();
        _discountController.text = '0';
        _taxValueController.text = '0';
        _barcodeController.clear();
        _priceController.clear();
      });
    }
  }


  ({double gross, double discount, double tax, double net}) _calculateTotals() {
    double baseTotal = 0.0;
    double discountTotal = 0.0;
    double taxTotal = 0.0;

    for (final it in _items) {
      final double price = (it['price'] as num?)?.toDouble() ?? 0.0;
      final double qty = (it['quantity'] as double?) ?? 0;
      final double discount = (it['discount'] as num?)?.toDouble() ?? 0.0;
      final double taxAmt = (it['taxAmount'] as num?)?.toDouble() ?? 0.0;

      baseTotal += price * qty;
      discountTotal += discount;
      taxTotal += taxAmt;
    }

    final double payable = baseTotal - discountTotal + taxTotal;

    return (
    gross: baseTotal,
    discount: discountTotal,
    tax: taxTotal,
    net: payable,
    );
  }


  bool _saved = false;
  Future<void> _saveRecords() async {
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No items to save')),
      );
      return;
    }

    final totals = _calculateTotals();

    final Map<String, dynamic> docData = {
      ...widget.headerData,
      'transactionId': widget.transactionId,
      'items': _items,
      'gross': totals.gross,
      'discount': totals.discount,
      'tax': totals.tax,
      'netval': totals.net,
    };

    try {
      await FirebaseFirestore.instance
          .collection('stock_transactions')
          .doc(widget.transactionId)
          .set(docData);

      if (!mounted) return;
  setState(() {
  _saved = true; // disable add & save, show print
  });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Records saved')),
      );

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Save failed: $e')),
      );
    }
    //Navigator.of(context).pop();
  }

  Future<void> _printRecords() async {
    final pdf = pw.Document();
    final totals = _calculateTotals();

    String fmtNum(dynamic v) {
      if (v == null || v.toString().isEmpty) return '-';
      if (v is int) return v.toString();
      if (v is double || v is num) return (v as num).toStringAsFixed(2);
      return v.toString();
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return <pw.Widget>[
            // Company name
            pw.Center(
              child: pw.Text(
                widget.headerData['company'] ?? 'COMPANY NAME',
                style: pw.TextStyle(fontSize: 26, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.SizedBox(height: 10),

            // Title
            pw.Center(
              child: pw.Text(
                'STOCK TRANSACTION',
                style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
              ),
            ),

            // new thin divider between title and headerdata
            pw.SizedBox(height: 8),
            pw.Container(height: 1, color: PdfColors.grey300),
            pw.SizedBox(height: 12),

            // Header section (no border)
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Invoice Number: ${widget.headerData['invoice'] ?? ''}', style: pw.TextStyle(fontSize: 14)),
                      pw.Text('Waybill Number: ${widget.headerData['waybill'] ?? ''}', style: pw.TextStyle(fontSize: 14)),
                      pw.Text('Staff: ${widget.headerData['createdby'] ?? ''}', style: pw.TextStyle(fontSize: 14)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Supplier: ${widget.headerData['suppliername'] ?? ''}', style: pw.TextStyle(fontSize: 14)),
                      pw.Text('Branch: ${widget.headerData['branchname'] ?? ''}', style: pw.TextStyle(fontSize: 14)),
                      pw.Text('Date: ${widget.headerData['invoicedate'] ?? ''}', style: pw.TextStyle(fontSize: 14)),
                    ],
                  ),
                ],
              ),
            ),

            // thin divider between header and table
            pw.SizedBox(height: 12),
            pw.Container(height: 1, color: PdfColors.grey300),
            pw.SizedBox(height: 12),

            // Manual table - borders enabled only here
            pw.Table(
              border: pw.TableBorder.all(width: 0.5, color: PdfColors.grey300),
              columnWidths: {
                0: const pw.FixedColumnWidth(24),   // #
                1: const pw.FlexColumnWidth(3.0),   // Item
                2: const pw.FlexColumnWidth(1.2),   // Mode
                3: const pw.FlexColumnWidth(0.9),   // Mode Qty (num)
                4: const pw.FlexColumnWidth(0.9),   // Pieces (num)
                5: const pw.FlexColumnWidth(0.9),   // Qty (num)
                6: const pw.FlexColumnWidth(1.2),   // Unit Price (num)
                7: const pw.FlexColumnWidth(1.2),   // Discount (num)
                8: const pw.FlexColumnWidth(1.4),   // Total (num)
              },
              children: [
                // header row
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('#', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold))),
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Item', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold))),
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Mode', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold))),
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Mode Qty', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right)),
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Pieces', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right)),
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Qty', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right)),
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Unit Price', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right)),
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Discount', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right)),
                    pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Total', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right)),
                  ],
                ),

                // data rows
                ..._items.asMap().entries.map((entry) {
                  final idx = entry.key + 1;
                  final it = entry.value;
                  final bool even = entry.key % 2 == 0;
                  return pw.TableRow(
                    decoration: pw.BoxDecoration(color: even ? PdfColors.white : PdfColors.grey100),
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(idx.toString(), style: pw.TextStyle(fontSize: 10))),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(it['item']?.toString() ?? '-', style: pw.TextStyle(fontSize: 10))),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(it['stockingmode']?.toString() ?? it['salesMode']?.toString() ?? '-', style: pw.TextStyle(fontSize: 10))),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(fmtNum(it['modeqty'] ?? it['modeQty'] ?? ''), style: pw.TextStyle(fontSize: 10), textAlign: pw.TextAlign.right)),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(fmtNum(it['pieces'] ?? ''), style: pw.TextStyle(fontSize: 10), textAlign: pw.TextAlign.right)),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(fmtNum(it['quantity'] ?? ''), style: pw.TextStyle(fontSize: 10), textAlign: pw.TextAlign.right)),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(fmtNum(it['price'] ?? ''), style: pw.TextStyle(fontSize: 10), textAlign: pw.TextAlign.right)),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(fmtNum(it['discount'] ?? ''), style: pw.TextStyle(fontSize: 10), textAlign: pw.TextAlign.right)),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(fmtNum(it['total'] ?? ''), style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right)),
                    ],
                  );
                }).toList(),
              ],
            ),

            pw.SizedBox(height: 20),

            // Totals - right aligned, no border
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Container(
                  width: 260,
                  padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                    children: [
                      pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                        pw.Text('Gross:', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                        pw.Text(fmtNum(totals.gross), style: pw.TextStyle(fontSize: 10), textAlign: pw.TextAlign.right),
                      ]),
                      pw.SizedBox(height: 6),
                      pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                        pw.Text('Discount:', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                        pw.Text(fmtNum(totals.discount), style: pw.TextStyle(fontSize: 10), textAlign: pw.TextAlign.right),
                      ]),
                      pw.SizedBox(height: 6),
                      pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                        pw.Text('Tax:', style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                        pw.Text(fmtNum(totals.tax), style: pw.TextStyle(fontSize: 10), textAlign: pw.TextAlign.right),
                      ]),
                      pw.Divider(),
                      pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                        pw.Text('Net:', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                        pw.Text(fmtNum(totals.net), style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right),
                      ]),
                    ],
                  ),
                ),
              ],
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101624),
      appBar: AppBar(
        title: const Text(
          "STOCK TRANSACTIONS",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1B263B),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 8.0,
            top: 20,
            right: 8,
            bottom: 20,
          ),
          child: Column(
            children: [
              Center(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isSmallScreen = constraints.maxWidth < 900;
                    final double itemWidth = isSmallScreen
                        ? constraints.maxWidth
                        : (constraints.maxWidth / 2) - 24;
                    return Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        SizedBox(
                          width: itemWidth,
                          child: Container(
                            color: const Color(0xFF182232),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "STOCK ENTRIES",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const Divider(color: Colors.white24),
                                  const SizedBox(height: 15),
                                  Form(
                                    key: _formKey,
                                    child: Column(
                                      children: [
                                        TextFormField(
                                          controller: _barcodeController,
                                          style: const TextStyle(color: Colors.white),
                                          decoration: InputDecoration(
                                            labelText: 'Barcode',
                                            labelStyle: const TextStyle(
                                              color: Colors.white70,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12),
                                              borderSide: const BorderSide(
                                                color: Colors.white24,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12),
                                              borderSide: const BorderSide(
                                                color: Colors.blue,
                                              ),
                                            ),
                                            fillColor: const Color(0xFF22304A),
                                            filled: true,
                                          ),
                                          validator: (value) =>
                                          value == null || value.isEmpty
                                              ? 'Barcode required'
                                              : null,
                                        ),
                                        if (_showSuggestions)
                                          StreamBuilder<QuerySnapshot>(
                                            stream: FirebaseFirestore.instance
                                                .collection('itemsreg')
                                                .snapshots(),
                                            builder: (context, snapshot) {
                                              if (!snapshot.hasData) {
                                                return Container(
                                                  margin: const EdgeInsets.only(top: 4),
                                                  padding: const EdgeInsets.all(16),
                                                  child: const Center(
                                                    child: CircularProgressIndicator(
                                                      color: Colors.blue,
                                                      strokeWidth: 2,
                                                    ),
                                                  ),
                                                );
                                              }

                                              final allDocs = snapshot.data!.docs;
                                              final filteredDocs = allDocs.where((doc) {
                                                final data = doc.data() as Map<String, dynamic>;
                                                final name = (data['name'] ?? '').toString().toLowerCase();
                                                final barcode = (data['barcode'] ?? '').toString().toLowerCase();
                                                final query = _searchQuery.toLowerCase();
                                                return name.contains(query) || barcode.contains(query);
                                              }).take(10).toList();

                                              if (filteredDocs.isEmpty) return const SizedBox.shrink();

                                              return Container(
                                                margin: const EdgeInsets.only(top: 4),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFF22304A),
                                                  borderRadius: BorderRadius.circular(8),
                                                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                                                  boxShadow: const [
                                                    BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
                                                  ],
                                                ),
                                                constraints: const BoxConstraints(maxHeight: 250),
                                                child: ListView.builder(
                                                  shrinkWrap: true,
                                                  itemCount: filteredDocs.length,
                                                  itemBuilder: (context, index) {
                                                    final doc = filteredDocs[index];
                                                    final item = doc.data() as Map<String, dynamic>;
                                                    item['id'] = doc.id;

                                                    return ListTile(
                                                      dense: true,
                                                      leading: const Icon(Icons.inventory_2, color: Colors.blue, size: 20),
                                                      title: Text(
                                                        item['name'] ?? '',
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 14,
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                      ),
                                                      subtitle: Text(
                                                        'Barcode: ${item['barcode']} | Retail: GHS ${item['retailprice']} | Stock: ${item['openingstock']}',
                                                        style: const TextStyle(color: Colors.white70, fontSize: 11),
                                                      ),
                                                      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 14),
                                                      onTap: () => _selectItem(item),
                                                    );
                                                  },
                                                ),
                                              );
                                            },
                                          ),
                                        const SizedBox(height: 10),
                                        TextFormField(
                                          controller: _itemController,
                                          style: const TextStyle(color: Colors.white),
                                          decoration: InputDecoration(
                                            labelText: 'Item',
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
                                          ),
                                          validator: (value) => value == null || value.isEmpty ? 'Item required' : null,
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: DropdownButtonFormField<String>(
                                                value: _selectedStockMode,
                                                dropdownColor: const Color(
                                                  0xFF22304A,
                                                ),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                ),
                                                decoration: InputDecoration(
                                                  labelText: 'Stocking  Mode',
                                                  labelStyle: const TextStyle(
                                                    color: Colors.white70,
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                      12,
                                                    ),
                                                  ),
                                                  enabledBorder:
                                                  OutlineInputBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                      12,
                                                    ),
                                                    borderSide:
                                                    const BorderSide(
                                                      color: Colors
                                                          .white24,
                                                    ),
                                                  ),
                                                  focusedBorder:
                                                  OutlineInputBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                      12,
                                                    ),
                                                    borderSide:
                                                    const BorderSide(
                                                      color:
                                                      Colors.blue,
                                                    ),
                                                  ),
                                                  fillColor: const Color(
                                                    0xFF22304A,
                                                  ),
                                                  filled: true,
                                                ),
                                                items: _stockMode.isEmpty ? null : _stockMode.map((type) {
                                                  return DropdownMenuItem<String>(value: type, child: Text(type));
                                                }).toList(),
                                                onChanged: (value) {
                                                  setState(() {
                                                    _selectedStockMode = value;
                                                    _updatePrice();
                                                  });
                                                },
                                                validator: (value) =>
                                                value == null
                                                    ? 'Please select stocking mode'
                                                    : null,
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            Expanded(
                                              child: TextFormField(
                                                controller: _priceController,
                                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                                inputFormatters:
                                                [
                                                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                                                ],
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                                decoration: InputDecoration(
                                                  labelText: 'Price',
                                                  labelStyle: const TextStyle(
                                                    color: Colors.white70,
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                      12,
                                                    ),
                                                  ),
                                                  enabledBorder:
                                                  OutlineInputBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                      12,
                                                    ),
                                                    borderSide:
                                                    const BorderSide(
                                                      color: Colors
                                                          .white24,
                                                    ),
                                                  ),
                                                  focusedBorder:
                                                  OutlineInputBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                      12,
                                                    ),
                                                    borderSide:
                                                    const BorderSide(
                                                      color:
                                                      Colors.blue,
                                                    ),
                                                  ),
                                                  fillColor: const Color(
                                                    0xFF22304A,
                                                  ),
                                                  filled: true,
                                                ),
                                                validator: (value) =>
                                                value == null ||
                                                    value.isEmpty
                                                    ? 'Enter amount'
                                                    : null,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        TextFormField(
                                          controller: _quantityController,
                                          style: const TextStyle(color: Colors.white),
                                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                          inputFormatters:
                                          [
                                            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                                          ],
                                          decoration: InputDecoration(
                                            labelText: 'Quantity',
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
                                          ),
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Enter quantity';
                                            }
                                            final qty = double.tryParse(value);
                                            if (qty == null) {
                                              return 'Quantity must be a number';
                                            }
                                            if (qty <= 0) {
                                              return 'Quantity must be greater than 0';
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 10),
                                        DropdownButtonFormField<String>(
                                          value: _selectedTaxType,
                                          dropdownColor: const Color(0xFF22304A),
                                          style: const TextStyle(color: Colors.white),
                                          decoration: InputDecoration(
                                            labelText: 'Tax Type',
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
                                          ),
                                          items: _taxType.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                                          onChanged: (val) => setState(() => _selectedTaxType = val),
                                        ),
                                        const SizedBox(height: 10),
                                        TextFormField(
                                          controller: _discountController,
                                          style: const TextStyle(color: Colors.white),
                                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                          inputFormatters:
                                          [
                                            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                                          ],
                                          decoration: InputDecoration(
                                            labelText: 'Purchase Discount',
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
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        const Divider(color: Colors.white24),
                                        Wrap(
                                          spacing: 10,
                                          runSpacing: 10,
                                          children: [
                                            if (!_saved)
                                              SizedBox(
                                                width: 150,
                                                child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.orangeAccent,
                                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                  ),
                                                  onPressed: _loading ? null : _addItem,
                                                  child: const Text(
                                                    "Add Record",
                                                    style: TextStyle(color: Colors.white),
                                                  ),
                                                ),
                                              ),
                                            SizedBox(
                                              width: 150,
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.lightBlue,
                                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    _itemController.clear();
                                                    _priceController.clear();
                                                    _quantityController.clear();
                                                    _discountController.text = '0';
                                                    _taxValueController.text = '0';
                                                    _barcodeController.clear();
                                                  });
                                                },
                                                child: const Text("Reset", style: TextStyle(color: Colors.white)),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 150,
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.teal,
                                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                ),
                                                onPressed: () => Navigator.of(context).pop(),
                                                child: const Text("New Transaction", style: TextStyle(color: Colors.white)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: itemWidth,
                          child: Container(
                            color: const Color(0xFF182232),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "STOCK PREVIEW",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const Divider(color: Colors.white24),
                                  const SizedBox(height: 15),
                                  Table(
                                    border: TableBorder.all(color: Colors.grey),
                                    columnWidths: const {
                                      0: FixedColumnWidth(40),
                                      1: FlexColumnWidth(2),
                                      2: FlexColumnWidth(1),
                                      3: FlexColumnWidth(1),
                                      4: FlexColumnWidth(1),
                                      5: FlexColumnWidth(1),
                                     // 6: FlexColumnWidth(1),
                                      7: FlexColumnWidth(1),
                                      8: FlexColumnWidth(1), // extra column for delete
                                    },
                                    children: [
                                      _tableRow([
                                        "#",
                                        "Item",
                                        "Mode",
                                        "Qty",
                                        "Pieces",
                                        "Unit Price",
                                        "Discount",
                                        //"Tax",
                                        "Total",
                                        "Action"
                                      ], isHeader: true),
                                      ..._items.asMap().entries.map((entry) {
                                        final idx = entry.key;
                                        final item = entry.value;
                                        final priceText = (item['price'] != null)
                                            ? (item['price'] as double).toStringAsFixed(2)
                                            : '0.00';
                                        final totalText = (item['total'] != null)
                                            ? (item['total'] as double).toStringAsFixed(2)
                                            : '0.00';
                                        final discountText = (item['discount'] != null)
                                            ? (item['discount'] as double).toStringAsFixed(2)
                                            : '0.00';
                                        // final taxText = (item['taxamount'] != null)
                                        //     ? (item['taxamount'] as double).toStringAsFixed(2)
                                        //     : '0.00';

                                        return TableRow(
                                          children: [
                                            _cell((idx + 1).toString()),
                                            _cell(item['item']?.toString() ?? ''),
                                            _cell(item['stockingmode']?.toString() ?? ''),
                                            _cell(item['quantity']?.toString() ?? '0', alignRight: true),
                                            _cell(item['pieces']?.toString() ?? '0', alignRight: true),
                                            _cell(priceText, alignRight: true),
                                            _cell(discountText, alignRight: true),
                                           // _cell(taxText, alignRight: true),
                                            _cell(totalText, alignRight: true),
                                            _saved
                                                ? const Padding(
                                              padding: EdgeInsets.all(4.0),
                                              child: Icon(Icons.check_circle, color: Colors.green, size: 20),
                                            )
                                                : Padding(
                                              padding: const EdgeInsets.all(4.0),
                                              child: IconButton(
                                                icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                                                onPressed: () async {
                                                  final confirm = await showDialog<bool>(
                                                    context: context,
                                                    builder: (ctx) => AlertDialog(
                                                      title: const Text("Confirm Delete"),
                                                      content: const Text("Are you sure you want to delete this item?"),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () => Navigator.of(ctx).pop(false),
                                                          child: const Text("Cancel"),
                                                        ),
                                                        ElevatedButton(
                                                          onPressed: () => Navigator.of(ctx).pop(true),
                                                          child: const Text("Delete"),
                                                        ),
                                                      ],
                                                    ),
                                                  );

                                                  if (confirm == true) {
                                                    setState(() {
                                                      _items.removeAt(idx);
                                                    });
                                                  }
                                                },
                                              ),
                                            )

                                          ],
                                        );
                                      }).toList(),
                                      (() {
                                        return _tableRow(["", "", "", "", "", "", "", "", "",]);
                                      })(),
                                      (() {
                                        final totals = _calculateTotals();
                                        return _tableRow([
                                          "",
                                          "Grand Total",
                                          "",
                                          "",
                                          "",
                                          "",
                                          totals.discount!.toStringAsFixed(2),
                                          //totals.tax!.toStringAsFixed(2),
                                          totals.net!.toStringAsFixed(2),
                                          ""
                                        ]);
                                      })(),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                    Center(
                    child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!_saved)
                    SizedBox(
                    width: 150,
                    child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    ),
                    ),
                    onPressed: _loading
                    ? null
                        : () async {
                    setState(() => _loading = true);
                    await _saveRecords();
                    if (mounted) setState(() => _loading = false);
                    },
                    child: _loading
                    ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                    ),
                    )
                        : const Text(
                    "SAVE RECORDS",
                    style: TextStyle(color: Colors.white),
                    ),
                    ),
                    ),

                    const SizedBox(height: 12),

                    if (_saved)
                    SizedBox(
                    width: 150,
                    child: OutlinedButton.icon(
                    onPressed: _printRecords,
                    icon: const Icon(Icons.print),
                    label: const Text('PRINT'),
                    style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.lightBlue),
                    foregroundColor: Colors.lightBlue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    ),
                    ),
                    ),
                    ),
                    ],
                    ),
                    )

                    ],
                              ),
                            ),
                          ),
                        ),

                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TableRow _tableRow(List<String> cells, {bool isHeader = false}) {
    return TableRow(
      children: cells.asMap().entries.map((entry) {
        final index = entry.key;
        final text = entry.value;

        TextAlign align;
        if (isHeader) {
          align = TextAlign.center;
        } else if ([4, 5, 6, 7, 8].contains(index)) {
          align = TextAlign.right;
        } else {
          align = TextAlign.left;
        }

        return Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            text,
            textAlign: align,
            style: const TextStyle(
              color: Colors.white,
            ).copyWith(fontWeight: isHeader ? FontWeight.bold : FontWeight.normal),
          ),
        );
      }).toList(),
    );
  }
  Widget _cell(String text, {bool alignRight = false}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        textAlign: alignRight ? TextAlign.right : TextAlign.left,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

}
