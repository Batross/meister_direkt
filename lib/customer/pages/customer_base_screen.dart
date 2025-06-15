// lib/customer/pages/customer_base_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meisterdirekt/shared/providers/user_provider.dart';
import 'package:meisterdirekt/shared/widgets/main_drawer.dart';
import 'package:meisterdirekt/customer/widgets/customer_bottom_navbar.dart';
import 'package:meisterdirekt/data/models/user_model.dart';
import 'package:meisterdirekt/shared/providers/auth_provider.dart'; // Import AuthProvider for sign-out

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
  final PageController _pageController = PageController();
  int _currentIndex =
      1; // Standard: 0: Meine Bestellungen, 1: Bestellung erstellen, 2: Mein Profil

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pageController.jumpToPage(_currentIndex);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
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

    return Scaffold(
      key: _scaffoldKey,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // الهيدر مع البحث والفلاتر
          Container(
            color: Theme.of(context).primaryColor,
            padding:
                const EdgeInsets.only(top: 36, left: 12, right: 12, bottom: 8),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.menu,
                              color: Colors.white, size: 24),
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
                    Text(
                      'MeisterDirekt',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
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
              ],
            ),
          ),
          // محتوى الصفحة
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: const [
              CustomerMyOrdersScreen(),
              CustomerCreateOrderScreen(),
              CustomerProfileScreen(),
            ],
          ),
        ],
      ),
      drawer: MainDrawer(
        userName: user.firstName ?? 'Kunde',
        userRole: user.role, // الحقل ليس null أبداً
        profilePicUrl: user.profileImageUrl,
        onSignOut: () async {
          // منطق تسجيل الخروج يتم التعامل معه في AuthProvider
          await Provider.of<AuthProvider>(context, listen: false).signOut();
        },
      ),
      bottomNavigationBar: CustomerBottomNavBar(
        selectedIndex: _currentIndex,
        onItemSelected: (index) {
          setState(() => _currentIndex = index);
          _pageController.jumpToPage(index);
        },
      ),
    );
  }
}
