class LikeState {
  final Map<int, bool> likedStatus;
  final Map<int, int> likeCounts;

  LikeState({required this.likedStatus, required this.likeCounts});

  LikeState copyWith({Map<int, bool>? likedStatus, Map<int, int>? likeCounts}) {
    return LikeState(
      likedStatus: likedStatus ?? this.likedStatus,
      likeCounts: likeCounts ?? this.likeCounts,
    );
  }

  factory LikeState.initial() {
    return LikeState(likedStatus: {}, likeCounts: {});
  }
}
