abstract class AuthEvent {}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  final String captchaToken; // Sesuai requirement backend
  LoginRequested({required this.email, required this.password, required this.captchaToken});
}

class RegisterRequested extends AuthEvent {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  RegisterRequested({required this.firstName, required this.lastName, required this.email, required this.password});
}

class SendResetCodeRequested extends AuthEvent {
  final String email;
  SendResetCodeRequested(this.email);
}

class VerifyResetCodeRequested extends AuthEvent {
  final String email;
  final String code;
  VerifyResetCodeRequested({required this.email, required this.code});
}

class ResetPasswordRequested extends AuthEvent {
  final String email;
  final String code;
  final String password;
  final String confirmPassword;
  ResetPasswordRequested({required this.email, required this.code, required this.password, required this.confirmPassword});
}

class LogoutRequested extends AuthEvent {}