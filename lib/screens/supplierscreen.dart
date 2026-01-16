import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kologsoft/providers/Datafeed.dart';
import 'package:provider/provider.dart';

import '../models/suppliermodel.dart';



class SupplierRegistration extends StatefulWidget {
  const SupplierRegistration({super.key});

  @override
  State<SupplierRegistration> createState() => _SupplierRegistrationState();
}

class _SupplierRegistrationState extends State<SupplierRegistration> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _supplierController = TextEditingController();
  final _contactController = TextEditingController();

  bool _isSubmitting = false;



  @override
  void dispose() {
    _nameController.dispose();
    _supplierController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final formWidth = screenWidth > 900 ? screenWidth * 0.6 : screenWidth * 0.95;
    return Consumer<Datafeed>(builder: (BuildContext context, Datafeed value, Widget? child) {
     return Scaffold(
        backgroundColor: const Color(0xFF101624),
        appBar: AppBar(title: const Text('Register Supplier')),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                    maxWidth: 700
                ),
                child: Container(
                  width: formWidth,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B263B),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
              
                        // Name
                        TextFormField(
                          controller: _nameController,
                          style: const TextStyle(color: Colors.white70),
                          decoration: _inputDecoration('Name', Icons.person),
                          validator: (v) =>
                          v == null || v.isEmpty ? 'Required' : null,
                        ),
              
                        const SizedBox(height: 14),
              
                        // Supplier
                        TextFormField(
                          controller: _supplierController,
                          style: const TextStyle(color: Colors.white70),
                          decoration: _inputDecoration('Supplier', Icons.store),
                          validator: (v) =>
                          v == null || v.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 14),
                        // Contact
                        TextFormField(
                          controller: _contactController,
                          style: const TextStyle(color: Colors.white70),
                          decoration: _inputDecoration('Contact', Icons.phone),
                          validator: (v) =>
                          v == null || v.isEmpty ? 'Required' : null,
                        ),
              
                        const SizedBox(height: 20),
              
                        // Submit button

                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            // Save button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(
                                    0xFF415A77,
                                  ), // normal color
                                  disabledBackgroundColor: Colors.grey,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: _isSubmitting ? null : () async {
                                  if (!_formKey.currentState!.validate() || _isSubmitting) return;
                                  setState(() => _isSubmitting = true);
                                  final user = FirebaseAuth.instance.currentUser?.displayName;
                                  final id = '${value.companyid}_${_nameController.text}'.trim()
                                      .toLowerCase().replaceAll(RegExp(r'[^a-z0-9 ]'), '')
                                      .replaceAll(RegExp(r'\s+'), '_');
                                  final supplier = Supplier(
                                    id: id,
                                    name: _nameController.text.trim(),
                                    supplier: _supplierController.text.trim(),
                                    contact: _contactController.text.trim(),
                                    company: value.company,
                                    companyid: value.companyid,
                                    datecreated: Timestamp.now(),
                                    staff: value.staff,
                                  );

                                  // Add to Firestore with auto ID
                                  await FirebaseFirestore.instance.collection('suppliers').doc(id).set(supplier.toMap());
                                  setState(() {
                                    _isSubmitting = false;
                                    _nameController.clear();
                                    _supplierController.clear();
                                    _contactController.clear();
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Supplier saved successfully')),
                                  );
                                },
                                child: _isSubmitting
                                    ? const CircularProgressIndicator()
                                    : const Text('Save Supplier'),
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
                ),
              ),
            ),
          ),
        ),
      );
    },

    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
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
    );
  }
}
