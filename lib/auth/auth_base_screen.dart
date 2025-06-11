import 'package:flutter/material.dart';

class AuthBaseScreen extends StatelessWidget {
  final Widget child;

  const AuthBaseScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          // تم تغيير 'const' إلى 'null' أو حذفها
          color: Colors.grey[200], // يمكنك تخصيص هذا اللون
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: child,
          ),
        ),
      ),
    );
  }
}
