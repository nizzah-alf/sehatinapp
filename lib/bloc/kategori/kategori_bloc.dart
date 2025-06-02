import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sehatinapp/bloc/kategori/kategori_event.dart';
import 'package:sehatinapp/bloc/kategori/kategori_state.dart';
import 'package:sehatinapp/data/datasource/auth_repo.dart';
import 'package:sehatinapp/data/model/artikel_category_model.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final AuthRepository repository;

  CategoryBloc(this.repository) : super(CategoryInitial()) {
    on<FetchCategories>((event, emit) async {
      emit(CategoryLoading());
      try {
        final token = await repository.getToken();
        if (token == null) throw Exception('Token tidak ditemukan');

        final List<ArtikelCategory> categories = await repository
            .fetchCategories(token);
        emit(CategoryLoaded(categories));
      } catch (e) {
        emit(CategoryError(e.toString()));
      }
    });
  }
}
