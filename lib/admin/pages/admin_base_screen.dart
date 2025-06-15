// lib/admin/pages/admin_base_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meisterdirekt/shared/providers/user_provider.dart';
import 'package:meisterdirekt/shared/widgets/main_drawer.dart';
import 'package:meisterdirekt/data/models/user_model.dart';
import 'package:meisterdirekt/shared/providers/auth_provider.dart'; // Import AuthProvider

class AdminBaseScreen extends StatefulWidget {
  const AdminBaseScreen({super.key});

  @override
  State<AdminBaseScreen> createState() => _AdminBaseScreenState();
}

class _AdminBaseScreenState extends State<AdminBaseScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
      appBar: AppBar(
        title: const Text('لوحة تحكم المسؤول'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('مرحباً بك، ${user.firstName ?? 'المسؤول'}!',
                style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            const Text('هذه صفحة المسؤول الرئيسية.',
                style: TextStyle(fontSize: 18)),
            // إضافة محتوى خاص بالمسؤول هنا، مثل إدارة المستخدمين، الخدمات، إلخ.
          ],
        ),
      ),
      drawer: MainDrawer(
        userName: user.firstName ?? 'Admin',
        userRole: user.role ?? 'admin',
        profilePicUrl: user.profileImageUrl,
        onSignOut: () async {
          await Provider.of<AuthProvider>(context, listen: false).signOut();
        },
      ),
    );
  }
}
