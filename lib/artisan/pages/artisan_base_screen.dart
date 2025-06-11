// lib/artisan/artisan_base_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../shared/providers/user_provider.dart';
import '../shared/widgets/artisan_home_header.dart'; // الرأسية الموحدة للحرفي
import '../shared/widgets/main_drawer.dart'; // القائمة الجانبية
import '../artisan/widgets/artisan_bottom_navbar.dart'; // ستحتاج لإنشاء هذا الودجت

// استيراد صفحات الحرفي التي ستعرض في الـ PageView
import 'pages/artisan_my_orders_screen.dart'; // افترض وجود هذه الصفحة (Meine Aufträge)
import 'pages/artisan_profile_screen.dart'; // افترض وجود هذه الصفحة (Profil)
import 'pages/artisan_find_requests_screen.dart'; // افترض وجود هذه الصفحة (Anfragen finden / البحث عن طلبات)

class ArtisanBaseScreen extends StatefulWidget {
  const ArtisanBaseScreen({super.key});

  @override
  State<ArtisanBaseScreen> createState() => _ArtisanBaseScreenState();
}

class _ArtisanBaseScreenState extends State<ArtisanBaseScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final PageController _pageController = PageController();
  int _currentIndex = 0; // 0: Meine Aufträge, 1: Profil, 2: Anfragen finden

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
      // لا نحتاج لـ AppBar هنا
      body: Column(
        children: [
          // الرأسية الموحدة للحرفي
          ArtisanHomeHeader(
            userName: user.name,
            profilePicUrl: user.profilePicUrl,
            isVerified: user.isVerified ?? false,
            onNotificationsPressed: () {
              print(
                  'Benachrichtigungen gedrückt (Handwerker)'); // Notifications pressed
              // TODO: Navigate to artisan notifications page
            },
            onSettingsPressed: () {
              print('Einstellungen gedrückt (Handwerker)'); // Settings pressed
              // TODO: Navigate to artisan settings page
            },
            onDrawerPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                // ترتيب الصفحات حسب الأزرار السفلية
                ArtisanMyOrdersScreen(), // Meine Aufträge
                ArtisanFindRequestsScreen(), // Anfragen finden
                ArtisanProfileScreen(), // Profil
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: ArtisanBottomNavBar(
        selectedIndex: _currentIndex,
        onItemSelected: (index) {
          setState(() => _currentIndex = index);
          _pageController.jumpToPage(index);
        },
      ),
    );
  }
}
