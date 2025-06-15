// lib/customer/widgets/customer_bottom_navbar.dart
import 'package:flutter/material.dart';
import 'package:meisterdirekt/shared/utils/constants.dart'; // For AppColors

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
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: onItemSelected,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primaryColor, // استخدام AppColors
          unselectedItemColor: Colors.grey[600],
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed, // لضمان تباعد ثابت
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.list_alt),
              label: 'طلباتي',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline),
              label: 'إنشاء طلب',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'ملفي',
            ),
          ],
        ),
      ),
    );
  }
}
