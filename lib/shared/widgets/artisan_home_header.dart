// lib/artisan/widgets/artisan_home_header.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // يجب استيراد provider
import 'package:meister_direkt/shared/providers/user_provider.dart'; // تأكد من المسار الصحيح
import 'package:meister_direkt/shared/utils/constants.dart'; // إذا كنت تستخدم هذا الملف لـ AppColors أو غيرها

class ArtisanHomeHeader extends StatelessWidget {
  const ArtisanHomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    // استخدم context.watch للاستماع إلى التغييرات في UserProvider.
    // هذه هي الطريقة الموصى بها في Provider v6+.
    final userProvider = context.watch<UserProvider>();
    final currentUser = userProvider.user; // الوصول إلى كائن المستخدم

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: AppColors
            .primaryColor, // تأكد من تعريف AppColors.primaryColor في constants.dart
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    // الوصول الآمن إلى firstName باستخدام ?.
                    // إذا كان currentUser أو firstName null، سيعرض 'Artisan'
                    'Hello, ${currentUser?.firstName ?? 'Artisan'}!',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (currentUser?.lastName != null &&
                      currentUser!.lastName.isNotEmpty)
                    Text(
                      // عرض lastName فقط إذا كان موجودًا وغير فارغ
                      currentUser.lastName,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.white70,
                              ),
                    ),
                ],
              ),
              // يمكنك هنا إضافة صورة الملف الشخصي إذا كانت موجودة
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                backgroundImage: currentUser?.profileImageUrl != null
                    ? NetworkImage(currentUser!.profileImageUrl!)
                    : const AssetImage('assets/images/default_profile.jpg')
                        as ImageProvider, // تأكد من وجود صورة افتراضية
              ),
            ],
          ),
          const SizedBox(height: 20),
          // يمكنك إضافة حقل بحث أو أي عناصر أخرى هنا
          // مثال:
          // TextField(
          //   decoration: InputDecoration(
          //     hintText: 'Search services...',
          //     fillColor: Colors.white,
          //     filled: true,
          //     border: OutlineInputBorder(
          //       borderRadius: BorderRadius.circular(10),
          //       borderSide: BorderSide.none,
          //     ),
          //     prefixIcon: Icon(Icons.search),
          //   ),
          // ),
        ],
      ),
    );
  }
}
