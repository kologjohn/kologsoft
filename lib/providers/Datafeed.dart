import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kologsoft/models/productcategorymodel.dart';
import 'package:kologsoft/providers/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/branch.dart';
import '../models/warehousemodel.dart';


class Datafeed extends ChangeNotifier {
  final auth = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance;
  bool authenticated = false;
  String company = "kologsoft";
  String companytype = "both";
  String companyid = "kS0001";
  String companyemail = "kologsoft@kologsoft.com";
  String companyphone = "0553354349";
  String staff = "Yinbey";
  List<WarehouseModel> warehouses = [];
  bool loadingWarehouses = false;

  Future<void> fetchWarehouses() async {
    try {
      loadingWarehouses = true;
      notifyListeners();

      final snap = await db.collection('warehouse').where('companyid', isEqualTo: companyid).get();

      warehouses = snap.docs.map((e) => WarehouseModel.fromMap(e.data()))
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
    notifyListeners();
    Navigator.pushNamedAndRemoveUntil(context, Routes.login, (route) => false);
  }
  String normalizeAndSanitize(dynamic value) {
    if (value == null) return "na";

    String result = value.toString().trim();

    if (result.isEmpty)
      return "n_a";

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
    }

    else {
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
    }

    else {
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


  Future<void> deleteBranch(String id) async {
    final db = FirebaseFirestore.instance;
    await db.collection('branches').doc(id).delete();
  }
  Future<void> deleteCategory(String id) async {
    final db = FirebaseFirestore.instance;
    await db.collection('productcategoryreg').doc(id).delete();
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
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // authenticated = true;
      // final userDoc = await db
      //     .collection('staff')
      //     .doc(auth.currentUser!.email.toString())
      //     .get();
      // String accessLevel = userDoc.data()!['accessLevel'];
      // String staffName = userDoc.data()!['name'];
      // String phone = userDoc.data()!['phone'];
      // String region = userDoc.data()!['region'];
      //
      // spref.setString('email', email);
      // spref.setString('accessLevel', accessLevel);
      // spref.setString('staff', staffName);
      // spref.setString('phone', phone);
      // spref.setString('region', region);
      // auth.currentUser!.updateDisplayName(staffName);
      //
      // await getdata();
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
    } catch (e) {
      print(e);
    }

    notifyListeners();
  }


}
