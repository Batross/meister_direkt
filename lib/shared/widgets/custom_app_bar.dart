// lib/shared/widgets/custom_app_bar.dart
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title; // لعنوان مخصص (مثل "الصفحة الرئيسية")
  final Widget? leadingIcon; // لأيقونة في البداية (مثل زر الرجوع أو القائمة)
  final List<Widget>?
      actions; // لمجموعة من الأيقونات في النهاية (مثل الإشعارات)
  final double height; // ارتفاع الشريط

  const CustomAppBar({
    super.key,
    this.title,
    this.leadingIcon,
    this.actions,
    this.height = kToolbarHeight, // الارتفاع الافتراضي لشريط التطبيق
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor:
          Theme.of(context).primaryColor, // استخدام لون الثيم الأساسي
      foregroundColor: Colors.white, // لون الأيقونات والنص
      title: title != null
          ? Text(
              title!,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            )
          : null,
      centerTitle: true, // لتوسيط العنوان
      leading: leadingIcon,
      actions: actions,
      elevation: 0, // إزالة الظل أسفل الشريط
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}
