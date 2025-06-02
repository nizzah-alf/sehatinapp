abstract class LikeEvent {}

class LoadLikedArticlesEvent extends LikeEvent {}

class ToggleLikeEvent extends LikeEvent {
  final int articleId;
  ToggleLikeEvent(this.articleId);
}
