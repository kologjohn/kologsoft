import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kologsoft/models/paymentdurationmodel.dart';
import 'package:kologsoft/models/productcategorymodel.dart';
import 'package:kologsoft/models/staffmodel.dart';
import 'package:kologsoft/providers/routes.dart';
import 'package:kologsoft/screens/stocking_mode.dart';
import 'package:kologsoft/services/item_cache_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/branch.dart';
import '../models/companymodel.dart';
import '../models/stocking_modeModel.dart';
import '../models/suppliermodel.dart';
import '../models/warehousemodel.dart';

class Datafeed extends ChangeNotifier {
  final auth = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance;
  final ItemCacheService itemCache = ItemCacheService();
  bool authenticated = false;
  bool isOffline = false;
  String company = "";
  String companytype = "both";
  String companyid = "";
  String companyemail = "";
  String companyphone = "";
  String staff = "";
  int staffPosition = 0;
  List<WarehouseModel> warehouses = [];
  bool loadingproductcategory = false;
  List<Productcategorymodel> productcategory = [];
  List<BranchModel> branches = [];
  List<Supplier> suppliers = [];
  List<stockingModeModel> stockingModes = [];
  bool loadingWarehouses = false;
  BranchModel? selectedBranch;
  Supplier? selectedSupplier;
  StaffModel? currentStaff;
  CompanyModel? currentCompany;
  stockingModeModel? selectedStockingMode;

  Datafeed() {
    _initSync();
    _initItemCache();
  }

  Future<void> _initItemCache() async {
    try {
      await itemCache.init();
      debugPrint('✅ Item cache initialized');
    } catch (e) {
      debugPrint('❌ Error initializing item cache: $e');
    }
  }

  void _initSync() {
    // Listen to Firestore snapshots metadata to detect offline/online status
    db
        .collection('_connection_check')
        .limit(1)
        .snapshots(includeMetadataChanges: true)
        .listen((snapshot) {
          isOffline = snapshot.metadata.isFromCache;
          notifyListeners();
          debugPrint(isOffline ? '📴 App is OFFLINE' : '📶 App is ONLINE');
        });
  }

  fetchBranches() async {
    try {
      final snap = await db
          .collection('branches')
          .where("companyId", isEqualTo: companyid)
          .get(const GetOptions(source: Source.serverAndCache));
      final fetchedBranches = snap.docs.map((doc) {
        return BranchModel.fromJson(doc.data());
      }).toList();
      branches = [
        BranchModel(id: "$companyid${'all'}", branchname: 'All'),
        ...fetchedBranches,
      ];
      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching branches: $e");
    }
  }

  fetchSuppliers() async {
    try {
      final snap = await db
          .collection('suppliers')
          .where("companyid", isEqualTo: companyid)
          .get(const GetOptions(source: Source.serverAndCache));
      suppliers = snap.docs.map((doc) {
        return Supplier.fromMap(doc.data());
      }).toList();
      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching suppliers: $e");
    }
  }

  fetchStockingModes() async {
    try {
      final snap = await db
          .collection('stockingmode')
          .where("companyid", isEqualTo: companyid)
          .get(const GetOptions(source: Source.serverAndCache));
      stockingModes = snap.docs.map((doc) {
        return stockingModeModel.fromJson(doc.data());
      }).toList();
      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching stocking modes: $e");
    }
  }

  Future<void> fetchproductcategory() async {
    loadingproductcategory = true;
    notifyListeners();

    try {
      final snap = await db
          .collection('productcategoryreg')
          .where('companyId', isEqualTo: companyid)
          .get(const GetOptions(source: Source.serverAndCache));
      print("the category lenth is ${snap.docs.length} $companyid");
      productcategory = snap.docs
          .map((e) => Productcategorymodel.fromJson(e.data()))
          .toList();
    } catch (e) {
      debugPrint("fetch product category error: $e");
    }

    loadingproductcategory = false;
    notifyListeners();
  }

