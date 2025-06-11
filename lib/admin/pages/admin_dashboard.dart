import 'package:flutter/material.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('لوحة تحكم المسؤول')),
      body: const Center(child: Text('هذه لوحة تحكم المسؤول (قيد الإنشاء)')),
    );
  }
}
