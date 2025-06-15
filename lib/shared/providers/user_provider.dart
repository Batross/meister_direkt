// lib/shared/providers/user_provider.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meisterdirekt/data/models/user_model.dart'; // تأكد من المسار الصحيح لـ UserModel

class UserProvider with ChangeNotifier {
  UserModel? _currentUser;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? get currentUser => _currentUser;

  UserProvider() {
    _auth.authStateChanges().listen((User? user) async {
      if (user != null) {
        await _fetchUserDetails(user.uid);
      } else {
        _currentUser = null;
        notifyListeners();
      }
    });
  }

  Future<void> _fetchUserDetails(String uid) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        _currentUser = UserModel.fromFirestore(userDoc);
      } else {
        // إذا كان المستخدم موجودًا في Auth ولكن ليس في Firestore، قم بإنشاء إدخال أساسي
        // (لا ينبغي أن يحدث مع التسجيل الصحيح الذي ينشئ مستند المستخدم)
        final email = _auth.currentUser?.email ?? 'unknown@example.com';
        // الدور الافتراضي للعميل إذا لم يتم العثور عليه في Firestore
        _currentUser = UserModel(uid: uid, email: email, role: 'client');
        await _firestore
            .collection('users')
            .doc(uid)
            .set(_currentUser!.toMap());
        print('تم إنشاء إدخال مستخدم أساسي لـ $uid في Firestore.');
      }
    } catch (e) {
      print('خطأ في جلب أو إنشاء تفاصيل المستخدم: $e');
      _currentUser = null;
    }
    notifyListeners();
  }

  // دالة مكشوفة ليتم استدعاؤها من SplashScreen أو تدفقات تسجيل الدخول/التسجيل الأخرى
  Future<void> fetchUserDetails(String uid) => _fetchUserDetails(uid);

  // دالة لتحديث تفاصيل المستخدم في المزود و Firestore
  Future<void> updateUserDetails(UserModel updatedUser) async {
    try {
      await _firestore
          .collection('users')
          .doc(updatedUser.uid)
          .update(updatedUser.toMap());
      _currentUser = updatedUser; // تحديث الحالة المحلية
      notifyListeners();
    } catch (e) {
      print('خطأ في تحديث تفاصيل المستخدم: $e');
    }
  }

  // دالة لتعيين المستخدم (مفيدة بعد تسجيل الدخول أو التسجيل لتحديث الحالة الفوري)
  void setUser(UserModel user) {
    _currentUser = user;
    notifyListeners();
  }

  // مسح بيانات المستخدم عند تسجيل الخروج (على الرغم من أن authStateChanges يجب أن تتعامل مع هذا)
  void clearUser() {
    _currentUser = null;
    notifyListeners();
  }
}
