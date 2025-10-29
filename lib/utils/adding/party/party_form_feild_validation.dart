class PartyValidations {
  /// Validates the Party Name field
  static String? validatePartyName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Party Name is required';
    }
    if (value.trim().length < 2) {
      return 'Party Name must be at least 2 characters long';
    }
    if (value.trim().length > 50) {
      return 'Party Name cannot exceed 50 characters';
    }
    return null;
  }

  /// Validates the Contact Number field
  static String? validateContactNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Contact Number is required';
    }
    // Remove any non-digit characters for validation (e.g., spaces, dashes)
    final cleanedValue = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanedValue.length < 10 || cleanedValue.length > 15) {
      return 'Contact Number must be between 10 and 15 digits';
    }
    if (!RegExp(r'^\+?[1-9]\d{9,14}$').hasMatch(cleanedValue)) {
      return 'Enter a valid contact number';
    }
    return null;
  }

  /// Validates the Opening Balance field
  static String? validateOpeningBalance(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Opening Balance is required';
    }
    final balance = double.tryParse(value);
    if (balance == null) {
      return 'Enter a valid number';
    }
    if (balance < 0) {
      return 'Opening Balance cannot be negative';
    }
    if (balance > 10000000) {
      return 'Opening Balance cannot exceed 10,000,000';
    }
    return null;
  }

  /// Validates the Billing Address field
  static String? validateBillingAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Billing Address is required';
    }
    if (value.trim().length < 5) {
      return 'Billing Address must be at least 5 characters long';
    }
    if (value.trim().length > 200) {
      return 'Billing Address cannot exceed 200 characters';
    }
    return null;
  }

  /// Validates the Email field
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Email is optional
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }
}