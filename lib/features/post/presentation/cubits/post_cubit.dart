import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_bloc/features/auth/domain/entities/comment.dart';
import 'package:social_bloc/features/post/domain/entities/post.dart';
import 'package:social_bloc/features/post/domain/entities/repo/post_repo.dart';
import 'package:social_bloc/features/post/presentation/cubits/post_state.dart';
import 'package:social_bloc/features/storage/domain/storage_repo.dart';

class PostCubit extends Cubit<PostState> {
  final PostRepo postRepo;
  final StorageRepo storageRepo;

  PostCubit({required this.postRepo, required this.storageRepo})
    : super(PostInitial());

  Future<void> createPost(
    Post post, {
    String? imagePath,
    Uint8List? imageBytes,
    String? imageExtension,
  }) async {
    String? imageUrl;
    try {
      if (imagePath != null) {
        emit(PostUploading());
        imageUrl = await storageRepo.uploadPostImageMobile(imagePath, post.id);
      } else if (imageBytes != null) {
        emit(PostLoading());
        imageUrl = await storageRepo.uploadPostImageWeb(
          imageBytes,
          post.id,
          imageExtension,
        );
      }

      final newPost = post.copyWith(imageUrl: imageUrl);
      await postRepo.createPosts(newPost);
      await fetchAllPosts();
    } catch (e, stackTrace) {
      print('POST ERROR: $e');
      print('STACK TRACE: $stackTrace');
      emit(PostError(e.toString()));
    }
  }

  Future<void> fetchAllPosts() async {
    try {
      emit(PostLoading());
      final posts = await postRepo.fetchAllPosts();
      emit(PostsLoaded(posts));
    } catch (e, stackTrace) {
      print('POST ERROR: $e');
      print('STACK TRACE: $stackTrace');
      emit(PostError(e.toString()));
    }
  }

  Future<void> deletePost(String postId) async {
    await postRepo.deletePosts(postId);
    await fetchAllPosts();
  }

  Future<void> toggleLikePost(String postId, String userId) async {
    try {
      await postRepo.toggleLikePost(postId, userId);
    } catch (e) {
      emit(PostError("Failed to toggle like: $e"));
    }
  }

  //add comment to a post

  Future<void> addComment(String postId, Comment comment) async {
    try {
      await postRepo.addComment(postId, comment);
      await fetchAllPosts();
    } catch (e) {
      emit(PostError("Failed to add comment: $e"));
    }
  }

  //delete comment from a post
  Future<void> deleteComment(String postId, String commentId) async {
    try {
      await postRepo.deleteComment(postId, commentId);
      await fetchAllPosts();
    } catch (e) {
      emit(PostError("Failed to delete comment: $e"));
    }
  }
}
