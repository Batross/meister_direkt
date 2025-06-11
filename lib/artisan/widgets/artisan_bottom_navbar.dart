// lib/artisan/widgets/artisan_bottom_navbar.dart
import 'package:flutter/material.dart';

class ArtisanBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const ArtisanBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.handyman), // أو أي أيقونة مناسبة لـ "Meine Aufträge"
          label: 'Meine Aufträge', // طلباتي
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label:
              'Anfragen finden', // البحث عن طلبات (ستكون ArtisanFindRequestsScreen)
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
