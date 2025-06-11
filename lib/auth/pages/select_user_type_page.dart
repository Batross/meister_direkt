import 'package:flutter/material.dart';
import '../login_page_customer.dart';
import '../login_page_artisan.dart';
import '../login_page_admin.dart';
import 'package:flutter_animate/flutter_animate.dart'; // لتأثيرات بصرية أجمل

class SelectUserTypePage extends StatefulWidget {
  const SelectUserTypePage({super.key});

  @override
  State<SelectUserTypePage> createState() => _SelectUserTypePageState();
}

class _SelectUserTypePageState extends State<SelectUserTypePage> {
  int _adminTapCount = 0;
  DateTime? _lastTapTime;

  // دالة لمعالجة الضغطات على الشعار للدخول كمسؤول
  void _handleAdminTap() {
    final now = DateTime.now();
    if (_lastTapTime == null ||
        now.difference(_lastTapTime!) > const Duration(seconds: 2)) {
      // إعادة تعيين العداد إذا كانت الفترة بين الضغطات طويلة
      _adminTapCount = 1;
    } else {
      _adminTapCount++;
    }
    _lastTapTime = now;

    if (_adminTapCount >= 5) {
      // بعد 5 ضغطات سريعة
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginPageAdmin()),
      );
      _adminTapCount = 0; // إعادة العداد بعد التوجيه
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2A5C82), Color(0xFF4A90E2)], // تدرج أزرق جذاب
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // الشعار مع GestureDetector ومنطق الضغطات للمشرف
              GestureDetector(
                onTap: _handleAdminTap,
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/meister_direkt_logo.png', // تأكد من وجود هذا الشعار
                      height: 150,
                    )
                        .animate()
                        .fade(duration: 800.ms)
                        .slideY(begin: -0.5, end: 0),
                    const SizedBox(height: 10),
                    const Text(
                      'Meister Direkt',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ).animate().fade(delay: 500.ms, duration: 800.ms),
                    const SizedBox(height: 10),
                    const Text(
                      'اضغط على الشعار 5 مرات للدخول كمسؤول',
                      style: TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 60),
              // زر "أنا زبون"
              SizedBox(
                width: 250,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const LoginPageCustomer()),
                    );
                  },
                  icon: const Icon(Icons.person, color: Color(0xFF2A5C82)),
                  label: const Text(
                    'أنا زبون',
                    style: TextStyle(fontSize: 18, color: Color(0xFF2A5C82)),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    elevation: 5,
                  ),
                )
                    .animate()
                    .fade(delay: 1000.ms, duration: 600.ms)
                    .slideX(begin: -1.0, end: 0),
              ),
              const SizedBox(height: 20),
              // زر "أنا حرفي"
              SizedBox(
                width: 250,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const LoginPageArtisan()),
                    );
                  },
                  icon: const Icon(Icons.engineering, color: Color(0xFF2A5C82)),
                  label: const Text(
                    'أنا حرفي',
                    style: TextStyle(fontSize: 18, color: Color(0xFF2A5C82)),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    elevation: 5,
                  ),
                )
                    .animate()
                    .fade(delay: 1200.ms, duration: 600.ms)
                    .slideX(begin: 1.0, end: 0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
