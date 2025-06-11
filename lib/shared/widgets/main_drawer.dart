import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/providers/user_provider.dart'; // لـ UserProvider

class MainDrawer extends StatelessWidget {
  final String userName;
  final String userRole;
  final String? profilePicUrl;
  final VoidCallback onSignOut;

  const MainDrawer({
    super.key,
    required this.userName,
    required this.userRole,
    this.profilePicUrl,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    // يمكنك الوصول إلى UserProvider هنا إذا أردت تحديث حالة المستخدم أو معلوماته
    // final userProvider = Provider.of<UserProvider>(context, listen: false);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(
              userName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(
              userRole == 'client' ? 'عميل' : 'حرفي', // يمكن عرض الإيميل الفعلي
              style: const TextStyle(fontSize: 16),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage:
                  profilePicUrl != null && profilePicUrl!.isNotEmpty
                      ? NetworkImage(profilePicUrl!) as ImageProvider
                      : const AssetImage('assets/images/default_profile.png'),
              child: profilePicUrl == null || profilePicUrl!.isEmpty
                  ? const Icon(Icons.person, size: 40, color: Colors.grey)
                  : null,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('الرئيسية'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              // يمكنك الانتقال إلى الشاشة الرئيسية إذا لم تكن عليها بالفعل
              // Navigator.of(context).pushReplacementNamed('/home');
            },
          ),
          if (userRole == 'client') ...[
            ListTile(
              leading: const Icon(Icons.build_circle),
              title: const Text('طلباتي'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                // TODO: Navigate to client's requests page
                print('Navigate to Client Requests');
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text('الحرفيون المفضلون'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                // TODO: Navigate to favorite artisans page
                print('Navigate to Favorite Artisans');
              },
            ),
          ],
          if (userRole == 'craftsman') ...[
            ListTile(
              leading: const Icon(Icons.work),
              title: const Text('طلبات الخدمات'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                // TODO: Navigate to artisan's available requests
                print('Navigate to Artisan Available Requests');
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('سجل العمليات'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                // TODO: Navigate to artisan's job history
                print('Navigate to Artisan Job History');
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_balance_wallet),
              title: const Text('المدفوعات والأرباح'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                // TODO: Navigate to artisan's earnings page
                print('Navigate to Artisan Earnings');
              },
            ),
          ],
          const Divider(),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('ملفي الشخصي'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              // TODO: Navigate to profile page
              print('Navigate to Profile');
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('الإعدادات'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              // TODO: Navigate to settings page
              print('Navigate to Settings');
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('عن التطبيق'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              // TODO: Navigate to about page
              print('Navigate to About');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'تسجيل الخروج',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () async {
              Navigator.pop(context); // Close the drawer first
              // قم بتسجيل الخروج من Firebase Auth ومسح بيانات المستخدم من Provider
              await Provider.of<UserProvider>(context, listen: false).signOut();
              // توجيه المستخدم إلى شاشة تسجيل الدخول أو اختيار النوع
              Navigator.of(context)
                  .pushReplacementNamed('/'); // أو إلى شاشة تسجيل الدخول
            },
          ),
        ],
      ),
    );
  }
}
