import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_bloc/features/auth/domain/entities/comment.dart';

class Post {
  final String id;
  final String userId;
  final String userName;
  final String text;
  final String imageUrl;
  final DateTime timestamp;
  final List<String> likes;
   final List<Comment> comments;

  Post({
    required this.id,
    required this.userId,
    required this.userName,
    required this.text,
    required this.imageUrl,
    required this.timestamp,
    required this.likes,
    required this.comments,
  });

  Post copyWith({String? imageUrl}) {
    return Post(
      id: id,
      userId: userId,
      userName: userName,
      text: text,
      imageUrl: imageUrl ?? this.imageUrl,
      timestamp: timestamp,
      likes: likes,
      comments: comments,
    );
  }

  // Post -> JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'text': text,
      'imageUrl': imageUrl,
      'timestamp': Timestamp.fromDate(timestamp),
      'likes': likes,
      'comments': comments.map((comment) => comment.toJson()).toList(),
    };
  }

  // JSON -> Post
  factory Post.fromJson(Map<String, dynamic> json) {

    //prepare comments list
    final List<Comment> comments = (json['comments'] as List<dynamic>?)
        ?.map((commentJson) => Comment.fromJson(commentJson as Map<String, dynamic>))
        .toList() ?? [];
    return Post(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      text: json['text'] as String,
      imageUrl: json['imageUrl'] as String,
      timestamp: (json['timestamp'] as Timestamp).toDate(),
      likes: List<String>.from(json['likes'] ?? []),
      comments: comments
    );
  }
}
