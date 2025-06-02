abstract class RegisterEvent {}

class RegisterButtonPressed extends RegisterEvent {
  final String name;
  final String username;
  final String phone;
  final String email;
  final String password;

  RegisterButtonPressed({
    required this.name,
    required this.username,
    required this.phone,
    required this.email,
    required this.password,
  });
}
