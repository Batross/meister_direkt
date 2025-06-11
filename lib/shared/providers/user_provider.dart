// lib/shared/providers/user_provider.dart

import 'package:flutter/material.dart';
import 'package:meister_direkt/data/models/user_model.dart'; // تأكد من المسار الصحيح لكلاس User

class UserProvider with ChangeNotifier {
  User? _user; // متغير لتخزين كائن المستخدم، يمكن أن يكون null

  // Getter للوصول إلى كائن المستخدم
  User? get user => _user;

  // دالة لتعيين كائن المستخدم
  void setUser(User user) {
    _user = user;
    notifyListeners(); // لإعلام جميع الـ widgets التي تستمع لهذا الـ provider بحدوث تغيير
  }

  // دالة لمسح كائن المستخدم (مثلاً عند تسجيل الخروج)
  void clearUser() {
    _user = null;
    notifyListeners();
  }

  // يمكنك إضافة دوال أخرى هنا، مثل:
  // Future<void> loadUserFromFirestore(String uid) async { ... }
  // Future<void> signOut() async { ... }
}
