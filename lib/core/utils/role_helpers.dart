import 'package:mobile_2/core/entities/user.dart';

String getRoleDisplayName(UserRole role) {
  switch (role) {
    case UserRole.student:
      return 'Ученик';
    case UserRole.mentor:
      return 'Куратор';
    case UserRole.assistant:
      return 'Ассистент';
    case UserRole.teacher:
      return 'Преподаватель';
    case UserRole.admin:
      return 'Администратор';
  }
}
