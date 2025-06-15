// lib/shared/utils/app_validators.dart
class AppValidators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'البريد الإلكتروني مطلوب.';
    }
    // Regex for email validation
    String pattern = r'^[^@]+@[^@]+\.[^@]+';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return 'أدخل بريد إلكتروني صحيح.';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'كلمة المرور مطلوبة.';
    }
    if (value.length < 6) {
      return 'يجب أن تكون كلمة المرور 6 أحرف على الأقل.';
    }
    return null;
  }

  static String? validateConfirmPassword(
      String? password, String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'تأكيد كلمة المرور مطلوب.';
    }
    if (password != confirmPassword) {
      return 'كلمة المرور غير متطابقة.';
    }
    return null;
  }

  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'رقم الهاتف مطلوب.';
    }
    // Simple phone number validation (e.g., only digits, min 7 digits)
    String pattern = r'^[0-9]{7,}$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return 'أدخل رقم هاتف صحيح.';
    }
    return null;
  }

  static String? validateText(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName مطلوب.';
    }
    return null;
  }

  static String? validateNumber(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName مطلوب.';
    }
    if (double.tryParse(value) == null) {
      return 'الرجاء إدخال رقم صالح لـ $fieldName.';
    }
    return null;
  }
}
