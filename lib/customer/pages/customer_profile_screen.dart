// lib/customer/pages/customer_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meisterdirekt/shared/providers/user_provider.dart';
import 'package:meisterdirekt/data/models/user_model.dart';
import 'package:meisterdirekt/shared/utils/constants.dart'; // For AppColors (assuming it exists)

class CustomerProfileScreen extends StatelessWidget {
  const CustomerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final UserModel? user = userProvider.currentUser;

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      // تم إعادة إضافة Scaffold هنا كونه صفحة مستقلة في PageView
      appBar: AppBar(
        // شريط التطبيق الخاص بالشاشة (اختياري)
        title: const Text('ملفي الشخصي'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 70,
                    backgroundColor:
                        Theme.of(context).primaryColor.withOpacity(0.1),
                    child: ClipOval(
                      child: (user.profileImageUrl != null &&
                              user.profileImageUrl!.isNotEmpty)
                          ? Image.network(
                              user.profileImageUrl!,
                              width: 140,
                              height: 140,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Image.asset(
                                'assets/images/default_profile.png',
                                width: 140,
                                height: 140,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(
                                  Icons.person,
                                  size: 70,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            )
                          : Image.asset(
                              'assets/images/default_profile.png',
                              width: 140,
                              height: 140,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(
                                Icons.person,
                                size: 70,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      backgroundColor: Theme.of(context)
                          .secondaryHeaderColor, // أو أي لون مميز
                      radius: 20,
                      child: IconButton(
                        icon: const Icon(Icons.edit,
                            color: Colors.white, size: 20),
                        onPressed: () {
                          // TODO: تنفيذ منطق تغيير الصورة
                          print('تعديل صورة الملف الشخصي');
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim().isEmpty
                  ? user.email
                  : '${user.firstName ?? ''} ${user.lastName ?? ''}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              user.email,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 30),
            _buildProfileInfoRow(context, Icons.phone, 'رقم الهاتف',
                user.phoneNumber ?? 'لم يضف بعد'),
            _buildProfileInfoRow(context, Icons.location_on, 'العنوان',
                user.address ?? 'لم يضف بعد'),
            _buildProfileInfoRow(
                context,
                Icons.work,
                'الدور',
                user.role == 'client'
                    ? 'عميل'
                    : user.role == 'craftsman'
                        ? 'حرفي'
                        : 'غير معروف'),
            if (user.role == 'craftsman') ...[
              _buildProfileInfoRow(context, Icons.handyman, 'المهنة',
                  user.profession ?? 'لم يضف بعد'),
              _buildProfileInfoRow(context, Icons.info_outline,
                  'السيرة الذاتية', user.bio ?? 'لم يضف بعد'),
              _buildProfileInfoRow(context, Icons.verified_user, 'موثق',
                  user.isVerified == true ? 'نعم' : 'لا'),
            ],
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // TODO: الانتقال إلى شاشة تعديل الملف الشخصي
                print('تم الضغط على زر تعديل الملف الشخصي');
              },
              child: const Text('تعديل الملف الشخصي'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfoRow(
      BuildContext context, IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  value,
                  style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
