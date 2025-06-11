import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../customer/pages/customer_base_screen.dart';
import '../data/models/user_model.dart';
import '../shared/widgets/custom_text_field.dart';
import '../shared/widgets/custom_button.dart';
import 'auth_base_screen.dart';

class SignUpPageCustomer extends StatefulWidget {
  const SignUpPageCustomer({super.key});

  @override
  State<SignUpPageCustomer> createState() => _SignUpPageCustomerState();
}

class _SignUpPageCustomerState extends State<SignUpPageCustomer> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _errorMessage;
  bool _isLoading = false;
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>(); // إضافة GlobalKey للتحقق من النموذج

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) {
      // التحقق من صحة النموذج
      return;
    }

    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Save user data to Firestore
      UserModel newUser = UserModel(
        userId: userCredential.user!.uid,
        email: _emailController.text.trim(),
        name: _nameController.text.trim(),
        role: 'client', // الدور الافتراضي للزبون
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(newUser.userId)
          .set(newUser.toMap());

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const CustomerBaseScreen(),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      print(
          'FirebaseAuthException during customer sign up: ${e.code} - ${e.message}'); // Debug print
      setState(() {
        if (e.code == 'weak-password') {
          _errorMessage =
              'كلمة المرور ضعيفة جدًا. يجب أن تكون 6 أحرف على الأقل.';
        } else if (e.code == 'email-already-in-use') {
          _errorMessage = 'هذا البريد الإلكتروني مستخدم بالفعل.';
        } else if (e.code == 'invalid-email') {
          _errorMessage = 'صيغة البريد الإلكتروني غير صحيحة.';
        } else {
          _errorMessage = 'حدث خطأ: ${e.message}';
        }
      });
    } catch (e) {
      print('Unexpected error during customer sign up: $e'); // Debug print
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
        // إضافة Form widget هنا
        key: _formKey, // تعيين GlobalKey
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
                      'assets/images/customer_signup_icon.png',
                      height: 100,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'إنشاء حساب زبون جديد',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2A5C82),
              ),
            ),
            const SizedBox(height: 30),
            CustomTextField(
              controller: _nameController,
              labelText: 'الاسم الكامل',
              hintText: 'أدخل اسمك',
              prefixIcon: const Icon(Icons.person),
              keyboardType: TextInputType.text,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال الاسم';
                }
                return null;
              },
            ),
            const SizedBox(height: 15),
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
              hintText: 'أدخل كلمة مرور قوية (6+ أحرف)',
              prefixIcon: const Icon(Icons.lock),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty || value.length < 6) {
                  return 'يجب أن تكون كلمة المرور على الأقل 6 أحرف';
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
                    onPressed: _signUp,
                    text: 'إنشاء حساب جديد',
                  ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // العودة لصفحة تسجيل الدخول
              },
              child: const Text(
                'لديك حساب بالفعل؟ تسجيل الدخول',
                style: TextStyle(color: Color(0xFF2A5C82)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
