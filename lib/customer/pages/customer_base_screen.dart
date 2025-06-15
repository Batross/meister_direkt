// lib/customer/pages/customer_base_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meisterdirekt/shared/providers/user_provider.dart';
import 'package:meisterdirekt/shared/widgets/main_drawer.dart';
import 'package:meisterdirekt/customer/widgets/customer_bottom_navbar.dart';
import 'package:meisterdirekt/data/models/user_model.dart';
import 'package:meisterdirekt/shared/widgets/customer_home_header.dart';
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
  int _currentIndex = 1; // الافتراضي: 0: My Orders, 1: Create Order, 2: Profile

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

  void _handleFilterPressed() {
    print('Filter button pressed!');
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
      body: CustomScrollView(
        slivers: [
          CustomerHomeHeader(
            onNotificationsPressed: () {
              print('Notifications pressed (Customer)');
            },
            onDrawerPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
            onFilterPressed: _handleFilterPressed,
          ),
          SliverFillRemaining(
            child: PageView(
              controller: _pageController,
              physics:
                  const NeverScrollableScrollPhysics(), // لمنع التمرير اليدوي بين الصفحات
              children: const [
                // ملاحظة: هذه الفئات يجب أن تكون معرفة في ملفاتها الخاصة
                // ومستوردة بشكل صحيح في أعلى هذا الملف.
                CustomerMyOrdersScreen(), // طلباتي (فهرس 0)
                CustomerCreateOrderScreen(), // إنشاء طلب جديد (الصفحة الرئيسية) (فهرس 1)
                CustomerProfileScreen(), // ملفي الشخصي (فهرس 2)
              ],
            ),
          ),
        ],
      ),
      drawer: MainDrawer(
        userName: user.firstName ?? 'العميل',
        userRole: user.role ?? 'customer',
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
