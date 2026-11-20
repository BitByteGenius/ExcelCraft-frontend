class Validators {
  static String? requiredField(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email address is required';
    }
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? mobile(String? value, {bool required = true}) {
    if (value == null || value.trim().isEmpty) {
      if (required) return 'Mobile number is required';
      return null;
    }
    final clean = value.replaceAll(RegExp(r'[\s-]'), '');
    if (clean.length < 10 || clean.length > 15) {
      return 'Mobile number must be 10 to 15 digits';
    }
    return null;
  }

  static String? udiseCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'UDISE Code is required';
    }
    if (value.trim().length < 8) {
      return 'UDISE Code must be at least 8 digits';
    }
    return null;
  }
}
