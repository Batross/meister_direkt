// lib/auth/pages/auth_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meisterdirekt/shared/providers/auth_provider.dart'
    as AppAuth; // ****** التغيير الحاسم هنا: إضافة 'as AppAuth' ******
import 'package:meisterdirekt/shared/providers/user_provider.dart';
import 'package:meisterdirekt/data/models/user_model.dart';

class AuthScreen extends StatefulWidget {
  final bool isCraftsman;
  final bool isAdmin; // مضاف لتسجيل دخول المسؤول

  const AuthScreen({super.key, this.isCraftsman = false, this.isAdmin = false});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _professionController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  bool _isLogin = true;
  bool _isLoading = false;

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'البريد الإلكتروني مطلوب.';
    }
    String pattern = r'^[^@]+@[^@]+\.[^@]+';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return 'أدخل بريد إلكتروني صحيح.';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'كلمة المرور مطلوبة.';
    }
    if (value.length < 6) {
      return 'يجب أن تكون كلمة المرور 6 أحرف على الأقل.';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (_isLogin) return null;
    if (value == null || value.isEmpty) {
      return 'تأكيد كلمة المرور مطلوب.';
    }
    if (_passwordController.text != value) {
      return 'كلمة المرور غير متطابقة.';
    }
    return null;
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName مطلوب.';
    }
    return null;
  }

  Future<void> _submitAuthForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    // ****** التغيير هنا: استخدام البادئة AppAuth.Auth
    final authProvider =
        Provider.of<AppAuth.AuthProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      if (_isLogin) {
        // تسجيل الدخول
        UserCredential? userCredential = await authProvider.signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (userCredential?.user != null) {
          // جلب تفاصيل المستخدم بعد تسجيل الدخول بنجاح
          await userProvider.fetchUserDetails(userCredential!.user!.uid);
          // سيتم التعامل مع التنقل بواسطة SplashScreen بناءً على دور المستخدم
        }
      } else {
        // التسجيل
        String role = 'client';
        if (widget.isCraftsman) {
          role = 'craftsman';
        } else if (widget.isAdmin) {
          role = 'admin'; // إذا كان تسجيل المسؤول مسموحًا عبر هذه الشاشة
        }

        UserCredential? userCredential = await authProvider.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          role: role,
          firstName: _firstNameController.text.trim().isNotEmpty
              ? _firstNameController.text.trim()
              : null,
          lastName: _lastNameController.text.trim().isNotEmpty
              ? _lastNameController.text.trim()
              : null,
          phoneNumber: _phoneNumberController.text.trim().isNotEmpty
              ? _phoneNumberController.text.trim()
              : null,
          address: _addressController.text.trim().isNotEmpty
              ? _addressController.text.trim()
              : null,
          profession:
              widget.isCraftsman && _professionController.text.trim().isNotEmpty
                  ? _professionController.text.trim()
                  : null,
          bio: widget.isCraftsman && _bioController.text.trim().isNotEmpty
              ? _bioController.text.trim()
              : null,
        );

        if (userCredential?.user != null) {
          final UserModel newUser = UserModel(
            uid: userCredential!.user!.uid,
            email: _emailController.text.trim(),
            role: role,
            firstName: _firstNameController.text.trim().isNotEmpty
                ? _firstNameController.text.trim()
                : null,
            lastName: _lastNameController.text.trim().isNotEmpty
                ? _lastNameController.text.trim()
                : null,
            phoneNumber: _phoneNumberController.text.trim().isNotEmpty
                ? _phoneNumberController.text.trim()
                : null,
            address: _addressController.text.trim().isNotEmpty
                ? _addressController.text.trim()
                : null,
            profession: role == 'craftsman' &&
                    _professionController.text.trim().isNotEmpty
                ? _professionController.text.trim()
                : null,
            bio: role == 'craftsman' && _bioController.text.trim().isNotEmpty
                ? _bioController.text.trim()
                : null,
            isVerified: role == 'craftsman' ? false : null,
          );
          userProvider.setUser(newUser); // تحديث حالة مزود المستخدم
        }
      }
    } catch (e) {
      String errorMessage = 'حدث خطأ. الرجاء المحاولة مرة أخرى.';
      if (e is String) {
        errorMessage = e;
      } else if (e is Exception) {
        errorMessage = e.toString();
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneNumberController.dispose();
    _addressController.dispose();
    _professionController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // تحديد العنوان بناءً على تسجيل الدخول/التسجيل ونوع المستخدم
    String titleText;
    if (widget.isAdmin) {
      titleText = _isLogin ? 'تسجيل دخول مسؤول' : 'تسجيل مسؤول جديد';
    } else if (widget.isCraftsman) {
      titleText = _isLogin ? 'تسجيل دخول حرفي' : 'تسجيل حرفي جديد';
    } else {
      titleText = _isLogin ? 'تسجيل دخول عميل' : 'تسجيل عميل جديد';
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                titleText,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                decoration:
                    const InputDecoration(labelText: 'البريد الإلكتروني'),
                keyboardType: TextInputType.emailAddress,
                validator: _validateEmail,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'كلمة المرور'),
                obscureText: true,
                validator: _validatePassword,
              ),
              if (!_isLogin) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration:
                      const InputDecoration(labelText: 'تأكيد كلمة المرور'),
                  obscureText: true,
                  validator: _validateConfirmPassword,
                ),
                // عرض هذه الحقول فقط إذا لم يكن مسؤولاً (قد يكون للمسؤولين تدفق تسجيل مختلف)
                if (!widget.isAdmin) ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(labelText: 'الاسم الأول'),
                    validator: (value) =>
                        _validateRequired(value, 'الاسم الأول'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(labelText: 'اسم العائلة'),
                    validator: (value) =>
                        _validateRequired(value, 'اسم العائلة'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _phoneNumberController,
                    decoration: const InputDecoration(labelText: 'رقم الهاتف'),
                    keyboardType: TextInputType.phone,
                    validator: (value) =>
                        _validateRequired(value, 'رقم الهاتف'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(labelText: 'العنوان'),
                    validator: (value) => _validateRequired(value, 'العنوان'),
                  ),
                ],
                if (widget.isCraftsman) ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _professionController,
                    decoration: const InputDecoration(labelText: 'المهنة'),
                    validator: (value) => _validateRequired(value, 'المهنة'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _bioController,
                    decoration: const InputDecoration(
                        labelText: 'السيرة الذاتية (نبذة عنك)'),
                    maxLines: 3,
                  ),
                ],
              ],
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _submitAuthForm,
                      child: Text(_isLogin ? 'تسجيل الدخول' : 'إنشاء حساب'),
                    ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isLogin = !_isLogin;
                  });
                },
                child: Text(
                    _isLogin ? 'ليس لديك حساب؟ إنشاء حساب' : 'لدي حساب بالفعل'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
