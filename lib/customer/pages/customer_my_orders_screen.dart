// lib/customer/pages/my_orders_screen.dart
import 'package:flutter/material.dart';
import '../../shared/widgets/custom_app_bar.dart'; // استيراد CustomAppBar

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'طلباتي', // عنوان مخصص لهذه الصفحة
        leadingIcon: IconButton(
          icon: const Icon(Icons.arrow_back), // زر رجوع
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search), // أيقونة بحث مثلاً
            onPressed: () {
              print('Search orders');
            },
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'لا توجد طلبات سابقة لعرضها.',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      ),
    );
  }
}
