// lib/admin/admin_base_screen.dart
import 'package:flutter/material.dart';

class AdminBaseScreen extends StatelessWidget {
  const AdminBaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('لوحة تحكم المسؤول')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'مرحباً أيها المسؤول!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text('هذه هي واجهة المسؤول الرئيسية.'),
            // يمكنك إضافة أزرار أو عناصر تحكم خاصة بالمسؤول هنا
          ],
        ),
      ),
    );
  }
}
