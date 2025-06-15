import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:meisterdirekt/shared/providers/user_provider.dart';

import 'package:meisterdirekt/data/models/user_model.dart'; // تأكد من استيراد UserModel هنا

import 'package:meisterdirekt/shared/utils/constants.dart'; // تأكد من المسار الصحيح

class ArtisanHomeHeader extends StatelessWidget {
  // تم تغيير بناء الكائن ليتناسب مع استخدام Provider

  final VoidCallback onNotificationsPressed;

  final VoidCallback onSettingsPressed;

  final VoidCallback onDrawerPressed;

  const ArtisanHomeHeader({
    super.key,
    required this.onNotificationsPressed,
    required this.onSettingsPressed,
    required this.onDrawerPressed,
  });

  @override
  Widget build(BuildContext context) {
    // استخدم context.watch للاستماع إلى التغييرات في UserProvider.

    final userProvider = context.watch<UserProvider>();

    final UserModel? currentUser =
        userProvider.currentUser; // الوصول إلى كائن المستخدم

    // التعامل مع حالة عدم وجود مستخدم

    if (currentUser == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),

        color: AppColors.primaryColor, // استخدام AppColors من constants.dart

        child: const SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Meister Direkt',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      );
    }

    // اسم المستخدم

    String displayName = 'Handwerker'; // قيمة افتراضية إذا لم يكن هناك اسم

    if (currentUser.firstName != null && currentUser.firstName!.isNotEmpty) {
      displayName = currentUser.firstName!;

      if (currentUser.lastName != null && currentUser.lastName!.isNotEmpty) {
        displayName += ' ${currentUser.lastName!}';
      }
    } else if (currentUser.email.isNotEmpty) {
      displayName = currentUser.email.split('@').first;
    }

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
      child: SafeArea(
        // إضافة SafeArea لتجنب التداخل مع نوتش الهاتف

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white, size: 30),
                  onPressed: onDrawerPressed,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.center, // توسيط الاسم

                    children: [
                      Text(
                        'Hello, $displayName!', // استخدام displayName المعالج

                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),

                        textAlign: TextAlign.center,
                      ),

                      // تم إزالة هذا الشرط الآن لأن displayName سيتضمن lastName إذا كان موجودًا

                      // إذا كنت تريد إظهار lastName في سطر منفصل، يمكنك تعديل هذا المنطق
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications,
                          color: Colors.white, size: 30),
                      onPressed: onNotificationsPressed,
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings,
                          color: Colors.white, size: 30),
                      onPressed: onSettingsPressed,
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 10), // تقليل المسافة

            // يمكنك إضافة حقل بحث أو أي عناصر أخرى هنا
          ],
        ),
      ),
    );
  }
}
