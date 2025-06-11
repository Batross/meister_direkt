// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../data/models/user_model.dart';
import '../shared/providers/user_provider.dart';

// استيراد الشاشات الأساسية (Base Screens)
import '../customer/pages/customer_base_screen.dart'; // هذه هي الشاشة التي ستعرض شريط التنقل السفلي للعميل
import '../artisan/artisan_base_screen.dart'; // هذه هي الشاشة التي ستعرض شريط التنقل السفلي للحرفي
import '../admin/pages/admin_base_screen.dart'; // افترض وجودها

// استيراد شاشة اختيار نوع المستخدم
import '../auth/pages/select_user_type_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    // عرض شاشة البداية لمدة 3 ثوانٍ
    await Future.delayed(const Duration(seconds: 3));

    // التحقق من حالة المصادقة
    User? firebaseUser = FirebaseAuth.instance.currentUser;
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (firebaseUser != null) {
      try {
        await Future.wait([
          Future.microtask(() => userProvider.currentUser != null
              ? null
              : Future.delayed(const Duration(milliseconds: 500))),
        ]);

        if (userProvider.currentUser != null) {
          UserModel userModel = userProvider.currentUser!;
          String role = userModel.role;

          print('DEBUG: User role is: $role'); // للمساعدة في التصحيح

          if (role == 'client') {
            // توجيه العميل إلى CustomerBaseScreen
            _goToScreen(const CustomerBaseScreen());
          } else if (role == 'craftsman') {
            // توجيه الحرفي إلى ArtisanBaseScreen
            _goToScreen(const ArtisanBaseScreen());
          } else if (role == 'admin') {
            _goToScreen(const AdminBaseScreen());
          } else {
            print('DEBUG: Unknown role: $role');
            _goToScreen(const SelectUserTypePage());
          }
        } else {
          print(
              'DEBUG: User document not loaded or does not exist for UID: ${firebaseUser.uid}');
          _goToScreen(const SelectUserTypePage());
        }
      } catch (e) {
        print('ERROR: Failed to fetch user role via Provider: $e');
        _goToScreen(const SelectUserTypePage());
      }
    } else {
      print('DEBUG: No user logged in.');
      _goToScreen(const SelectUserTypePage());
    }
  }

  void _goToScreen(Widget screen) {
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (context) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/app_logo.png',
              height: 100,
              width: 100,
            ),
            const SizedBox(height: 20),
            const Text(
              'Meister Direkt',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(),
            const SizedBox(height: 10),
            const Text('Laden...'), // جاري التحميل...
          ],
        ),
      ),
    );
  }
}
