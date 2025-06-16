// lib/customer/pages/customer_base_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meisterdirekt/shared/providers/user_provider.dart';
import 'package:meisterdirekt/shared/widgets/main_drawer.dart';
import 'package:meisterdirekt/customer/widgets/customer_bottom_navbar.dart';
import 'package:meisterdirekt/data/models/user_model.dart';
import 'package:meisterdirekt/shared/providers/auth_provider.dart'; // Import AuthProvider for sign-out
import 'package:meisterdirekt/shared/utils/constants.dart';
import 'package:flutter/services.dart';

// استيراد صفحات العميل - تأكد من هذه المسارات
import 'package:meisterdirekt/customer/pages/customer_create_order_screen.dart';
import 'package:meisterdirekt/customer/pages/customer_my_orders_screen.dart';
import 'package:meisterdirekt/customer/pages/customer_profile_screen.dart';

class CustomerBaseScreen extends StatefulWidget {
  const CustomerBaseScreen({super.key});

  @override
  State<CustomerBaseScreen> createState() => _CustomerBaseScreenState();
}

class _CustomerBaseScreenState extends State<CustomerBaseScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 1;

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    Widget mainContent;
    if (_currentIndex == 1) {
      mainContent = CustomerCreateOrderScreen();
    } else if (_currentIndex == 0) {
      mainContent = const CustomerMyOrdersScreen();
    } else {
      mainContent = const CustomerProfileScreen();
    }

    return Scaffold(
      key: _scaffoldKey,
      drawer: MainDrawer(
        userName: user.firstName ?? 'Kunde',
        userRole: user.role,
        profilePicUrl: user.profileImageUrl,
        onSignOut: () async {
          await Provider.of<AuthProvider>(context, listen: false).signOut();
        },
      ),
      body: mainContent,
      bottomNavigationBar: CustomerBottomNavBar(
        selectedIndex: _currentIndex,
        onItemSelected: (index) {
          setState(() => _currentIndex = index);
        },
      ),
    );
  }
}
