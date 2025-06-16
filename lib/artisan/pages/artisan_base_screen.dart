// lib/artisan/pages/artisan_base_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meisterdirekt/shared/providers/user_provider.dart';
import 'package:meisterdirekt/shared/widgets/main_drawer.dart';
import 'package:meisterdirekt/data/models/user_model.dart'; // Import UserModel
import 'package:meisterdirekt/shared/providers/auth_provider.dart'; // Import AuthProvider for sign-out
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

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final UserModel? user = userProvider.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    Widget mainContent;
    if (_selectedIndex == 0) {
      mainContent = ArtisanFindRequestsScreen();
    } else if (_selectedIndex == 1) {
      mainContent = const ArtisanMyOrdersScreen();
    } else {
      mainContent = const ArtisanProfileScreen();
    }

    return Scaffold(
      key: _scaffoldKey,
      body: mainContent,
      drawer: MainDrawer(
        userName: user.firstName ?? 'Handwerker',
        userRole: user.role,
        profilePicUrl: user.profileImageUrl,
        onSignOut: () async {
          await Provider.of<AuthProvider>(context, listen: false).signOut();
        },
      ),
      bottomNavigationBar: ArtisanBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemSelected: (index) {
          setState(() => _selectedIndex = index);
        },
      ),
    );
  }
}
