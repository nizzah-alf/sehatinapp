import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sehatinapp/bloc/loginn/login_event.dart';
import 'package:sehatinapp/bloc/loginn/login_state.dart';
import 'package:sehatinapp/data/datasource/auth_repo.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepository authRepository;

  LoginBloc({required this.authRepository}) : super(LoginInitial()) {
    on<LoginButtonPrassed>((event, emit) async {
      emit(LoginLoading());
      try {
        await authRepository.login(event.email, event.password);
        emit(LoginSuccess());
      } catch (e) {
        emit(LoginFailure(message: e.toString()));
      }
    });
  }
}
