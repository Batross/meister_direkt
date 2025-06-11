// lib/customer/pages/customer_base_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/providers/user_provider.dart';
import '../../shared/widgets/customer_home_header.dart'; // الرأسية الموحدة
import '../../shared/widgets/main_drawer.dart'; // القائمة الجانبية
import '../widgets/customer_bottom_navbar.dart'; // شريط التنقل السفلي الخاص بالعميل

// استيراد صفحات العميل التي ستعرض في الـ PageView
import 'customer_my_orders_screen.dart';
import 'customer_create_order_screen.dart'; // هذه ستكون الصفحة الرئيسية للعميل
import 'customer_profile_screen.dart';

class CustomerBaseScreen extends StatefulWidget {
  const CustomerBaseScreen({super.key});

  @override
  State<CustomerBaseScreen> createState() => _CustomerBaseScreenState();
}

class _CustomerBaseScreenState extends State<CustomerBaseScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final PageController _pageController = PageController();
  // ابدأ بالصفحة الرئيسية للعميل (إنشاء طلب جديد)
  int _currentIndex = 1; // 0: MyOrders, 1: CreateOrder, 2: Profile

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
      // يمكنك عرض شاشة تحميل أو توجيه المستخدم إذا لم يكن هناك بيانات مستخدم
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      // لا نحتاج لـ AppBar هنا لأن الرأسية الموحدة ستوفرها
      // appBar: AppBar(
      //   title: const Text('meister direkt'),
      //   actions: [
      //     IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),
      //   ],
      // ),
      drawer: MainDrawer(
        userName: user.name,
        userRole: user.role,
        profilePicUrl: user.profilePicUrl,
        onSignOut: () {
          print(
              'Abmeldung von CustomerBaseScreen initiiert.'); // Sign out initiated
        },
      ),
      body: Column(
        children: [
          // الرأسية الموحدة للعميل
          CustomerHomeHeader(
            userName: user.name,
            profilePicUrl: user.profilePicUrl,
            onNotificationsPressed: () {
              print(
                  'Benachrichtigungen gedrückt (Kunde)'); // Notifications pressed
              // TODO: Navigate to customer notifications page
            },
            onSettingsPressed: () {
              print('Einstellungen gedrückt (Kunde)'); // Settings pressed
              // TODO: Navigate to customer settings page
            },
            onDrawerPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics:
                  const NeverScrollableScrollPhysics(), // لمنع السحب بين الصفحات
              children: const [
                // ترتيب الصفحات حسب الأزرار السفلية
                MyOrdersScreen(), // My Orders
                CreateOrderScreen(), // Create New Order (Hauptseite)
                ProfileScreen(), // Profile
              ],
            ),
          ),
        ],
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
