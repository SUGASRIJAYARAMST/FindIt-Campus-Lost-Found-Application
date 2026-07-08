class AuthValidation {
  static String? validateRegistration({
    required String name,
    required String email,
    required String password,
    required String department,
    required String phoneNumber,
    String? confirmPassword,
    bool? acceptTerms,
  }) {
    if (name.trim().isEmpty) {
      return 'Name is required.';
    }

    final emailError = validateLoginEmail(email);
    if (emailError != null) return emailError;

    final passwordError = validateRegistrationPassword(password);
    if (passwordError != null) return passwordError;

    if (confirmPassword != null && password != confirmPassword) {
      return 'Passwords do not match.';
    }

    if (department.trim().isEmpty) {
      return 'Department is required.';
    }

    final phoneError = validatePhone(phoneNumber);
    if (phoneError != null) return phoneError;

    if (acceptTerms != true) {
      return 'Please accept the terms and conditions.';
    }

    return null;
  }

  static String? validateLogin({required String email, required String password}) {
    final emailError = validateLoginEmail(email);
    if (emailError != null) return emailError;

    final passwordError = validateLoginPassword(password);
    if (passwordError != null) return passwordError;

    return null;
  }

  static String? validateLoginEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email address.';
    }
    if (!_isValidEmail(value)) {
      return 'Please enter a valid email address.';
    }
    return null;
  }

  static String? validateLoginPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password.';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters.';
    }
    return null;
  }

  static String? validateRegistrationPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password.';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters.';
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password.';
    }
    if (value != password) {
      return 'Passwords do not match.';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your phone number.';
    }
    final phonePattern = RegExp(r'^[0-9+\-\s]{7,15}$');
    if (!phonePattern.hasMatch(value.trim())) {
      return 'Please enter a valid phone number.';
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your full name.';
    }
    return null;
  }

  static String? validateDepartment(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your department.';
    }
    return null;
  }

  static String? validateEmailForReset(String email) {
    return validateLoginEmail(email);
  }

  static bool _isValidEmail(String email) {
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return regex.hasMatch(email.trim());
  }
}
