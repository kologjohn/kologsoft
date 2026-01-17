import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kologsoft/models/customerreg_model.dart';
import 'package:kologsoft/providers/Datafeed.dart';
import 'package:provider/provider.dart';

import 'customerlist.dart';

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
  final TextEditingController _creditlimitController = TextEditingController();

  String? _selectedPurchaseType;
  String? _selectedpaymentduration;
  bool _loading=false;

  late List<String> _purchasTypes = ['Cash', 'Credit','Opening Stock'];
  late List<String> paymentduration = ['Short term', 'Long term'];

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
      _creditlimitController.text = customadata['creditlimit'] ?? '';
      final customerType = customadata['customertype'];
      if (_purchasTypes.contains(customerType)) { _selectedPurchaseType = customerType; }
      final paymentDuration = customadata['paymentduration'];
      if (paymentduration.contains(paymentDuration)) { _selectedpaymentduration = paymentDuration; }
    }
  }
  @override
  void dispose() {
    _invoicenumberController.dispose();
    _contactController.dispose();
    _creditlimitController.dispose();
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
                                          _creditlimitController.clear();
                                          _selectedpaymentduration = null;
                                        }
                                      });
                                    },
                                    validator: (value) =>
                                    value == null ? 'Please select customer type' : null,
                                  ),
                                  SizedBox(height: 14),
                                  if (isCashPurchase) ...[
                                    /// CREDIT LIMIT
                                    TextFormField(
                                      controller: _creditlimitController,
                                      style: const TextStyle(color: Colors.white),
                                      keyboardType: TextInputType.number,
                                      inputFormatters:
                                      [
                                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                                      ],
                                      decoration: InputDecoration(
                                        labelText: 'Credit Limit',
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
                                      validator: (value) {
                                        if (!isCashPurchase) return null;
                                        if (value == null || value.isEmpty) {
                                          return 'Enter valid credit limit'; }
                                        final num? parsed = num.tryParse(value);
                                        if (parsed == null) {
                                          return 'Only numbers are allowed'; }
                                        if (parsed <= 0) { return 'Credit limit must be greater than 0'; }
                                        return null;
                                      },
                                    ),

                                    const SizedBox(height: 14),

                                    /// PAYMENT DURATION
                                    DropdownButtonFormField<String>(
                                      value: _selectedpaymentduration,
                                      dropdownColor: const Color(0xFF22304A),
                                      style: const TextStyle(color: Colors.white),
                                      decoration: InputDecoration(
                                        labelText: 'Payment Duration',
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
                                      items: paymentduration.map((type) {
                                        return DropdownMenuItem<String>(
                                          value: type,
                                          child: Text(type),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() => _selectedpaymentduration = value);
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



                                  const SizedBox(height: 30),
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
                                            String name= _invoicenumberController.text.trim();
                                            String contact= _contactController.text.trim();
                                            String customertype= _selectedPurchaseType!;
                                            String creditlimit = isCashPurchase ? _creditlimitController.text.trim() : '';
                                            String paymentduration = isCashPurchase ? _selectedpaymentduration ?? '' : '';
                                            final branchId = value.selectedBranch?.id ?? '';
                                            final branchName = value.selectedBranch?.branchname ?? '';
                                            String docid=value.normalizeAndSanitize("${value.companyid}${contact}${branchId}");


                                            try {

                                              if (widget.docId != null) {
                                                final id = widget.docId!;
                                                final newCustomer = CustomerRegModel(id: id, branchname:branchName, branchid: branchId, name: name, contact: contact, customertype: customertype,creditlimit: creditlimit,paymentduration: paymentduration, companyid: value.companyid, staff: value.staff, date: DateTime.now(),updatedby: value.staff, updatedat: DateTime.now(), deletedat: null

                                                );

                                                await value.db
                                                    .collection('customers')
                                                    .doc(id)
                                                    .set(newCustomer.toMap());
                                                _invoicenumberController.clear();
                                                _contactController.clear();
                                                setState(() => _selectedPurchaseType = null);
                                              }

                                              else {
                                                final newCustomer = CustomerRegModel(id: docid, branchname:branchName, branchid:branchId, name: name, contact: contact, customertype: customertype,creditlimit: creditlimit,paymentduration: paymentduration, companyid: value.companyid, staff: value.staff, date: DateTime.now(), updatedat: null, deletedat: null

                                                );

                                                await value.db
                                                    .collection('customers')
                                                    .doc(docid)
                                                    .set(newCustomer.toMap());
                                                _invoicenumberController.clear();
                                                _contactController.clear();
                                                setState(() => _selectedPurchaseType = null);

                                              }

                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(widget.docId == null
                                                      ? "Customer Registered Successfully"
                                                      : "Customer Updated Successfully"),
                                                ),
                                              );

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
                                      SizedBox(
                                        width: 200,
                                        child: OutlinedButton.icon(
                                          style: OutlinedButton.styleFrom(
                                            side: const BorderSide(color: Colors.white70),
                                            padding: const EdgeInsets.symmetric(vertical: 16),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(14),
                                            ),
                                          ),
                                          icon: const Icon(Icons.view_list, color: Colors.white70),
                                          label: const Text("View", style: TextStyle(color: Colors.white70)),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (_) => CustomerListPage()),
                                            );
                                          },
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
