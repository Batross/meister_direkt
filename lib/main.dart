// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:meisterdirekt/firebase_options.dart';
import 'package:meisterdirekt/shared/providers/auth_provider.dart'
    as AppAuth; // ****** التغيير الحاسم هنا: إضافة 'as AppAuth' ******
import 'package:meisterdirekt/shared/providers/user_provider.dart';
import 'package:meisterdirekt/screens/splash_screen.dart';
import 'package:meisterdirekt/data/repositories/service_repository.dart';
import 'package:firebase_auth/firebase_auth.dart'; // استيراد FirebaseAuth

// استيراد شاشات الأدوار الأساسية لتعريف الـ routes
import 'package:meisterdirekt/customer/pages/customer_base_screen.dart';
import 'package:meisterdirekt/artisan/pages/artisan_base_screen.dart';
import 'package:meisterdirekt/admin/pages/admin_base_screen.dart';
import 'package:meisterdirekt/auth/pages/select_user_type_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print('Firebase initialization started...'); // طباعة للمتابعة

  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    print('Firebase initialized successfully!'); // طباعة للمتابعة

    // إضافة هذه الأسطر لتسجيل الدخول كمستخدم مجهول إذا لم يكن هناك مستخدم بالفعل
    final FirebaseAuth auth = FirebaseAuth.instance;
    if (auth.currentUser == null) {
      await auth.signInAnonymously();
      print('Signed in anonymously!'); // طباعة للمتابعة
    } else {
      print(
          'User already signed in: ${auth.currentUser!.uid}'); // طباعة للمتابعة
    }
  } catch (e) {
    print(
        'Error during Firebase initialization or anonymous sign-in: $e'); // طباعة للأخطاء
    // يمكنك إضافة SnackBar أو عرض رسالة خطأ هنا للمستخدم
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // استخدام MultiProvider لتقديم عدة مزودات (providers)
      providers: [
        ChangeNotifierProvider(
            create: (_) => AppAuth
                .AuthProvider()), // ****** التغيير هنا: استخدام AppAuth.AuthProvider ******
        ChangeNotifierProvider(create: (_) => UserProvider()),
        Provider<ServiceRepository>(create: (_) => ServiceRepository()),
      ],
      child: MaterialApp(
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
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/select-user-type': (context) => const SelectUserTypePage(),
          '/customer-home': (context) => const CustomerBaseScreen(),
          '/artisan-home': (context) => const ArtisanBaseScreen(),
          '/admin-home': (context) => const AdminBaseScreen(),
        },
      ),
    );
  }
}
