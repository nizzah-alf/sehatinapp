abstract class LoginEvent {}

class LoginButtonPrassed extends LoginEvent {
  final String email;
  final String password;

  LoginButtonPrassed({required this.email, required this.password});
}
