import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart'; // استيراد حزمة provider
import 'firebase_options.dart';
import 'screens/splash_screen.dart'; // استيراد شاشة البداية
import 'shared/providers/user_provider.dart'; // استيراد مزود المستخدم
// import 'data/models/user_model.dart'; // ليس ضرورياً هنا مباشرة

// استيراد شاشات الأدوار الأساسية لتعريف الـ routes
import 'customer/pages/customer_create_order_screen.dart';
import 'artisan/pages/artisan_find_requests_screen.dart';
import 'admin/pages/admin_base_screen.dart'; // تأكد من وجودها
import 'auth/pages/select_user_type_page.dart'; // تأكد من وجودها

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    ChangeNotifierProvider(
      create: (context) => UserProvider(), // تهيئة مزود المستخدم
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meister Direkt',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.blue,
        ).copyWith(
          primary: const Color(0xFF2A5C82),
          secondary: const Color(0xFF4A90E2),
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          surface: Colors.white,
          onSurface: Colors.black87,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF2A5C82),
          centerTitle: true,
          elevation: 0,
        ),
        scaffoldBackgroundColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF2A5C82), width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          labelStyle: const TextStyle(color: Colors.grey),
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIconColor: const Color(0xFF2A5C82),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2A5C82),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 5,
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF4A90E2),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      // تم إزالة خاصية home هنا لحل التعارض مع المسار '/'
      initialRoute: '/', // تحديد المسار الأولي بشكل صريح
      routes: {
        // تم الإبقاء على المسار '/' الذي يشير إلى SplashScreen
        '/': (context) => const SplashScreen(),
        '/select-user-type': (context) => const SelectUserTypePage(),
        '/customer-home': (context) => const CustomerHomePage(),
        '/artisan-home': (context) => const ArtisanHomePage(),
        // '/admin-home': (context) => const AdminBaseScreen(), // إذا كان لديك Admin
      },
    );
  }
}
