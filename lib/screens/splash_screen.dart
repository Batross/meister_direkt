// lib/shared/pages/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meisterdirekt/shared/providers/user_provider.dart';
import 'package:meisterdirekt/data/repositories/service_repository.dart'; // استيراد ServiceRepository

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // إضافة تأخير صغير لتأثير شاشة البداية
    await Future.delayed(const Duration(seconds: 2));

    final user = FirebaseAuth.instance.currentUser;
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final serviceRepository =
        Provider.of<ServiceRepository>(context, listen: false);

    // التأكد من تحميل الخدمات الأولية (يعمل مرة واحدة إذا كانت المجموعة فارغة)
    await serviceRepository.uploadInitialServices();

    if (user == null) {
      // المستخدم غير مسجل الدخول، الانتقال إلى شاشة اختيار نوع المستخدم
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/select-user-type');
    } else {
      // المستخدم مسجل الدخول، جلب تفاصيل المستخدم والانتقال إلى الشاشة الرئيسية المناسبة
      await userProvider
          .fetchUserDetails(user.uid); // التأكد من جلب تفاصيل المستخدم
      if (userProvider.currentUser != null) {
        String role = userProvider.currentUser!.role;
        if (!mounted) return;
        if (role == 'client') {
          Navigator.pushReplacementNamed(context, '/customer-home');
        } else if (role == 'craftsman') {
          Navigator.pushReplacementNamed(context, '/artisan-home');
        } else if (role == 'admin') {
          Navigator.pushReplacementNamed(context, '/admin-home');
        } else {
          // بديل إذا كان الدور غير معروف أو لم يتم تعيينه
          Navigator.pushReplacementNamed(context, '/select-user-type');
        }
      } else {
        // المستخدم موجود في Firebase Auth ولكن لا توجد تفاصيل في Firestore (لا ينبغي أن يحدث مع التسجيل الصحيح)
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/select-user-type');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // استبدل هذا بشعار تطبيقك / صورة شاشة البداية
            Image.asset('assets/images/meisterdirekt_logo.png', height: 150),
            const SizedBox(height: 20),
            const Text(
              'Meister Direkt',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 30),
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            const Text('جاري التحميل...', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
