// lib/shared/utils/app_validators.dart
class AppValidators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'E-Mail ist erforderlich.';
    }
    // Regex for email validation
    String pattern = r'^[^@]+@[^@]+\.[^@]+';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return 'Bitte geben Sie eine gültige E-Mail-Adresse ein.';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Passwort ist erforderlich.';
    }
    if (value.length < 6) {
      return 'Das Passwort muss mindestens 6 Zeichen lang sein.';
    }
    return null;
  }

  static String? validateConfirmPassword(
      String? password, String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Passwortbestätigung ist erforderlich.';
    }
    if (password != confirmPassword) {
      return 'Passwörter stimmen nicht überein.';
    }
    return null;
  }

  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Telefonnummer ist erforderlich.';
    }
    // Simple phone number validation (e.g., only digits, min 7 digits)
    String pattern = r'^[0-9]{7,}$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return 'Bitte geben Sie eine gültige Telefonnummer ein.';
    }
    return null;
  }

  static String? validateText(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName ist erforderlich.';
    }
    return null;
  }

  static String? validateNumber(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName ist erforderlich.';
    }
    if (double.tryParse(value) == null) {
      return 'Bitte geben Sie eine gültige Nummer für $fieldName ein.';
    }
    return null;
  }
}
