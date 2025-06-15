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
                                'Suche nach Aufträgen, Kunden oder Angeboten...',
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
          _pages[_selectedIndex],
        ],
      ),
      drawer: MainDrawer(
        userName: user.firstName ?? 'Handwerker',
        userRole: user.role, // الحقل ليس null أبداً
        profilePicUrl: user.profileImageUrl,
        onSignOut: () async {
          // منطق تسجيل الخروج يتم التعامل معه في AuthProvider
          await Provider.of<AuthProvider>(context, listen: false).signOut();
        },
      ),
      bottomNavigationBar: ArtisanBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemSelected: _onItemTapped,
      ),
    );
  }
}
