// lib/artisan/pages/artisan_base_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meisterdirekt/shared/providers/user_provider.dart';
import 'package:meisterdirekt/shared/widgets/main_drawer.dart';
import 'package:meisterdirekt/data/models/user_model.dart'; // Import UserModel
import 'package:meisterdirekt/shared/providers/auth_provider.dart'; // Import AuthProvider for sign-out

class ArtisanBaseScreen extends StatefulWidget {
  const ArtisanBaseScreen({super.key});

  @override
  State<ArtisanBaseScreen> createState() => _ArtisanBaseScreenState();
}

class _ArtisanBaseScreenState extends State<ArtisanBaseScreen> {
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
        title: const Text('لوحة تحكم الحرفي'),
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
            Text('مرحباً بك، ${user.firstName ?? 'الحرفي'}!',
                style: const TextStyle(fontSize: 24)),
            if (user.profession != null && user.profession!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('مهنتك: ${user.profession}',
                    style: const TextStyle(fontSize: 18, color: Colors.grey)),
              ),
            if (user.isVerified == true)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('حسابك موثق!',
                    style: TextStyle(fontSize: 16, color: Colors.green)),
              )
            else
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('حسابك غير موثق بعد.',
                    style: TextStyle(fontSize: 16, color: Colors.orange)),
              ),
            const SizedBox(height: 20),
            const Text('هذه صفحة الحرفي الرئيسية.',
                style: TextStyle(fontSize: 18)),
            // إضافة محتوى خاص بالحرفي هنا، مثل قائمة الطلبات، العروض، إلخ.
          ],
        ),
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
