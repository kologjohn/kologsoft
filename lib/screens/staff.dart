import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' hide Uint8List;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../providers/Datafeed.dart';
import '../models/staffmodel.dart';

class Staff extends StatefulWidget {
  final String? docId;
  final Map<String, dynamic>? data;

  const Staff({Key? key, this.docId, this.data}) : super(key: key);

  @override
  State<Staff> createState() => _StaffState();
}

class _StaffState extends State<Staff> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  String? _accesslevel;
  String? _selectedBranch;
  bool _pricingRetail = false;
  bool _pricingWholesale = false;
  bool _pricingNone = false;

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
      context.read<Datafeed>().fetchBranches();
    });

    if (widget.data != null) {
      final d = widget.data!;
      _existingLogoUrl = d['imageurl'];
      _nameController.text = d['name'] ?? '';
      // ensure branch selection is initialized from passed data (support multiple key names)
      _selectedBranch =
          d['branchId'] ?? d['branch'] ?? d['branche'] ?? d['branchname'];
      // initialize pricing mode if provided (supports String or List)
      final pricingRaw = d['pricingMode'] ?? d['pricing'];
      List<String> pricingList = [];
      if (pricingRaw is List) {
        pricingList = pricingRaw.map((e) => e.toString()).toList();
      } else if (pricingRaw is String) {
        pricingList = pricingRaw
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
      _pricingRetail = pricingList.contains('retail');
      _pricingWholesale = pricingList.contains('wholesale');
      _pricingNone = pricingList.contains('none');
      // _barcodeController.text = d['barcode'] ?? '';
      // _costController.text = d['costprice'] ?? '';
      // _productType = d['producttype'];
      // _productCategory = d['productcategory'];
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
                      _buildField(_nameController, 'staff Name', Icons.person),
                      const SizedBox(height: 10),
                      _buildField(
                        _emailController,
                        'Email',
                        Icons.email,
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Please enter an email';
                          }
                          final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                          if (!emailRegex.hasMatch(v)) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      _buildField(
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Please enter a phone number';
                          }
                          final phoneRegex = RegExp(r'^\+?[0-9]{7,15}$');
                          if (!phoneRegex.hasMatch(v)) {
                            return 'Please enter a valid phone number';
                          }
                          return null;
                        },
                        _phoneController,
                        'Phone',
                        Icons.phone,
                        isNumber: true,
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: _accesslevel,
                        decoration: _buildDropdownDecoration('Product Type'),
                        items: const [
                          DropdownMenuItem(
                            value: 'admin',
                            child: Text('admin'),
                          ),
                          DropdownMenuItem(
                            value: 'super admin',
                            child: Text('super admin'),
                          ),
                          DropdownMenuItem(
                            value: 'warehouse',
                            child: Text('warehouse'),
                          ),
                          DropdownMenuItem(
                            value: 'sales',
                            child: Text('sales'),
                          ),
                          DropdownMenuItem(
                            value: 'cashier',
                            child: Text('cashier'),
                          ),
                        ],
                        onChanged: (v) => setState(() => _accesslevel = v),
                        validator: (v) =>
                            v == null ? 'Select product type' : null,
                      ),
                      const SizedBox(height: 10),
                      Consumer<Datafeed>(
                        builder: (context, datafeed, _) {
                          if (datafeed.branches.isEmpty) {
                            return const Text(
                              "No branches found",
                              style: TextStyle(color: Colors.white54),
                            );
                          }

                          return DropdownButtonFormField<String>(
                            value: _selectedBranch,
                            decoration: _buildDropdownDecoration(
                              'Select Branch',
                            ),
                            items: datafeed.branches
                                .map(
                                  (w) => DropdownMenuItem<String>(
                                    value: w.id,
                                    child: Text(w.branchname),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _selectedBranch = v),
                            validator: (v) =>
                                v == null ? 'Select Staff Branch' : null,
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      // Pricing mode checkboxes (mutually exclusive)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Pricing Mode',
                            style: TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 6),
                          CheckboxListTile(
                            value: _pricingRetail,
                            onChanged: (v) => setState(() {
                              _pricingRetail = v ?? false;
                              // selecting retail should clear 'none' if set
                              if (_pricingRetail) _pricingNone = false;
                            }),
                            title: const Text(
                              'Retail',
                              style: TextStyle(color: Colors.white70),
                            ),
                            controlAffinity: ListTileControlAffinity.leading,
                            activeColor: Colors.blue,
                            tileColor: const Color(0xFF22304A),
                            contentPadding: EdgeInsets.zero,
                          ),
                          CheckboxListTile(
                            value: _pricingWholesale,
                            onChanged: (v) => setState(() {
                              _pricingWholesale = v ?? false;
                              // selecting wholesale should clear 'none' if set
                              if (_pricingWholesale) _pricingNone = false;
                            }),
                            title: const Text(
                              'Wholesale',
                              style: TextStyle(color: Colors.white70),
                            ),
                            controlAffinity: ListTileControlAffinity.leading,
                            activeColor: Colors.blue,
                            tileColor: const Color(0xFF22304A),
                            contentPadding: EdgeInsets.zero,
                          ),
                          CheckboxListTile(
                            value: _pricingNone,
                            onChanged: (v) => setState(() {
                              _pricingNone = v ?? false;
                              if (_pricingNone) {
                                _pricingRetail = false;
                                _pricingWholesale = false;
                              }
                            }),
                            title: const Text(
                              'None',
                              style: TextStyle(color: Colors.white70),
                            ),
                            controlAffinity: ListTileControlAffinity.leading,
                            activeColor: Colors.blue,
                            tileColor: const Color(0xFF22304A),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF415A77),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                          ),
                          onPressed: _loading
                              ? null
                              : () async {
                                  if (!_formKey.currentState!.validate())
                                    return;
                                  setState(() => _loading = true);

                                  final name = _nameController.text.trim();
                                  final email = _emailController.text.trim();
                                  final phone = _phoneController.text.trim();
                                  final access = _accesslevel ?? '';
                                  final branchId = _selectedBranch ?? '';

                                  // find branch name from provider's list
                                  String branchName = '';
                                  for (var b in datafeed.branches) {
                                    if (b.id == branchId) {
                                      branchName = b.branchname;
                                      break;
                                    }
                                  }

                                  final docid = datafeed.normalizeAndSanitize(
                                    "${datafeed.companyid}${phone}${branchId}",
                                  );

                                  try {
                                    final id = widget.docId ?? docid;

                                    // If creating a new staff entry, check whether it already exists
                                    if (widget.docId == null) {
                                      final existing = await _db
                                          .collection('staff')
                                          .doc(id)
                                          .get();
                                      if (existing.exists) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Staff already exists',
                                            ),
                                          ),
                                        );
                                        if (!mounted) return;
                                        setState(() => _loading = false);
                                        return;
                                      }
                                    }

                                    final imageUrl = await uploadLogo(id);

                                    // collect one-or-more pricing modes
                                    final List<String> pricingModes = [];
                                    if (_pricingRetail)
                                      pricingModes.add('retail');
                                    if (_pricingWholesale)
                                      pricingModes.add('wholesale');
                                    if (_pricingNone) pricingModes.add('none');

                                    // build StaffModel
                                    final staffModel = StaffModel(
                                      id: id,
                                      name: name,
                                      email: email,
                                      phone: phone,
                                      accesslevel: access,
                                      pricingmode: pricingModes,
                                      createdAt: Timestamp.now(),
                                      createdBy: datafeed.staff,
                                      deletedAt: null,
                                      deletedBy: null,
                                      companyId: datafeed.companyid,
                                    );

                                    // convert to map and merge extra fields
                                    final record = staffModel.toMap();
                                    record.addAll({
                                      'branchId': branchId,
                                      'branchName': branchName,
                                      'imageurl': imageUrl ?? '',
                                      'updatedAt': widget.docId != null
                                          ? Timestamp.now()
                                          : null,
                                    });

                                    await _db
                                        .collection('staff')
                                        .doc(id)
                                        .set(record);

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          widget.docId == null
                                              ? 'Staff Registered Successfully'
                                              : 'Staff Updated Successfully',
                                        ),
                                      ),
                                    );

                                    // reset form
                                    _nameController.clear();
                                    _emailController.clear();
                                    _phoneController.clear();
                                    setState(() {
                                      _accesslevel = null;
                                      _selectedBranch = null;
                                    });
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(e.toString())),
                                    );
                                  }

                                  if (!mounted) return;
                                  setState(() => _loading = false);
                                },
                          child: _loading
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      'Saving...',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(
                                      Icons.save,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Save Staff',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ================= IMAGE UI =================
  Widget _imagePickerSection() {
    Widget preview;

    if (_logoBytes != null) {
      preview = Image.memory(_logoBytes!, fit: BoxFit.contain);
    } else if (_logoFile != null) {
      preview = Image.file(_logoFile!, fit: BoxFit.contain);
    } else if (_existingLogoUrl != null && _existingLogoUrl!.isNotEmpty) {
      preview = Image.network(_existingLogoUrl!, fit: BoxFit.contain);
    } else {
      preview = const Icon(Icons.image, size: 40, color: Colors.white38);
    }

    final bool hasImage =
        _logoBytes != null ||
        _logoFile != null ||
        (_existingLogoUrl != null && _existingLogoUrl!.isNotEmpty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Item Image (optional)',
          style: TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 8),

        // show preview only when an image exists (hide by default)
        if (hasImage) ...[
          GestureDetector(
            onTap: pickLogo,
            child: Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF22304A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Center(child: preview),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
        ],

        TextButton.icon(
          onPressed: pickLogo,
          icon: const Icon(Icons.upload),
          label: const Text('Select Image'),
        ),
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
    bool isNumber = false,
    Function(String)? onChanged,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
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
