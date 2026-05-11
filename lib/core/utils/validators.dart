/// Input validators for SisaSaku
class Validators {
  /// Validate nominal (should be > 0)
  static String? validateNominal(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nominal harus diisi';
    }

    final nominal = double.tryParse(value);
    if (nominal == null || nominal <= 0) {
      return 'Nominal harus lebih dari 0';
    }

    return null;
  }

  /// Validate category name
  static String? validateCategoryName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nama kategori harus diisi';
    }

    if (value.length < 2) {
      return 'Nama kategori minimal 2 karakter';
    }

    if (value.length > 50) {
      return 'Nama kategori maksimal 50 karakter';
    }

    return null;
  }

  /// Validate bill name
  static String? validateBillName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nama tagihan harus diisi';
    }

    if (value.length < 3) {
      return 'Nama tagihan minimal 3 karakter';
    }

    return null;
  }

  /// Validate email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email harus diisi';
    }

    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(value)) {
      return 'Email tidak valid';
    }

    return null;
  }

  /// Validate password
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password harus diisi';
    }

    if (value.length < 6) {
      return 'Password minimal 6 karakter';
    }

    return null;
  }
}
