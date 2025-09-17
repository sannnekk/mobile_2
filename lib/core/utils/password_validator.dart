/// Utility class for password validation
class PasswordValidator {
  /// Validates a password and returns an error message if invalid, null if valid
  static String? validate(String? password) {
    if (password == null || password.isEmpty) {
      return 'Пароль обязателен';
    }
    if (password.length < 8) {
      return 'Пароль должен содержать минимум 8 символов';
    }
    if (!RegExp(r'(?=.*[a-z])').hasMatch(password)) {
      return 'Пароль должен содержать строчную букву';
    }
    if (!RegExp(r'(?=.*[A-Z])').hasMatch(password)) {
      return 'Пароль должен содержать заглавную букву';
    }
    if (!RegExp(r'(?=.*\d)').hasMatch(password)) {
      return 'Пароль должен содержать цифру';
    }
    return null;
  }

  /// Validates password confirmation by comparing with original password
  static String? validateConfirmation(
    String? confirmation,
    String originalPassword,
  ) {
    if (confirmation == null || confirmation.isEmpty) {
      return 'Подтверждение пароля обязательно';
    }
    if (confirmation != originalPassword) {
      return 'Пароли не совпадают';
    }
    return null;
  }

  /// Returns a list of password requirements with their current status
  static List<PasswordRequirement> getRequirements(String password) {
    return [
      PasswordRequirement(
        description: 'Минимум 8 символов',
        isMet: password.length >= 8,
      ),
      PasswordRequirement(
        description: 'Строчная буква (a-z)',
        isMet: RegExp(r'(?=.*[a-z])').hasMatch(password),
      ),
      PasswordRequirement(
        description: 'Заглавная буква (A-Z)',
        isMet: RegExp(r'(?=.*[A-Z])').hasMatch(password),
      ),
      PasswordRequirement(
        description: 'Цифра (0-9)',
        isMet: RegExp(r'(?=.*\d)').hasMatch(password),
      ),
    ];
  }

  /// Checks if password meets all requirements
  static bool isValid(String password) {
    return validate(password) == null;
  }
}

/// Represents a single password requirement
class PasswordRequirement {
  final String description;
  final bool isMet;

  const PasswordRequirement({required this.description, required this.isMet});
}
