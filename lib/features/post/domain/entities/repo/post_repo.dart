import 'package:social_bloc/features/auth/domain/entities/comment.dart';
import 'package:social_bloc/features/post/domain/entities/post.dart';

abstract class PostRepo {
  Future<List<Post>> fetchAllPosts();
  Future<void> createPosts(Post post);
  Future<void> deletePosts(String postId);
  Future<List<Post>> fetchPostsByUserId(String userId);
  Future<void> toggleLikePost(String postId, String userId);
  Future<void> addComment(String postId, Comment comment);
  Future<void> deleteComment(String postId, String commentId);
}
