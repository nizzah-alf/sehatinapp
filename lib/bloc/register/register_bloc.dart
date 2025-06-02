import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sehatinapp/bloc/register/register_event.dart';
import 'package:sehatinapp/bloc/register/register_state.dart';
import 'package:sehatinapp/data/datasource/auth_repo.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final AuthRepository authRepository;

  RegisterBloc({required this.authRepository}) : super(RegisterInitial()) {
    on<RegisterButtonPressed>((event, emit) async {
      emit(RegisterLoading());
      try {
        final response = await authRepository.register(
          name: event.name,
          email: event.email,
          password: event.password,
        );

        if (response.containsKey('token')) {
          await authRepository.saveToken(response['token']);

          if (response.containsKey('user')) {
            final user = response['user'];
            if (user != null && user['name'] != null) {
              await authRepository.saveUserName(user['name']);
            }
          }
        }

        emit(
          RegisterSuccess(
            message: response['message'] ?? 'Registrasi berhasil',
          ),
        );
      } catch (e) {
        emit(RegisterFailure(message: e.toString()));
      }
    });
  }
}
