import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // استيراد Firestore للتحقق من الدور
import 'signup_page_artisan.dart';
import '../artisan/pages/artisan_base_screen.dart'; // تأكد من المسار الصحيح
import '../shared/widgets/custom_button.dart';
import '../shared/widgets/custom_text_field.dart';
import 'auth_base_screen.dart';

class LoginPageArtisan extends StatefulWidget {
  const LoginPageArtisan({super.key});

  @override
  State<LoginPageArtisan> createState() => _LoginPageArtisanState();
}

class _LoginPageArtisanState extends State<LoginPageArtisan> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final FirebaseAuth _auth =
      FirebaseAuth.instance; // إضافة FirebaseAuth instance
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance; // إضافة Firestore instance
  String? _errorMessage;
  bool _isLoading = false;
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>(); // إضافة GlobalKey للتحقق من النموذج

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) {
      // التحقق من صحة النموذج
      return;
    }

    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // التحقق من دور المستخدم من Firestore
      if (userCredential.user != null) {
        DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        if (userDoc.exists && userDoc.get('role') == 'craftsman') {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const ArtisanBaseScreen()),
            );
          }
        } else {
          // إذا لم يكن الدور حرفياً أو لم يتم العثور على المستند
          print(
              'User document not found or role is not craftsman for UID: ${userCredential.user!.uid}'); // Debug print
          await _auth.signOut(); // تسجيل الخروج من Firebase Auth
          setState(() {
            _errorMessage = 'هذا الحساب ليس حساب حرفي أو غير موجود.';
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
          'FirebaseAuthException during artisan login: ${e.code} - ${e.message}'); // Debug print
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
      print('Unexpected error during artisan login: $e'); // Debug print
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
          children: <Widget>[
            // لقطة الشاشة القديمة تظهر FlutterLogo، يمكن استبدالها بصورة Artisan
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 50 * (1 - value)),
                    child: Image.asset(
                      'assets/images/artisan_login_icon.png', // تأكد من وجود هذه الصورة في assets
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
                color: Color(0xFF2A5C82), // لون من PrimarySwatch
              ),
            ),
            const Text(
              'تسجيل دخول الحرفي',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 30),
            CustomTextField(
              controller: _emailController,
              labelText: 'البريد الإلكتروني',
              keyboardType: TextInputType.emailAddress,
              prefixIcon: const Icon(Icons.email),
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
              obscureText: true,
              prefixIcon: const Icon(Icons.lock),
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
                // تم استخدام AnimatedOpacity لتحسين الواجهة
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
                : CustomButton(onPressed: _signIn, text: 'تسجيل الدخول كحرفي'),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                if (mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SignupPageArtisan(),
                    ),
                  );
                }
              },
              child: const Text(
                'ليس لديك حساب؟ إنشاء حساب حرفي',
                style:
                    TextStyle(color: Color(0xFF2A5C82)), // لون من PrimarySwatch
              ),
            ),
          ],
        ),
      ),
    );
  }
}
