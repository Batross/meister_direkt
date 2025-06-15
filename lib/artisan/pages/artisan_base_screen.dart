// lib/artisan/pages/artisan_base_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meisterdirekt/shared/providers/user_provider.dart';
import 'package:meisterdirekt/shared/widgets/main_drawer.dart';
import 'package:meisterdirekt/data/models/user_model.dart'; // Import UserModel
import 'package:meisterdirekt/shared/providers/auth_provider.dart'; // Import AuthProvider for sign-out
import 'package:meisterdirekt/shared/widgets/artisan_home_header.dart';
import '../widgets/artisan_bottom_navbar.dart';
import 'artisan_find_requests_screen.dart';
import 'artisan_requests_screen.dart';
import 'artisan_profile_screen.dart';

class ArtisanBaseScreen extends StatefulWidget {
  const ArtisanBaseScreen({super.key});

  @override
  State<ArtisanBaseScreen> createState() => _ArtisanBaseScreenState();
}

class _ArtisanBaseScreenState extends State<ArtisanBaseScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    ArtisanFindRequestsScreen(),
    ArtisanMyOrdersScreen(),
    ArtisanProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final UserModel? user = userProvider.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: ArtisanHomeHeader(
        onNotificationsPressed: () {
          print('Notifications pressed (Artisan)');
        },
        onDrawerPressed: () {
          _scaffoldKey.currentState?.openDrawer();
        },
        onFilterPressed: () {
          print('Filter pressed (Artisan)');
        },
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: ArtisanBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemSelected: _onItemTapped,
      ),
      drawer: MainDrawer(
        userName: user.firstName ?? 'Artisan',
        userRole: user.role ?? 'craftsman',
        profilePicUrl: user.profileImageUrl,
        onSignOut: () async {
          // منطق تسجيل الخروج يتم التعامل معه في AuthProvider
          await Provider.of<AuthProvider>(context, listen: false).signOut();
        },
      ),
    );
  }
}
