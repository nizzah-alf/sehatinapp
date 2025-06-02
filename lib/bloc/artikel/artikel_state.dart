import 'package:sehatinapp/data/model/respone/artikel_response.dart';

abstract class ArtikelState {}

class ArtikelInitial extends ArtikelState {}

class ArtikelLoading extends ArtikelState {}

class ArtikelLoaded extends ArtikelState {
  final List<Artikel> artikels;
  ArtikelLoaded(this.artikels);
}

class ArtikelError extends ArtikelState {
  final String message;
  ArtikelError(this.message);
}
