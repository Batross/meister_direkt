import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../customer/pages/customer_base_screen.dart';
import '../shared/widgets/custom_text_field.dart';
import '../shared/widgets/custom_button.dart';
import 'auth_base_screen.dart';
import 'signup_page_customer.dart';

class LoginPageCustomer extends StatefulWidget {
  const LoginPageCustomer({super.key});

  @override
  State<LoginPageCustomer> createState() => _LoginPageCustomerState();
}

class _LoginPageCustomerState extends State<LoginPageCustomer> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _errorMessage;
  bool _isLoading = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Check user role from Firestore
      if (userCredential.user != null) {
        DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        if (userDoc.exists && userDoc.get('role') == 'client') {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const CustomerBaseScreen(),
              ),
            );
          }
        } else {
          // If role is not client, or user data not found, sign out and show error
          print(
              'User document not found or role is not client for UID: ${userCredential.user!.uid}'); // Debug print
          await _auth.signOut();
          setState(() {
            _errorMessage = 'هذا الحساب ليس حساب زبون أو غير موجود.';
          });
        }
      } else {
        // Should ideally not happen if signInWithEmailAndPassword succeeds
        setState(() {
          _errorMessage = 'فشل تسجيل الدخول: المستخدم غير موجود.';
        });
      }
    } on FirebaseAuthException catch (e) {
      print(
          'FirebaseAuthException during customer login: ${e.code} - ${e.message}'); // Debug print
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
      print('Unexpected error during customer login: $e'); // Debug print
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
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 50 * (1 - value)),
                    child: Image.asset(
                      'assets/images/customer_login_icon.png',
                      height: 100,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'مرحباً بك مجدداً!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2A5C82),
              ),
            ),
            const Text(
              'تسجيل دخول الزبون',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 30),
            CustomTextField(
              controller: _emailController,
              labelText: 'البريد الإلكتروني',
              hintText: 'example@email.com',
              prefixIcon: const Icon(Icons.email),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty || !value.contains('@')) {
                  return 'الرجاء إدخال بريد إلكتروني صحيح';
                }
                return null;
              },
            ),
            const SizedBox(height: 15),
            CustomTextField(
              controller: _passwordController,
              labelText: 'كلمة المرور',
              hintText: 'أدخل كلمة المرور الخاصة بك',
              prefixIcon: const Icon(Icons.lock),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال كلمة المرور';
                }
                return null;
              },
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
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            _isLoading
                ? const CircularProgressIndicator()
                : CustomButton(
                    onPressed: _login,
                    text: 'تسجيل الدخول',
                  ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SignUpPageCustomer()),
                );
              },
              child: const Text(
                'ليس لديك حساب؟ سجل الآن',
                style: TextStyle(color: Color(0xFF2A5C82)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
