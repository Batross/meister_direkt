import 'package:flutter/material.dart';
import 'package:meister_direkt/admin/pages/admin_dashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // <--- أضف هذا الاستيراد
import '../shared/widgets/custom_button.dart';
import '../shared/widgets/custom_text_field.dart';
import 'auth_base_screen.dart';

class LoginPageAdmin extends StatefulWidget {
  const LoginPageAdmin({super.key});

  @override
  State<LoginPageAdmin> createState() => _LoginPageAdminState();
}

class _LoginPageAdminState extends State<LoginPageAdmin> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance; // <--- أضف هذا
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance; // <--- أضف هذا
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void dispose() {
    // <--- أضف هذا
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signInAdmin() async {
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        // <--- استخدم _auth
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      User? user = userCredential.user; // <--- استخدم userCredential.user
      if (user != null) {
        // التحقق من دور المستخدم من Firestore
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();

        if (userDoc.exists && userDoc.get('role') == 'admin') {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AdminDashboard()),
            );
          }
        } else {
          // إذا لم يكن الدور مسؤولاً أو لم يتم العثور على المستند
          print(
              'User document not found or role is not admin for UID: ${user.uid}'); // Debug print
          await _auth.signOut(); // تسجيل الخروج من Firebase Auth
          setState(() {
            _errorMessage = 'هذا الحساب ليس حساب مسؤول أو غير موجود.';
          });
        }
      } else {
        // هذا المسار نادراً ما يتم الوصول إليه إذا نجح signInWithEmailAndPassword
        setState(() {
          _errorMessage = 'فشل تسجيل الدخول: المستخدم غير موجود.';
        });
      }
    } on FirebaseAuthException catch (e) {
      print(
          'FirebaseAuthException during admin login: ${e.code} - ${e.message}'); // Debug print
      setState(() {
        if (e.code == 'user-not-found' || e.code == 'wrong-password') {
          _errorMessage = 'البريد الإلكتروني أو كلمة المرور غير صحيحة.';
        } else if (e.code == 'invalid-email') {
          _errorMessage = 'صيغة البريد الإلكتروني غير صحيحة.';
        } else {
          _errorMessage = 'حدث خطأ: ${e.message}';
        }
      });
    } catch (e) {
      print('Unexpected error during admin login: $e'); // Debug print
      setState(() {
        _errorMessage = 'حدث خطأ غير متوقع: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthBaseScreen(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const FlutterLogo(size: 80),
          const SizedBox(height: 20),
          CustomTextField(
            controller: _emailController,
            labelText: 'البريد الإلكتروني',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 15),
          CustomTextField(
            controller: _passwordController,
            labelText: 'كلمة المرور',
            obscureText: true,
          ),
          const SizedBox(height: 20),
          if (_errorMessage != null)
            AnimatedOpacity(
              opacity: _errorMessage != null ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeIn,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),
          _isLoading
              ? const CircularProgressIndicator()
              : CustomButton(
                  onPressed: _signInAdmin,
                  text: 'تسجيل الدخول كمسؤول',
                ),
        ],
      ),
    );
  }
}
