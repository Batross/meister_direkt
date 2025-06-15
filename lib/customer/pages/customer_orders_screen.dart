import 'package:flutter/material.dart';

class CustomerOrdersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(title: Text('طلباتي')),
        // ... بقية الطلبات
      ],
    );
  }
}
