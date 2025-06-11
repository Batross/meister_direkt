import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/user_model.dart'; // تأكد من المسار الصحيح

class UserProvider with ChangeNotifier {
  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserProvider() {
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        _fetchUser(user.uid);
      } else {
        _currentUser = null;
        notifyListeners();
      }
    });
  }

  Future<void> _fetchUser(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        _currentUser = UserModel.fromSnapshot(doc);
        notifyListeners();
      } else {
        _currentUser = null;
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching user: $e');
      _currentUser = null;
      notifyListeners();
    }
  }

  // يمكن استخدام هذه الوظيفة لتحديث بيانات المستخدم محلياً أو بعد تسجيل الدخول
  void setCurrentUser(UserModel? user) {
    _currentUser = user;
    notifyListeners();
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _currentUser = null; // مسح بيانات المستخدم عند تسجيل الخروج
    notifyListeners();
  }
}
