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
    return Consumer<Datafeed>(builder: (BuildContext context, Datafeed value, Widget? child) {
     return Scaffold(
        backgroundColor: const Color(0xFF101624),
        appBar: AppBar(title: const Text('Register Supplier')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            child: Form(
              key: _formKey,
              child: Card(
                color: const Color(0xFF182232),
                child: Padding(
                  padding: const EdgeInsets.all(16),
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
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
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
                    ],
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
