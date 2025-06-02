import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sehatinapp/data/datasource/auth_repo.dart';
import 'logout_event.dart';
import 'logout_state.dart';

class LogoutBloc extends Bloc<LogoutEvent, LogoutState> {
  final AuthRepository authRepository;

  LogoutBloc({required this.authRepository}) : super(LogoutInitial()) {
    on<LogoutRequested>((event, emit) async {
      emit(LogoutLoading());
      try {
        await authRepository.logout();
        emit(LogoutSuccess());
      } catch (e) {
        emit(LogoutFailure(e.toString()));
      }
    });
  }
}
