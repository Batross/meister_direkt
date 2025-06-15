import 'package:flutter/material.dart';

class ArtisanOrdersScreen extends StatelessWidget {
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