  selectSupplier(String suplylierId) {
    selectedSupplier = suppliers.firstWhere(
      (sup) => sup.id == suplylierId,
      orElse: () => Supplier(
        id: '',
        supplier: '',
        staff: '',
        contact: '',
        company: '',
        companyid: '',
        datecreated: Timestamp.now(),
      ),
    );
    notifyListeners();
  }

  selectBranch(String branchId) {
    selectedBranch = branches.firstWhere(
      (branch) => branch.id == branchId,
      orElse: () => BranchModel(),
    );
    notifyListeners();
  }

  selectstockingMode(String modeid) {
    selectedStockingMode = stockingModes.firstWhere(
      (stockmode) => stockmode.id == modeid,
      orElse: () => stockingModeModel(
        name: '',
        staff: '',
        id: '',
        date: DateTime.now(),
        companyid: '',
        company: '',
      ),
    );
    notifyListeners();
  }

  Future<void> fetchWarehouses() async {
    try {
      loadingWarehouses = true;
      notifyListeners();

      final snap = await db
          .collection('warehouse')
          .where('companyid', isEqualTo: companyid)
          .get();

      warehouses = snap.docs
          .map((e) => WarehouseModel.fromMap(e.data()))
          .toList();
    } catch (e) {
      debugPrint("Fetch warehouses error: $e");
    }

    loadingWarehouses = false;
    notifyListeners();
  }

