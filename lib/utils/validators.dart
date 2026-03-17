import 'package:email_validator/email_validator.dart';

class Validators {
  // ── Email ─────────────────────────────────────────────────────────────────
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập email';
    }
    if (!EmailValidator.validate(value.trim())) {
      return 'Email không hợp lệ';
    }
    return null;
  }

  // ── Password ──────────────────────────────────────────────────────────────
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }
    if (value.length < 6) {
      return 'Mật khẩu tối thiểu 6 ký tự';
    }
    if (value.length > 72) {
      return 'Mật khẩu tối đa 72 ký tự';
    }
    return null;
  }

  // ── Confirm Password ──────────────────────────────────────────────────────
  static String? Function(String?) confirmPassword(String password) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return 'Vui lòng xác nhận mật khẩu';
      }
      if (value != password) {
        return 'Mật khẩu không khớp';
      }
      return null;
    };
  }

  // ── Required field ────────────────────────────────────────────────────────
  static String? required(String? value, [String fieldName = 'Trường này']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName không được để trống';
    }
    return null;
  }

  // ── Name ──────────────────────────────────────────────────────────────────
  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập tên';
    }
    if (value.trim().length < 2) {
      return 'Tên tối thiểu 2 ký tự';
    }
    if (value.trim().length > 50) {
      return 'Tên tối đa 50 ký tự';
    }
    return null;
  }

  // ── Task Title ────────────────────────────────────────────────────────────
  static String? taskTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập tên nhiệm vụ';
    }
    if (value.trim().length < 2) {
      return 'Tên nhiệm vụ tối thiểu 2 ký tự';
    }
    if (value.trim().length > 100) {
      return 'Tên nhiệm vụ tối đa 100 ký tự';
    }
    return null;
  }

  // ── Positive Integer ──────────────────────────────────────────────────────
  static String? positiveInt(String? value, [String fieldName = 'Giá trị']) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập $fieldName';
    }
    final parsed = int.tryParse(value.trim());
    if (parsed == null) {
      return '$fieldName phải là số nguyên';
    }
    if (parsed <= 0) {
      return '$fieldName phải lớn hơn 0';
    }
    return null;
  }

  // ── Age ───────────────────────────────────────────────────────────────────
  static String? age(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập tuổi';
    }
    final parsed = int.tryParse(value.trim());
    if (parsed == null) {
      return 'Tuổi phải là số nguyên';
    }
    if (parsed < 3 || parsed > 18) {
      return 'Tuổi phải từ 3 đến 18';
    }
    return null;
  }

  // ── Coin Reward ───────────────────────────────────────────────────────────
  static String? coinReward(int? value) {
    if (value == null || value < 1) {
      return 'Phần thưởng phải từ 1 Xu trở lên';
    }
    if (value > 1000) {
      return 'Phần thưởng tối đa 1000 Xu';
    }
    return null;
  }
}
