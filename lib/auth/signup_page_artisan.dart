import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../artisan/pages/artisan_base_screen.dart'; // تأكد من المسار الصحيح
import '../data/models/user_model.dart';
import '../shared/widgets/custom_button.dart';
import '../shared/widgets/custom_text_field.dart';
import 'auth_base_screen.dart';

class SignupPageArtisan extends StatefulWidget {
  const SignupPageArtisan({super.key});

  @override
  State<SignupPageArtisan> createState() => _SignupPageArtisanState();
}

class _SignupPageArtisanState extends State<SignupPageArtisan> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  final _skillsController = TextEditingController();
  final _serviceAreasController = TextEditingController();
  final _companyNameController = TextEditingController();

  String? _errorMessage;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _skillsController.dispose();
    _serviceAreasController.dispose();
    _companyNameController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    try {
      if (_passwordController.text == _confirmPasswordController.text) {
        final UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        if (userCredential.user != null) {
          UserModel newArtisan = UserModel(
            userId: userCredential.user!.uid,
            email: _emailController.text.trim(),
            name: _nameController.text.trim(),
            role: 'craftsman',
            phone: _phoneController.text.trim().isNotEmpty
                ? _phoneController.text.trim()
                : null,
            bio: _bioController.text.trim().isNotEmpty
                ? _bioController.text.trim()
                : null,
            skills: _skillsController.text.trim().isNotEmpty
                ? _skillsController.text
                    .split(',')
                    .map((s) => s.trim())
                    .toList()
                : null,
            serviceAreas: _serviceAreasController.text.trim().isNotEmpty
                ? _serviceAreasController.text
                    .split(',')
                    .map((s) => s.trim())
                    .toList()
                : null,
            companyName: _companyNameController.text.trim().isNotEmpty
                ? _companyNameController.text.trim()
                : null,
            createdAt: DateTime.now(),
            isVerified: false,
            averageRating: 0.0,
            totalRatings: 0,
            badges: [],
            portfolioImages: [],
            fcmToken: null,
            paymentInfo: null,
            profilePicUrl: null,
          );

          await FirebaseFirestore.instance
              .collection('users')
              .doc(newArtisan.userId)
              .set(newArtisan.toMap());
        }

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ArtisanBaseScreen()),
          );
        }
      } else {
        setState(() {
          _errorMessage = 'كلمة المرور وتأكيد كلمة المرور غير متطابقتين';
        });
      }
    } on FirebaseAuthException catch (e) {
      print(
          'FirebaseAuthException during artisan sign up: ${e.code} - ${e.message}'); // Debug print
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
      print('Unexpected error during artisan sign up: $e'); // Debug print
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
          children: <Widget>[
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 50 * (1 - value)),
                    child: Image.asset(
                      'assets/images/artisan_signup_icon.png',
                      height: 100,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'انضم كحرفي!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2A5C82),
              ),
            ),
            const Text(
              'سجل الآن وابدأ في تقديم خدماتك',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
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
              keyboardType: TextInputType.emailAddress,
              labelText: 'البريد الإلكتروني',
              hintText: 'example@email.com',
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
              obscureText: true,
              labelText: 'كلمة المرور',
              hintText: 'أدخل كلمة مرور قوية (6+ أحرف)',
              prefixIcon: const Icon(Icons.lock),
              validator: (value) {
                if (value == null || value.isEmpty || value.length < 6) {
                  return 'يجب أن تكون كلمة المرور على الأقل 6 أحرف';
                }
                return null;
              },
            ),
            const SizedBox(height: 15),
            CustomTextField(
              controller: _confirmPasswordController,
              obscureText: true,
              labelText: 'تأكيد كلمة المرور',
              hintText: 'أعد إدخال كلمة المرور',
              prefixIcon: const Icon(Icons.lock),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء تأكيد كلمة المرور';
                }
                if (value != _passwordController.text) {
                  return 'كلمة المرور غير متطابقة';
                }
                return null;
              },
            ),
            const SizedBox(height: 15),
            CustomTextField(
              controller: _phoneController,
              labelText: 'رقم الهاتف (اختياري)',
              hintText: 'أدخل رقم هاتفك',
              prefixIcon: const Icon(Icons.phone),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 15),
            CustomTextField(
              controller: _bioController,
              labelText: 'سيرتك الذاتية (اختياري)',
              hintText: 'وصف قصير عنك وخبراتك',
              prefixIcon: const Icon(Icons.description),
              maxLines: 3,
            ),
            const SizedBox(height: 15),
            CustomTextField(
              controller: _skillsController,
              labelText: 'مهاراتك (اختياري)',
              hintText: 'مثال: سباكة، نجارة، كهرباء (افصل بفاصلة)',
              prefixIcon: const Icon(Icons.build),
            ),
            const SizedBox(height: 15),
            CustomTextField(
              controller: _serviceAreasController,
              labelText: 'مناطق الخدمة (اختياري)',
              hintText: 'مثال: الرياض، جدة (افصل بفاصلة)',
              prefixIcon: const Icon(Icons.location_on),
            ),
            const SizedBox(height: 15),
            CustomTextField(
              controller: _companyNameController,
              labelText: 'اسم الشركة (اختياري)',
              hintText: 'اسم شركتك أو عملك الحر',
              prefixIcon: const Icon(Icons.business),
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
                : CustomButton(onPressed: _signUp, text: 'إنشاء حساب حرفي'),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                if (mounted) {
                  Navigator.pop(context);
                }
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
