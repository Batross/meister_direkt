// lib/shared/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meisterdirekt/data/models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _firebaseUser;
  User? get firebaseUser => _firebaseUser;

  AuthProvider() {
    _auth.authStateChanges().listen((User? user) {
      _firebaseUser = user;
      notifyListeners();
      print('Auth state changed: ${user?.uid}');
    });
  }

  Future<UserCredential?> signUp({
    required String email,
    required String password,
    required String role,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? address,
    String? profession, // أضيف للحرفيين
    String? bio, // أضيف للحرفيين
  }) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // إنشاء UserModel وحفظه في Firestore
        UserModel newUser = UserModel(
          uid: userCredential.user!.uid,
          email: email,
          role: role,
          firstName: firstName,
          lastName: lastName,
          phoneNumber: phoneNumber,
          address: address,
          profession: profession, // تمرير المهنة
          bio: bio, // تمرير السيرة الذاتية
          isVerified:
              role == 'craftsman' ? false : null, // الحرفيون يبدأون كغير موثقين
        );
        await _firestore
            .collection('users')
            .doc(newUser.uid)
            .set(newUser.toMap());
      }
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('خطأ في مصادقة Firebase أثناء التسجيل: ${e.message}');
      return Future.error(e.message ?? 'فشل التسجيل');
    } catch (e) {
      print('خطأ أثناء التسجيل: $e');
      return Future.error('فشل التسجيل: $e');
    }
  }

  Future<UserCredential?> signIn(
      {required String email, required String password}) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('خطأ في مصادقة Firebase أثناء تسجيل الدخول: ${e.message}');
      return Future.error(e.message ?? 'فشل تسجيل الدخول');
    } catch (e) {
      print('خطأ أثناء تسجيل الدخول: $e');
      return Future.error('فشل تسجيل الدخول: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      print('تم تسجيل خروج المستخدم بنجاح.');
    } catch (e) {
      print('خطأ أثناء تسجيل الخروج: $e');
      return Future.error('فشل تسجيل الخروج: $e');
    }
  }
}
