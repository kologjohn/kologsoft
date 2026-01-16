// import 'dart:io';
// import 'dart:typed_data';
//
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:provider/provider.dart';
//
// import '../models/companymodel.dart';
// import '../providers/Datafeed.dart';
//
// class CompanyRegPage extends StatefulWidget {
//   final String? docId;
//   final Map<String, dynamic>? data;
//
//   const CompanyRegPage({Key? key, this.docId, this.data}) : super(key: key);
//
//   @override
//   State<CompanyRegPage> createState() => _CompanyRegPageState();
// }
//
// class _CompanyRegPageState extends State<CompanyRegPage> {
//   final _formKey = GlobalKey<FormState>();
//
//   final _companyController = TextEditingController();
//   final _nameController = TextEditingController();
//   final _phoneController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _addressController = TextEditingController();
//
//   String _branchType = "retail";
//   bool _loading = false;
//
//   Uint8List? _logoBytes;
//   File? _logoFile;
//   String? _existingLogoUrl;
//   String? _mode;
//   final FirebaseFirestore _db = FirebaseFirestore.instance;
//   final ImagePicker _picker = ImagePicker();
//
//   @override
//   void initState() {
//     super.initState();
//     if (widget.data != null) {
//       final d = widget.data!;
//       _companyController.text = d['company'] ?? '';
//       _nameController.text = d['name'] ?? '';
//       _phoneController.text = d['phone'] ?? '';
//       _emailController.text = d['email'] ?? '';
//       _addressController.text = d['address'] ?? '';
//       _branchType = d['branchType'] ?? 'retail';
//       _existingLogoUrl = d['logo'];
//     }
//   }
//
//   String normalizeKey(String input) {
//     return input.trim().toLowerCase()
//         .replaceAll(RegExp(r'[^a-z0-9 ]'), '')
//         .replaceAll(RegExp(r'\s+'), '_');
//   }
//
//   /// Pick image (all platforms)
//   Future<void> pickLogo() async {
//     final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
//     if (picked == null) return;
//
//     if (kIsWeb) {
//       _logoBytes = await picked.readAsBytes();
//       _logoFile = null;
//     } else {
//       _logoFile = File(picked.path);
//       _logoBytes = null;
//     }
//     setState(() {});
//   }
//
//   /// Upload logo to Firebase Storage and return download URL
//   Future<String?> uploadLogo(String companyId) async {
//     if (_logoFile == null && _logoBytes == null) {
//       return _existingLogoUrl; // no new logo selected
//     }
//
//     final ref = FirebaseStorage.instance
//         .ref()
//         .child('company_logos')
//         .child('$companyId.png');
//
//     UploadTask uploadTask;
//
//     if (kIsWeb) {
//       uploadTask = ref.putData(_logoBytes!,
//           SettableMetadata(contentType: 'image/png'));
//     } else {
//       uploadTask = ref.putFile(_logoFile!,
//           SettableMetadata(contentType: 'image/png'));
//     }
//
//     final snapshot = await uploadTask;
//     return await snapshot.ref.getDownloadURL();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final formWidth =
//     screenWidth > 900 ? screenWidth * 0.6 : screenWidth * 0.95;
//
//     return Consumer<Datafeed>(
//       builder: (context, datafeed, child) {
//         return Scaffold(
//           backgroundColor: const Color(0xFF101624),
//           appBar: AppBar(
//             title: Text(widget.docId == null
//                 ? "Register Company"
//                 : "Edit Company"),
//           ),
//           body: Padding(
//             padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
//             child: Align(
//               alignment: Alignment.topCenter,
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.symmetric(vertical: 40),
//                 child: ConstrainedBox(
//                   constraints: const BoxConstraints(maxWidth: 700),
//                   child: Container(
//                     width: formWidth,
//                     padding: const EdgeInsets.all(24),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFF1B263B),
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Form(
//                       key: _formKey,
//                       child: Column(
//                         children: [
//
//                           /// LOGO PICKER + PREVIEW
//                           Text("Upload Company Logo",
//                               style: TextStyle( color: Colors.white70, fontSize: 16,
//                                   fontWeight: FontWeight.w500)),
//                           SizedBox(height: 5.0,),
//                           GestureDetector(
//                             onTap: pickLogo,
//                             child: CircleAvatar(
//                               radius: 45,
//                               backgroundColor: const Color(0xFF22304A),
//                               backgroundImage: _logoBytes != null
//                                   ? MemoryImage(_logoBytes!)
//                                   : _logoFile != null
//                                   ? FileImage(_logoFile!)
//                                   : _existingLogoUrl != null
//                                   ? NetworkImage(_existingLogoUrl!)
//                                   : null,
//                               child: (_logoBytes == null &&
//                                   _logoFile == null &&
//                                   _existingLogoUrl == null)
//                                   ? const Icon(Icons.camera_alt,
//                                   color: Colors.white70, size: 30)
//                                   : null,
//                             ),
//                           ),
//
//                           const SizedBox(height: 20),
//
//                           _buildField(_companyController, "Company Name",
//                               Icons.business),
//                           const SizedBox(height: 14),
//                           _buildField(_nameController, "Contact Person",
//                               Icons.person),
//                           const SizedBox(height: 14),
//                           _buildField(
//                               _phoneController, "Phone", Icons.phone),
//                           const SizedBox(height: 14),
//                           _buildField(
//                               _emailController, "Email", Icons.email),
//                           const SizedBox(height: 14),
//                           _buildField(_addressController, "Address",
//                               Icons.location_on),
//                           const SizedBox(height: 20),
//                          DropdownButtonFormField<String>(
//                             dropdownColor: const Color(0xFF22304A),
//                             style: const TextStyle(color: Colors.white70),
//                             decoration: InputDecoration(
//                               labelText: "Branch",
//                               labelStyle: const TextStyle(color: Colors.white70),
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               enabledBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                                 borderSide: const BorderSide(color: Colors.white24),
//                               ),
//                               focusedBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                                 borderSide: const BorderSide(color: Colors.blue),
//                               ),
//                               fillColor: const Color(0xFF22304A),
//                               filled: true,
//                             ),
//                             value: _mode, // starts as null
//                             items: const [
//                               DropdownMenuItem(value: "single", child: Text("Single")),
//                               DropdownMenuItem(value: "multiple", child: Text("Multiple")),
//                             ],
//                             onChanged: (val) => setState(() => _mode = val),
//                             validator: (val) => val == null ? "Please select a mode" : null,
//                           ),
//                           const SizedBox(height: 20),
//                           Align(
//                             alignment: Alignment.topLeft,
//                             child: const Text(
//                               "Select type",
//                               style: TextStyle(color: Colors.white70),
//                             ),
//                           ),
//                           RadioListTile(
//                             title: const Text("Retail",
//                                 style: TextStyle(color: Colors.white70)),
//                             value: "retail",
//                             groupValue: _branchType,
//                             onChanged: (v) =>
//                                 setState(() => _branchType = v.toString()),
//                           ),
//                           RadioListTile(
//                             title: const Text("Wholesale",
//                                 style: TextStyle(color: Colors.white70)),
//                             value: "wholesale",
//                             groupValue: _branchType,
//                             onChanged: (v) =>
//                                 setState(() => _branchType = v.toString()),
//                           ),
//                           RadioListTile(
//                             title: const Text("Both",
//                                 style: TextStyle(color: Colors.white70)),
//                             value: "both",
//                             groupValue: _branchType,
//                             onChanged: (v) =>
//                                 setState(() => _branchType = v.toString()),
//                           ),
//
//                           const SizedBox(height: 25),
//
//                           SizedBox(
//                             width: 200,
//                             child: ElevatedButton(
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: const Color(0xFF415A77),
//                                 padding:
//                                 const EdgeInsets.symmetric(vertical: 14),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                               ),
//                               // onPressed: _loading
//                               //     ? null
//                               //     : () async {
//                               //   if (!_formKey.currentState!.validate()) {
//                               //     return;
//                               //   }
//                               //
//                               //   setState(() => _loading = true);
//                               //
//                               //   final staff = datafeed.staff;
//                               //   final company =
//                               //   _companyController.text.trim();
//                               //   final companyid = normalizeKey(company);
//                               //   final id = widget.docId ?? companyid;
//                               //
//                               //   /// Upload logo first
//                               //   final logoUrl =
//                               //   await uploadLogo(companyid);
//                               //
//                               //   CompanyModel model = CompanyModel(
//                               //     id: id,
//                               //     company: company,
//                               //     companyid: companyid,
//                               //     name: _nameController.text.trim(),
//                               //     phone: _phoneController.text.trim(),
//                               //     email: _emailController.text.trim(),
//                               //     address:
//                               //     _addressController.text.trim(),
//                               //     branchType: _branchType,
//                               //     logo: logoUrl ?? "",
//                               //     createdAt: DateTime.now(),
//                               //     updatedAt: DateTime.now(),
//                               //     updatedBy: staff,
//                               //   );
//                               //
//                               //   await _db
//                               //       .collection('companies')
//                               //       .doc(id)
//                               //       .set(model.toMap());
//                               //
//                               //   setState(() => _loading = false);
//                               //
//                               //   ScaffoldMessenger.of(context)
//                               //       .showSnackBar(SnackBar(
//                               //     content: Text(widget.docId == null
//                               //         ? "Company Registered Successfully"
//                               //         : "Company Updated Successfully"),
//                               //   ));
//                               //
//                               //   Navigator.pop(context);
//                               // },
//                               onPressed: _loading ? null : () async {
//                                 if (!_formKey.currentState!.validate()) return;
//
//                                 setState(() => _loading = true);
//                                 final staff = datafeed.staff;
//                                 final companyName = _companyController.text.trim();
//
//                                 try {
//
//                                   /// ================= EDIT MODE =================
//                                   if (widget.docId != null) {
//                                     final id = widget.docId!;
//                                     final logoUrl = await uploadLogo(id);
//
//                                     await _db.collection('companies').doc(id).update({
//                                       'company': companyName,
//                                       'name': _nameController.text.trim(),
//                                       'phone': _phoneController.text.trim(),
//                                       'email': _emailController.text.trim(),
//                                       'address': _addressController.text.trim(),
//                                       'branchType': _branchType,
//                                       'logo': logoUrl ?? "",
//                                       'updatedat': DateTime.now(),
//                                       'updatedby ': staff,
//                                     });
//                                   }
//
//                                   /// ================= NEW REGISTRATION =================
//                                   else {
//
//                                     /// 🔹 First check duplicate name (outside transaction)
//                                     final existing = await _db
//                                         .collection('companies')
//                                         .where('company', isEqualTo: companyName)
//                                         .limit(1)
//                                         .get();
//
//                                     if (existing.docs.isNotEmpty) {
//                                       throw Exception("Company already exists");
//                                     }
//
//                                     /// 🔹 Generate KS00 ID safely inside transaction
//                                     await _db.runTransaction((tx) async {
//                                       final counterRef =
//                                       _db.collection('counters').doc('company_ids');
//
//                                       final counterSnap = await tx.get(counterRef);
//
//                                       int last = counterSnap.exists ? (counterSnap['last'] ?? 0) : 0;
//                                       final next = last + 1;
//
//                                       tx.set(counterRef, {'last': next});
//
//                                       final newId = "KS00$next";
//
//                                       /// Upload logo using final ID
//                                       final logoUrl = await uploadLogo(newId);
//
//                                       final model = CompanyModel(
//                                         id: newId,
//                                         company: companyName,
//                                         companyid: newId,
//                                         name: _nameController.text.trim(),
//                                         phone: _phoneController.text.trim(),
//                                         email: _emailController.text.trim(),
//                                         address: _addressController.text.trim(),
//                                         branch: _mode!,
//                                         type: _branchType,
//                                         logo: logoUrl ?? "",
//                                         createdAt: DateTime.now(),
//                                         updatedAt: DateTime.now(),
//                                         updatedBy: staff,
//                                       );
//
//                                       tx.set(
//                                         _db.collection('companies').doc(newId),
//                                         model.toMap(),
//                                       );
//                                     });
//                                   }
//
//                                   ScaffoldMessenger.of(context).showSnackBar(
//                                     SnackBar(
//                                       content: Text(widget.docId == null
//                                           ? "Company Registered Successfully"
//                                           : "Company Updated Successfully"),
//                                     ),
//                                   );
//
//                                   Navigator.pop(context);
//
//                                 } catch (e) {
//                                   ScaffoldMessenger.of(context).showSnackBar(
//                                     SnackBar(content: Text(e.toString())),
//                                   );
//                                 }
//
//                                 setState(() => _loading = false);
//                               },
//
//                               child: _loading
//                                   ? const CircularProgressIndicator(
//                                   color: Colors.white)
//                                   : Text(widget.docId == null
//                                   ? "Register"
//                                   : "Update",style: TextStyle(color: Colors.white70),),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   TextFormField _buildField(
//       TextEditingController controller, String label, IconData icon) {
//     return TextFormField(
//       controller: controller,
//       style: const TextStyle(color: Colors.white70),
//       validator: (v) => v == null || v.isEmpty ? "Required" : null,
//       decoration: InputDecoration(
//         labelText: label,
//         labelStyle: const TextStyle(color: Colors.white70),
//         prefixIcon: Icon(icon, color: Colors.white70),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: Colors.white24),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: Colors.blue),
//         ),
//         fillColor: const Color(0xFF22304A),
//         filled: true,
//       ),
//     );
//   }
// }

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/companymodel.dart';
import '../providers/Datafeed.dart';

class CompanyRegPage extends StatefulWidget {
  final String? docId;
  final Map<String, dynamic>? data;

  const CompanyRegPage({Key? key, this.docId, this.data}) : super(key: key);

  @override
  State<CompanyRegPage> createState() => _CompanyRegPageState();
}

class _CompanyRegPageState extends State<CompanyRegPage> {
  final _formKey = GlobalKey<FormState>();

  final _companyController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();

  String _branchType = "retail";
  String? _mode; // dropdown
  bool _loading = false;

  Uint8List? _logoBytes;
  File? _logoFile;
  String? _existingLogoUrl;

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.data != null) {
      final d = widget.data!;
      _companyController.text = d['company'] ?? '';
      _nameController.text = d['name'] ?? '';
      _phoneController.text = d['phone'] ?? '';
      _emailController.text = d['email'] ?? '';
      _addressController.text = d['address'] ?? '';
      _branchType = d['branchType'] ?? 'retail';
      _mode = d['branch'] ?? null; // prefill dropdown
      _existingLogoUrl = d['logo'];
    }
  }

  String normalizeKey(String input) {
    return input.trim().toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9 ]'), '')
        .replaceAll(RegExp(r'\s+'), '_');
  }

  /// Pick image (all platforms)
  Future<void> pickLogo() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
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

  /// Upload logo to Firebase Storage and return download URL
  Future<String?> uploadLogo(String companyId) async {
    if (_logoFile == null && _logoBytes == null) {
      return _existingLogoUrl; // no new logo selected
    }

    final ref = FirebaseStorage.instance
        .ref()
        .child('company_logos')
        .child('$companyId.png');

    UploadTask uploadTask;

    if (kIsWeb) {
      uploadTask = ref.putData(_logoBytes!,
          SettableMetadata(contentType: 'image/png'));
    } else {
      uploadTask = ref.putFile(_logoFile!,
          SettableMetadata(contentType: 'image/png'));
    }

    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final formWidth =
    screenWidth > 900 ? screenWidth * 0.6 : screenWidth * 0.95;

    return Consumer<Datafeed>(
      builder: (context, datafeed, child) {
        return Scaffold(
          backgroundColor: const Color(0xFF101624),
          appBar: AppBar(
            title: Text(widget.docId == null
                ? "Register Company"
                : "Edit Company"),
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

                          /// LOGO PICKER + PREVIEW
                          Text(
                            "Upload Company Logo",
                            style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                                fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 5),
                          GestureDetector(
                            onTap: pickLogo,
                            child: CircleAvatar(
                              radius: 45,
                              backgroundColor: const Color(0xFF22304A),
                              backgroundImage: _logoBytes != null
                                  ? MemoryImage(_logoBytes!)
                                  : _logoFile != null
                                  ? FileImage(_logoFile!)
                                  : _existingLogoUrl != null
                                  ? NetworkImage(_existingLogoUrl!)
                                  : null,
                              child: (_logoBytes == null &&
                                  _logoFile == null &&
                                  _existingLogoUrl == null)
                                  ? const Icon(Icons.camera_alt,
                                  color: Colors.white70, size: 30)
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 20),

                          _buildField(_companyController, "Company Name",
                              Icons.business),
                          const SizedBox(height: 14),
                          _buildField(_nameController, "Contact Person",
                              Icons.person),
                          const SizedBox(height: 14),
                          _buildField(_phoneController, "Phone", Icons.phone),
                          const SizedBox(height: 14),
                          _buildField(_emailController, "Email", Icons.email),
                          const SizedBox(height: 14),
                          _buildField(
                              _addressController, "Address", Icons.location_on),
                          const SizedBox(height: 20),

                          /// DROPDOWN: Branch mode
                          DropdownButtonFormField<String>(
                            dropdownColor: const Color(0xFF22304A),
                            style: const TextStyle(color: Colors.white70),
                            decoration: InputDecoration(
                              labelText: "Branch",
                              labelStyle: const TextStyle(color: Colors.white70),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                const BorderSide(color: Colors.white24),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                const BorderSide(color: Colors.blue),
                              ),
                              fillColor: const Color(0xFF22304A),
                              filled: true,
                            ),
                            value: _mode,
                            items: const [
                              DropdownMenuItem(
                                  value: "single", child: Text("Single")),
                              DropdownMenuItem(
                                  value: "multiple", child: Text("Multiple")),
                            ],
                            onChanged: (val) => setState(() => _mode = val),
                            validator: (val) =>
                            val == null ? "Please select a mode" : null,
                          ),

                          const SizedBox(height: 20),

                          Align(
                            alignment: Alignment.topLeft,
                            child: const Text(
                              "Select type",
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),

                          RadioListTile(
                            title: const Text("Retail",
                                style: TextStyle(color: Colors.white70)),
                            value: "retail",
                            groupValue: _branchType,
                            onChanged: (v) =>
                                setState(() => _branchType = v.toString()),
                          ),
                          RadioListTile(
                            title: const Text("Wholesale",
                                style: TextStyle(color: Colors.white70)),
                            value: "wholesale",
                            groupValue: _branchType,
                            onChanged: (v) =>
                                setState(() => _branchType = v.toString()),
                          ),
                          RadioListTile(
                            title: const Text("Both",
                                style: TextStyle(color: Colors.white70)),
                            value: "both",
                            groupValue: _branchType,
                            onChanged: (v) =>
                                setState(() => _branchType = v.toString()),
                          ),

                          const SizedBox(height: 25),

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
                                final staff = datafeed.staff;
                                final companyName =
                                _companyController.text.trim();

                                try {
                                  /// ================= EDIT MODE =================
                                  if (widget.docId != null) {
                                    final id = widget.docId!;
                                    final logoUrl = await uploadLogo(id);

                                    await _db
                                        .collection('companies')
                                        .doc(id)
                                        .update({
                                      'company': companyName,
                                      'name': _nameController.text.trim(),
                                      'phone': _phoneController.text.trim(),
                                      'email': _emailController.text.trim(),
                                      'address':
                                      _addressController.text.trim(),
                                      'branchType': _branchType,
                                      'branch': _mode,
                                      'logo': logoUrl ?? "",
                                      'updatedAt': DateTime.now(),
                                      'updatedBy': staff,
                                    });
                                  }

                                  /// ================= NEW REGISTRATION =================
                                  else {
                                    final existing = await _db
                                        .collection('companies')
                                        .where('company',
                                        isEqualTo: companyName)
                                        .limit(1)
                                        .get();

                                    if (existing.docs.isNotEmpty) {
                                      throw Exception(
                                          "Company already exists");
                                    }

                                    /// Transaction to generate unique KS00 ID
                                    await _db.runTransaction((tx) async {
                                      final counterRef = _db
                                          .collection('counters')
                                          .doc('company_ids');

                                      final counterSnap =
                                      await tx.get(counterRef);

                                      int last = counterSnap.exists
                                          ? (counterSnap['last'] ?? 0)
                                          : 0;
                                      final next = last + 1;

                                      tx.set(counterRef, {'last': next});

                                      final newId = "KS00$next";

                                      /// Upload logo using final ID
                                      final logoUrl = await uploadLogo(newId);

                                      final model = CompanyModel(
                                        id: newId,
                                        company: companyName,
                                        companyid: newId,
                                        name:
                                        _nameController.text.trim(),
                                        phone:
                                        _phoneController.text.trim(),
                                        email:
                                        _emailController.text.trim(),
                                        address:
                                        _addressController.text.trim(),
                                        branch: _mode!,
                                        type: _branchType,
                                        logo: logoUrl ?? "",
                                        createdAt: DateTime.now(),
                                        updatedAt: DateTime.now(),
                                        updatedBy: staff,
                                      );

                                      tx.set(
                                        _db
                                            .collection('companies')
                                            .doc(newId),
                                        model.toMap(),
                                      );
                                    });
                                  }

                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    SnackBar(
                                      content: Text(widget.docId == null
                                          ? "Company Registered Successfully"
                                          : "Company Updated Successfully"),
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
                                  ? const CircularProgressIndicator(
                                  color: Colors.white)
                                  : Text(
                                widget.docId == null
                                    ? "Register"
                                    : "Update",
                                style: const TextStyle(
                                    color: Colors.white70),
                              ),
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

  TextFormField _buildField(
      TextEditingController controller, String label, IconData icon) {
    return TextFormField(
      controller: controller,
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
