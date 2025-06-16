import 'package:flutter/material.dart';
import 'customer_create_order_screen.dart';
import 'customer_orders_screen.dart';
import 'customer_profile_screen.dart';

class CustomerMainLayout extends StatefulWidget {
  @override
  State<CustomerMainLayout> createState() => _CustomerMainLayoutState();
}

class _CustomerMainLayoutState extends State<CustomerMainLayout> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    CustomerCreateOrderScreen(),
    CustomerOrdersScreen(),
    CustomerProfileScreen(),
  ];

  final List<String> _titles = [
    'إضافة طلب',
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
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'الرئيسية'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'طلباتي'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'حسابي'),
        ],
      ),
    );
  }
}
