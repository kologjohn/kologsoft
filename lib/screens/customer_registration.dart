import 'package:flutter/material.dart';
import 'package:kologsoft/models/customerreg_model.dart';
import 'package:kologsoft/providers/Datafeed.dart';
import 'package:provider/provider.dart';

class CustomerRegistration extends StatefulWidget {
  const CustomerRegistration({super.key});

  @override
  State<CustomerRegistration> createState() => _CustomerRegistrationState();
}

class _CustomerRegistrationState extends State<CustomerRegistration> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _creditlimitController = TextEditingController();

  String? _selectedCustomerType;
  String? _selectedpaymentduration;
  final List<String> _customerTypes = ['Cash', 'Credit'];
  final List<String> paymentduration = ['Short term', 'Long term'];
  bool get isCreditCustomer => _selectedCustomerType == 'Credit';

  @override
  Widget build(BuildContext context) {
    return Consumer<Datafeed>(
        builder: (BuildContext context, Datafeed value, Widget? child){
          return Scaffold(
            backgroundColor: const Color(0xFF101A23),
            appBar: AppBar(
              title: const Text('CUSTOMER REGISTRATION'),
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
                                    controller: _nameController,
                                    style: TextStyle(color: Colors.white),
                                    decoration: InputDecoration(
                                      labelText: 'Customer Name',
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
                                    validator: (value) => value == null || value.isEmpty
                                        ? 'Enter customer name'
                                        : null,
                                  ),
                                  SizedBox(height: 14),
                                  TextFormField(
                                    controller: _contactController,
                                    style: TextStyle(color: Colors.white),
                                    decoration: InputDecoration(
                                      labelText: 'Contact',
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
                                    validator: (value) => value == null || value.isEmpty
                                        ? 'Enter valid contact'
                                        : null,
                                  ),

                                  const SizedBox(height: 14),

                                  DropdownButtonFormField<String>(
                                    value: _selectedCustomerType,
                                    dropdownColor: const Color(0xFF22304A),
                                    style: const TextStyle(color: Colors.white),
                                    decoration: InputDecoration(
                                      labelText: 'Customer Type',
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
                                    items: _customerTypes.map((type) {
                                      return DropdownMenuItem<String>(
                                        value: type,
                                        child: Text(type),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedCustomerType = value;
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
                                  if (isCreditCustomer) ...[
                                    /// CREDIT LIMIT
                                    TextFormField(
                                      controller: _creditlimitController,
                                      style: const TextStyle(color: Colors.white),
                                      keyboardType: TextInputType.number,
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
                                        if (!isCreditCustomer) return null;
                                        return value == null || value.isEmpty
                                            ? 'Enter valid credit limit'
                                            : null;
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
                                        if (!isCreditCustomer) return null;
                                        return value == null ? 'Please select payment duration' : null;
                                      },
                                    ),
                                  ],

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
                                            backgroundColor: Colors.blue,
                                            padding: const EdgeInsets.symmetric(vertical: 16),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(14),
                                            ),
                                          ),
                                          onPressed: () async {
                                            if (!_formKey.currentState!.validate()) return;
                                                String name= _nameController.text.trim();
                                                String contact= _contactController.text.trim();
                                                String customertype= _selectedCustomerType!;
                                                String creditlimit = isCreditCustomer ? _creditlimitController.text.trim() : '';
                                                String paymentduration = isCreditCustomer ? _selectedpaymentduration ?? '' : '';

                                            String docid=value.normalizeAndSanitize("${value.companyid}${contact}");
                                            try {
                                              final newCustomer = CustomerRegModel(id: docid, branchname: '', branchid: '', name: name, contact: contact, customertype: customertype,creditlimit: creditlimit,paymentduration: paymentduration, companyid: value.companyid, staff: value.staff, date: DateTime.now()

                                              );

                                              await value.db
                                                  .collection('customers')
                                                  .doc(docid)
                                                  .set(newCustomer.toMap());

                                              // ✅ Clear form
                                              _nameController.clear();
                                              _contactController.clear();
                                              setState(() => _selectedCustomerType = null);

                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Customer saved successfully'),
                                                  backgroundColor: Colors.green,
                                                ),
                                              );

                                            } catch (e) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('Failed to save branch: $e'),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                          },

                                          child: Text("Add", style: TextStyle(color: Colors.white),),
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
                                          onPressed: () {},
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
