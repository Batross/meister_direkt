import 'package:flutter/material.dart';
import 'artisan_find_requests_screen.dart';
import 'artisan_orders_screen.dart';
import 'artisan_profile_screen.dart';

class ArtisanMainLayout extends StatefulWidget {
  @override
  State<ArtisanMainLayout> createState() => _ArtisanMainLayoutState();
}

class _ArtisanMainLayoutState extends State<ArtisanMainLayout> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    ArtisanFindRequestsScreen(),
    ArtisanOrdersScreen(),
    ArtisanProfileScreen(),
  ];

  final List<String> _titles = [
    'بحث عن الطلبات',
    'طلباتي',
    'الملف الشخصي',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            pinned: false,
            expandedHeight: 80,
            title: Text(_titles[_currentIndex]),
            centerTitle: true,
            backgroundColor: Theme.of(context).primaryColor,
          ),
          SliverFillRemaining(
            child: _pages[_currentIndex],
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'الرئيسية'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'طلباتي'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'حسابي'),
        ],
      ),
    );
  }
}
