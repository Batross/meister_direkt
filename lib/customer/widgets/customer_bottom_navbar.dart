// lib/customer/widgets/customer_bottom_navbar.dart
import 'package:flutter/material.dart';

class CustomerBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const CustomerBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.list_alt),
          label: 'Meine Aufträge', // طلباتي
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_circle_outline),
          label: 'Neuer Auftrag', // إنشاء طلب (الصفحة الرئيسية)
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profil', // بروفايلي
        ),
      ],
      currentIndex: selectedIndex,
      selectedItemColor: Theme.of(context).primaryColor,
      unselectedItemColor: Colors.grey,
      onTap: onItemSelected,
    );
  }
}
