import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sehatinapp/data/datasource/like_repo.dart';
import 'like_event.dart';
import 'like_state.dart';

class LikeBloc extends Bloc<LikeEvent, LikeState> {
  final LikeRepository likeRepository;

  LikeBloc({required this.likeRepository}) : super(LikeState.initial()) {
    on<LoadLikedArticlesEvent>((event, emit) async {
      try {
        final likedArticles = await likeRepository.fetchLikedArticles();
        final likeCounts = await likeRepository.fetchLikeCounts();
        emit(LikeState(likedStatus: likedArticles, likeCounts: likeCounts));
      } catch (e) {
        emit(state);
      }
    });

    on<ToggleLikeEvent>((event, emit) async {
      try {
        await likeRepository.toggleLike(event.articleId);

        final likedArticles = await likeRepository.fetchLikedArticles();
        final likeCounts = await likeRepository.fetchLikeCounts();

        emit(LikeState(likedStatus: likedArticles, likeCounts: likeCounts));
      } catch (e) {
        print('Error toggle like: $e');
      }
    });
  }
}
