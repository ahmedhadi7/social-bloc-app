import 'package:social_bloc/features/post/domain/entities/post.dart';

abstract class PostState {}

class PostInitial extends PostState {}

class PostLoading extends PostState {}

class PostUploading extends PostState {}

class PostError extends PostState {
  final String message;
  PostError(this.message);
}

class PostsLoaded extends PostState {
  final List<Post> posts;
  PostsLoaded(this.posts);
}
