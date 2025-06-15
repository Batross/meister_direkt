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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // _pageController.jumpToPage(_currentIndex);
    });
  }

  @override
  void dispose() {
    // _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // استخدم CustomScrollView مع SliverAppBar، وبدون PageView
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
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            pinned: false,
            backgroundColor: Theme.of(context).primaryColor,
            elevation: 2,
            automaticallyImplyLeading: false,
            expandedHeight: 60,
            titleSpacing: 12,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left side: icons
                Row(
                  children: [
                    IconButton(
                      icon:
                          const Icon(Icons.menu, color: Colors.white, size: 24),
                      onPressed: () {
                        _scaffoldKey.currentState?.openDrawer();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.notifications,
                          color: Colors.white, size: 24),
                      onPressed: () {
                        // إشعار
                      },
                    ),
                  ],
                ),
                // Right side: app name
                const Text(
                  'MeisterDirekt',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(56),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          readOnly: true,
                          decoration: const InputDecoration(
                            hintText:
                                'Suche nach Dienstleistungen oder Handwerkern...',
                            hintStyle: TextStyle(fontSize: 13),
                            border: InputBorder.none,
                            prefixIcon:
                                Icon(Icons.search, color: Color(0xFF2A5C82)),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 0, horizontal: 8),
                          ),
                          onTap: () {},
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Material(
                      color: Colors.white,
                      shape: const CircleBorder(),
                      child: IconButton(
                        icon: const Icon(Icons.tune, color: Color(0xFF2A5C82)),
                        onPressed: () {
                          // فلتر
                        },
                        tooltip: 'Filter',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            systemOverlayStyle: SystemUiOverlayStyle.light,
          ),
          SliverFillRemaining(
            child: Builder(
              builder: (context) {
                // عرض الصفحة حسب الـ index
                if (_currentIndex == 0) {
                  return const CustomerMyOrdersScreen();
                } else if (_currentIndex == 1) {
                  return const CustomerCreateOrderScreen();
                } else {
                  return const CustomerProfileScreen();
                }
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomerBottomNavBar(
        selectedIndex: _currentIndex,
        onItemSelected: (index) {
          setState(() => _currentIndex = index);
        },
      ),
    );
  }
}
