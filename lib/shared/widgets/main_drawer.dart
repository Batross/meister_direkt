// lib/shared/widgets/main_drawer.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meisterdirekt/shared/providers/auth_provider.dart'; // استيراد AuthProvider
import 'package:meisterdirekt/shared/providers/user_provider.dart'; // استيراد UserProvider (لا يزال مطلوبًا لبيانات المستخدم)

class MainDrawer extends StatelessWidget {
  final String userName;
  final String userRole;
  final String? profilePicUrl;
  final VoidCallback? onSignOut; // الآن اختياري حيث أن المنطق أصبح داخليًا

  const MainDrawer({
    super.key,
    required this.userName,
    required this.userRole,
    this.profilePicUrl,
    this.onSignOut, // الآن اختياري
  });

  @override
  Widget build(BuildContext context) {
    String roleDisplay = '';
    if (userRole == 'client') {
      roleDisplay = 'Kunde';
    } else if (userRole == 'craftsman') {
      roleDisplay = 'Handwerker';
    } else if (userRole == 'admin') {
      roleDisplay = 'Admin';
    }

    return Drawer(
      child: Column(
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(
              userName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            accountEmail: Text(
              roleDisplay,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: ClipOval(
                child: profilePicUrl != null && profilePicUrl!.isNotEmpty
                    ? Image.network(
                        profilePicUrl!,
                        width: 90,
                        height: 90,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Image.asset(
                          'assets/images/default_profile.png', // صورة احتياطية محلية
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.person,
                                  size: 40, color: Colors.blue),
                        ),
                      )
                    : Image.asset(
                        'assets/images/default_profile.png', // صورة افتراضية محلية
                        width: 90,
                        height: 90,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.person,
                                size: 40, color: Colors.blue),
                      ),
              ),
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Startseite'),
            onTap: () {
              Navigator.pop(context); // إغلاق الدرج
              // الانتقال إلى الشاشة الرئيسية المناسبة بناءً على دور المستخدم
              if (userRole == 'client') {
                Navigator.pushReplacementNamed(context, '/customer-home');
              } else if (userRole == 'craftsman') {
                Navigator.pushReplacementNamed(context, '/artisan-home');
              } else if (userRole == 'admin') {
                Navigator.pushReplacementNamed(context, '/admin-home');
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Einstellungen'),
            onTap: () {
              Navigator.pop(context); // إغلاق الدرج
              print('تم الضغط على الإعدادات!');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Abmelden'),
            onTap: () async {
              Navigator.pop(context); // إغلاق الدرج أولاً
              await Provider.of<AuthProvider>(context, listen: false).signOut();
              // بعد تسجيل الخروج، انتقل مباشرة إلى صفحة اختيار الدور وامسح سجل التنقل
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/select-user-type',
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
