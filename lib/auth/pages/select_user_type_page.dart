// lib/auth/pages/select_user_type_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_page_customer.dart';
import 'login_page_artisan.dart';
import 'login_page_admin.dart';

class SelectUserTypePage extends StatefulWidget {
  const SelectUserTypePage({super.key});

  @override
  State<SelectUserTypePage> createState() => _SelectUserTypePageState();
}

class _SelectUserTypePageState extends State<SelectUserTypePage> {
  int _adminTapCount = 0;
  DateTime? _lastTapTime;

  void _handleAdminTap() {
    final now = DateTime.now();
    if (_lastTapTime == null ||
        now.difference(_lastTapTime!) > const Duration(seconds: 2)) {
      _adminTapCount = 1;
    } else {
      _adminTapCount++;
    }
    _lastTapTime = now;
    if (_adminTapCount >= 5) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginPageAdmin(),
        ),
      );
      _adminTapCount = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2A5C82), Color(0xFF4A90E2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _handleAdminTap,
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/meisterdirekt_logo.png',
                      width: 120,
                      height: 120,
                    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2),
                    const SizedBox(height: 10),
                    Text(
                      'MeisterDirekt',
                      style: GoogleFonts.cairo(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ).animate().fadeIn(duration: 800.ms, delay: 200.ms),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'Wählen Sie den Kontotyp',
                style: GoogleFonts.cairo(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ).animate().fadeIn(duration: 700.ms, delay: 300.ms),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _RoleCard(
                    title: 'Kunde',
                    icon: Icons.person_outline,
                    color: Colors.white,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LoginPageCustomer(),
                        ),
                      );
                    },
                  )
                      .animate()
                      .fadeIn(duration: 700.ms, delay: 400.ms)
                      .slideX(begin: -0.2),
                  const SizedBox(width: 24),
                  _RoleCard(
                    title: 'Handwerker',
                    icon: Icons.handyman_outlined,
                    color: Colors.white,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LoginPageArtisan(),
                        ),
                      );
                    },
                  )
                      .animate()
                      .fadeIn(duration: 700.ms, delay: 500.ms)
                      .slideX(begin: 0.2),
                ],
              ),
              const SizedBox(height: 60),
              Text(
                'Qualität. Schnelligkeit. Sicherheit.',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  color: Colors.white70,
                  fontWeight: FontWeight.w400,
                ),
              ).animate().fadeIn(duration: 800.ms, delay: 600.ms),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 130,
        height: 160,
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 54, color: Colors.white),
            const SizedBox(height: 18),
            Text(
              title,
              style: GoogleFonts.cairo(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
