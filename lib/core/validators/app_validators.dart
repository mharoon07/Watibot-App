class AppValidators {
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    if (value.trim().length < 3) {
      return 'Name must be at least 3 characters';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    // Basic email validation
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Minimum 8 characters required';
    }
    // if (!RegExp(r'[A-Z]').hasMatch(value)) {
    //   return 'Must contain at least one uppercase letter';
    // }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Must contain at least one lowercase letter';
    }
    // if (!RegExp(r'[0-9]').hasMatch(value)) {
    //   return 'Must contain at least one number';
    // }
    // if (!RegExp(r'[!@#\$&*~]').hasMatch(value)) {
    //   return 'Must contain at least one special character';
    // }
    return null;
  }
}
