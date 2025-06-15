// lib/customer/pages/customer_my_orders_screen.dart
import 'package:flutter/material.dart';

class CustomerMyOrdersScreen extends StatelessWidget {
  const CustomerMyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment, size: 80, color: Colors.grey),
            SizedBox(height: 20),
            Text(
              'لا توجد طلبات حالياً.',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 10),
            Text(
              'يمكنك إنشاء طلب جديد من خلال صفحة "إنشاء طلب جديد".',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