  Future<void> logout(BuildContext context) async {
    final spref = await SharedPreferences.getInstance();
    await spref.clear();
    await auth.signOut();
    authenticated = false;
    company = "";
    companyid = "";
    companyemail = "";
    companyphone = "";
    staff = "";
    staffPosition = 0;
    currentStaff = null;
    currentCompany = null;
    notifyListeners();
    Navigator.pushNamedAndRemoveUntil(context, Routes.login, (route) => false);
  }

  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      final user = auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      // Re-authenticate user with current password
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // Change password
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        throw Exception('Current password is incorrect');
      } else if (e.code == 'weak-password') {
        throw Exception('New password is too weak');
      } else {
        throw Exception(e.message ?? 'Failed to change password');
      }
    } catch (e) {
      throw Exception('Failed to change password: $e');
    }
  }

  String normalizeAndSanitize(dynamic value) {
    if (value == null) return "na";

    String result = value.toString().trim();

    if (result.isEmpty) return "n_a";

    result = result
        .replaceAll('/', '')
        .replaceAll(' ', '')
        .replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '');

    result = result.toLowerCase();

    return result.isNotEmpty ? result : "n_a";
  }

  Future<void> addOrUpdateBranch(BranchModel branch) async {
    String docId;

    if (branch.id.isNotEmpty) {
      docId = branch.id;
    } else {
      docId = "${branch.companyid}${branch.branchname}"
          .toLowerCase()
          .replaceAll(RegExp(r'\s+'), '_');

      branch.id = docId;
    }

    await db
        .collection('branches')
        .doc(docId)
        .set(branch.toMap(), SetOptions(merge: true));
  }

  Future<void> addOrUpdateCategory(Productcategorymodel category) async {
    String docId;

    if (category.id.isNotEmpty) {
      docId = category.id;
    } else {
      docId = "${category.companyid}${category.productname}"
          .toLowerCase()
          .replaceAll(RegExp(r'\s+'), '_');

      category.id = docId;
    }

    await db
        .collection('productcategoryreg')
        .doc(docId)
        .set(category.toMap(), SetOptions(merge: true));
  }

  Future<void> addOrUpdatePaymentDuration(PaymentDurationModel payment) async {
    String docId;

    if (payment.id.isNotEmpty) {
      docId = payment.id;
    } else {
      docId = "${payment.companyid}${payment.paymentname}"
          .toLowerCase()
          .replaceAll(RegExp(r'\s+'), '_');

      payment.id = docId;
    }

    await db
        .collection('paymentdurationreg')
        .doc(docId)
        .set(payment.toMap(), SetOptions(merge: true));
  }

  Future<void> deleteBranch(String id) async {
    await db.collection('branches').doc(id).delete();
  }

  Future<void> deleteCategory(String id) async {
    await db.collection('productcategoryreg').doc(id).delete();
  }

  Future<void> deletePaymentDuration(String id) async {
    await db.collection('paymentdurationreg').doc(id).delete();
  }

  Future<void> forgotPassword(String email, BuildContext context) async {
    try {
      await auth.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset email sent!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: \\${e.toString()}')));
    }
  }

  login(String email, String password, BuildContext context) async {
    final spref = await SharedPreferences.getInstance();
    try {
      final userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      authenticated = true;
      final userDoc = await db
          .collection('staff')
          .doc(auth.currentUser!.email.toString())
          .get();

      if (userDoc.exists) {
        // Use StaffModel to parse the data
        currentStaff = StaffModel.fromMap(userDoc.data()!);

        final companydoc = await db
            .collection('companies')
            .doc(currentStaff!.companyId.toString().toUpperCase())
            .get();
        print(currentStaff!.companyId);

        if (companydoc.exists) {
          currentCompany = CompanyModel.fromMap(companydoc.data()!);
          company = currentCompany!.company;
          companyemail = currentCompany!.email;
          companyphone = currentCompany!.phone;
        }
        // Save to SharedPreferences
        spref.setString('email', currentStaff!.email);
        spref.setString('accessLevel', currentStaff!.accesslevel);
        spref.setString('staff', currentStaff!.name);
        spref.setString('phone', currentStaff!.phone);
        spref.setString('companyid', currentStaff!.companyId);
        spref.setString('companyphone', currentCompany!.phone);
        spref.setString('company', currentCompany!.company);
        spref.setString('companyemail', currentCompany!.email);
        spref.setInt('staffPosition', currentStaff!.position);

        // Update display name
        auth.currentUser!.updateDisplayName(currentStaff!.name);

        // Update local state
        staff = currentStaff!.name;
        companyid = currentStaff!.companyId;
        staffPosition = currentStaff!.position;
      }
      await getdata();

      // Sync items cache after successful login
      _syncItemsCache();

      notifyListeners();
      Navigator.pushNamed(context, Routes.home);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
        SnackBar snackBar = SnackBar(
          content: Text('No user found for that email.'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
        SnackBar snackBar = SnackBar(
          content: Text('Wrong password provided for that user.'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
      SnackBar snackBar = SnackBar(content: Text('Error: ${e.message}'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

    // Implement login logic here
  }

  getdata() async {
    try {
      final spref = await SharedPreferences.getInstance();
      company = spref.getString('company')!;
      companyid = spref.getString('companyid')!;
      companyemail = spref.getString('companyemail')!;
      companyphone = spref.getString('companyphone')!;
      staff = spref.getString('staff')!;
      staffPosition = spref.getInt('staffPosition') ?? 0;
      print(company);
    } catch (e) {
      print(e);
    }

    notifyListeners();
  }

  // Sync items cache in background
  void _syncItemsCache() async {
    if (companyid.isEmpty) return;

    try {
      debugPrint('🔄 Starting background item sync...');
      await itemCache.syncItems(companyid);
      final stats = itemCache.getCacheStats();
      debugPrint('✅ Item cache synced: ${stats['totalItems']} items');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error syncing item cache: $e');
    }
  }

  // Force sync items cache
  Future<void> forceSyncItems() async {
    if (companyid.isEmpty) return;

    try {
      debugPrint('🔄 Force syncing items...');
      await itemCache.syncItems(companyid, forceSync: true);
      final stats = itemCache.getCacheStats();
      debugPrint('✅ Items force synced: ${stats['totalItems']} items');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error force syncing items: $e');
      rethrow;
    }
  }
}
