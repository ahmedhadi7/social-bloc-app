import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_bloc/features/auth/domain/entities/comment.dart';
import 'package:social_bloc/features/post/domain/entities/post.dart';
import 'package:social_bloc/features/post/domain/entities/repo/post_repo.dart';

class FirebasePostRepo implements PostRepo {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  //store the post in a collection called 'posts'
  final CollectionReference postCollection = FirebaseFirestore.instance
      .collection('posts');

  @override
  Future<void> createPosts(Post post) async {
    try {
      await postCollection.doc(post.id).set(post.toJson());
    } catch (e) {
      throw Exception("Error creating post: $e");
    }
  }

  @override
  Future<void> deletePosts(String postId) async {
    await postCollection.doc(postId).delete();
  }

  @override
  Future<List<Post>> fetchAllPosts() async {
    try {
      //get all posts with most recent posts at the top
      final postsSnapshot = await postCollection
          .orderBy('timestamp', descending: true)
          .get();

      //convert each firestore document from json -> list of posts
      final List<Post> allPosts = postsSnapshot.docs
          .map((doc) => Post.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
      return allPosts;
    } catch (e) {
      throw Exception("Error fetching posts: $e");
    }
  }

  @override
  Future<List<Post>> fetchPostsByUserId(String userId) async {
    try {
      //fetch posts snapshot with this uid
      final postsSnapshot = await postCollection
          .where('userId', isEqualTo: userId)
          .get();

      //convert firestore document from json -> list of posts
      final userPosts = postsSnapshot.docs
          .map((doc) => Post.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      return userPosts;
    } catch (e) {
      throw Exception("Error fetchig posts by user: $e");
    }
  }

  @override
  Future<void> toggleLikePost(String postId, String userId) async {
    try {
      //get the post document from firestore
      final postDoc = await postCollection.doc(postId).get();
      if (postDoc.exists) {
        final post = Post.fromJson(postDoc.data() as Map<String, dynamic>);

        //check if the user has already liked the post
        final hasLiked = post.likes.contains(userId);

        //update the likes list
        if (hasLiked) {
          post.likes.remove(userId);
        } else {
          post.likes.add(userId);
        }

        //save the updated post back to Firestore
        await postCollection.doc(postId).update({'likes': post.likes});
      } else {
        throw Exception("Post not found");
      }
    } catch (e) {
      throw Exception("Error toggling like: $e");
    }
  }

  @override
  Future<void> addComment(String postId, Comment comment) async {
    try {
      //get the post document from firestore
      final postDoc = await postCollection.doc(postId).get();
      if (postDoc.exists) {
        final post = Post.fromJson(postDoc.data() as Map<String, dynamic>);

        //add the new comment to the comments list
        post.comments.add(comment);

        //save the updated post back to Firestore
        await postCollection.doc(postId).update({
          'comments': post.comments.map((c) => c.toJson()).toList(),
        });
      } else {
        throw Exception("Post not found");
      }
    } catch (e) {
      throw Exception("Error adding comment: $e");
    }
  }

  @override
  Future<void> deleteComment(String postId, String commentId) async {
    try {
      //get the post document from firestore
      final postDoc = await postCollection.doc(postId).get();
      if (postDoc.exists) {
        final post = Post.fromJson(postDoc.data() as Map<String, dynamic>);

        //add the new comment to the comments list
        post.comments.removeWhere((comment) => comment.id == commentId);

        //save the updated post back to Firestore
        await postCollection.doc(postId).update({
          'comments': post.comments.map((c) => c.toJson()).toList(),
        });
      } else {
        throw Exception("Post not found");
      }
    } catch (e) {
      throw Exception("Error adding comment: $e");
    }
  }
}
