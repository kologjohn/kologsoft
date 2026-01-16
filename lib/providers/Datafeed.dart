import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kologsoft/providers/routes.dart';
import 'package:kologsoft/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_user.dart';
import '../models/survey_question_model.dart';
import '../models/survey_response_model.dart';
import '../models/survey_template_model.dart';

class Datafeed extends ChangeNotifier {
  final auth = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance;
  bool authenticated = false;
  String staff = "";
  String region = "";
  String phone = "";
  String selectedWorkspaceClass = '';
  String selectedSurveyId = '';
  Future<void> logout(BuildContext context) async {
    final spref = await SharedPreferences.getInstance();
    await spref.clear();
    await auth.signOut();
    authenticated = false;
    staff = "";
    region = "";
    phone = "";
    notifyListeners();
    Navigator.pushNamedAndRemoveUntil(context, Routes.login, (route) => false);
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
      authenticated = true;
      final userDoc = await db
          .collection('staff')
          .doc(auth.currentUser!.email.toString())
          .get();
      String accessLevel = userDoc.data()!['accessLevel'];
      String staffName = userDoc.data()!['name'];
      String phone = userDoc.data()!['phone'];
      String region = userDoc.data()!['region'];

      spref.setString('email', email);
      spref.setString('accessLevel', accessLevel);
      spref.setString('staff', staffName);
      spref.setString('phone', phone);
      spref.setString('region', region);
      auth.currentUser!.updateDisplayName(staffName);

      await getdata();
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
      staff = spref.getString('staff')!;
      region = spref.getString('region')!;
      phone = spref.getString('phone')!;
    } catch (e) {
      print(e);
    }

    notifyListeners();
  }

  Future<void> fetchAndCacheStaff(String) async {
    final staffSnapshot = await db.collection('staff').get();
  }

  /// Fetches the list of business types from the workspacecategory collection
  /// Returns a list of maps containing name and workspaceClass
  Future<List<Map<String, dynamic>>> getBusinessTypes() async {
    try {
      final snapshot = await db.collection('workspacecategory').get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'name': data['name'] ?? '',
          'workspaceClass': data['workspaceClass'] ?? '',
          'id': doc.id,
        };
      }).toList();
    } catch (e) {
      print('Error fetching business types: $e');
      return [];
    }
  }
  // ---------- ADMIN ----------
  Future<void> saveSurvey( SurveyTemplate template, List<SurveyQuestion> questions, ) async {
    final batch = db.batch();

    final surveyRef =
    db.collection('surveys').doc(template.id);
    batch.set(surveyRef, template.toMap());

    for (final q in questions) {
      batch.set(
        surveyRef.collection('questions').doc(q.id),
        q.toMap(),
      );
    }

    await batch.commit();
  }

  Future<void> deleteSurvey(String id) async {
    await db.collection('surveys').doc(id).delete();
  }

  Stream<List<SurveyTemplate>> fetchSurveys() {
    return db.collection('surveys').snapshots().map(
          (s) => s.docs
          .map((d) => SurveyTemplate.fromMap(d.data()))
          .toList(),
    );
  }



  Future<List<SurveyQuestion>> fetchQuestions(String surveyId) async {
    final snap = await db.collection('surveys')
        .doc(surveyId).collection('questions').get();
        return snap.docs
        .map((e) => SurveyQuestion.fromMap(e.data()))
        .toList();
  }

  Future<void> submitSurvey(SurveyResponse response) async {
    await db.collection('surveyResponses').doc(response.id).set(response.toMap());
  }

}
