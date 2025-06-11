import 'package:flutter/material.dart';

class CustomerHomeHeader extends StatelessWidget {
  final String userName;
  final String? profilePicUrl;
  final VoidCallback onNotificationsPressed;
  final VoidCallback onSettingsPressed;
  final VoidCallback onDrawerPressed; // لفتح الـ Drawer

  const CustomerHomeHeader({
    super.key,
    required this.userName,
    this.profilePicUrl,
    required this.onNotificationsPressed,
    required this.onSettingsPressed,
    required this.onDrawerPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // يمكن استخدام نسبة مئوية من الشاشة أو ارتفاع ثابت
      // لتحديد الارتفاع، مع الأخذ في الاعتبار أن 30% من الجزء العلوي
      // سيشمل أيضًا شريط البحث والإعلان لاحقًا.
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor, // أو أي لون خلفية يناسب التصميم
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: onDrawerPressed, // زر لفتح الـ Drawer
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications, color: Colors.white),
                    onPressed: onNotificationsPressed,
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings, color: Colors.white),
                    onPressed: onSettingsPressed,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                backgroundImage: profilePicUrl != null &&
                        profilePicUrl!.isNotEmpty
                    ? NetworkImage(profilePicUrl!) as ImageProvider
                    : const AssetImage(
                        'assets/images/default_profile.png'), // تأكد من وجود صورة افتراضية
                child: profilePicUrl == null || profilePicUrl!.isEmpty
                    ? const Icon(Icons.person, size: 30, color: Colors.grey)
                    : null,
              ),
              const SizedBox(width: 15),
              Text(
                'مرحباً، $userName!',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // فلتر البحث المتخصص
          TextField(
            readOnly: true, // لجعله غير قابل للكتابة المباشرة ويفتح شاشة بحث
            decoration: InputDecoration(
              hintText: 'ابحث عن خدمات أو حرفيين...',
              hintStyle: TextStyle(color: Colors.grey[600]),
              prefixIcon: const Icon(Icons.search, color: Color(0xFF2A5C82)),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
            ),
            onTap: () {
              // TODO: Navigate to a dedicated search page
              print('Search field tapped - Navigate to search page');
            },
          ),
        ],
      ),
    );
  }
}
