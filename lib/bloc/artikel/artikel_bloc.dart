import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sehatinapp/data/datasource/auth_repo.dart';
import 'artikel_event.dart';
import 'artikel_state.dart';
import 'package:sehatinapp/data/model/respone/artikel_response.dart';

class ArtikelBloc extends Bloc<ArtikelEvent, ArtikelState> {
  final AuthRepository repository;

  ArtikelBloc(this.repository) : super(ArtikelInitial()) {
    on<FetchArticles>((event, emit) async {
      emit(ArtikelLoading());
      try {
        final token = await repository.getToken();
        if (token == null) throw Exception('Token tidak ditemukan');
        final List<Artikel> artikels = await repository.fetchArticles(token);
        final uniqueArtikels = artikels.toSet().toList();
        emit(ArtikelLoaded(uniqueArtikels));
      } catch (e) {
        emit(ArtikelError(e.toString()));
      }
    });
  }
}
