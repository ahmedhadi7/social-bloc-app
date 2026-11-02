import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_bloc/features/auth/domain/entities/app_user.dart';
import 'package:social_bloc/features/auth/domain/entities/comment.dart';
import 'package:social_bloc/features/auth/presentation/cubits/auth_cubits.dart';
import 'package:social_bloc/features/post/presentation/cubits/post_cubit.dart';

class CommentTile extends StatefulWidget {
  final Comment comment;
  const CommentTile({super.key, required this.comment});

  @override
  State<CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends State<CommentTile> {
  //current user
  AppUser? currentUser;
  bool isOwnPost = false;
  @override
  void initState() {
    super.initState();
    getCurrentUser();
    
  }
  void getCurrentUser() async {
    //get current user from auth cubit
    final authCubit = context.read<AuthCubits>();
    currentUser = authCubit.currentUser;
    isOwnPost =  widget.comment.userId == currentUser!.uid;
  }
  //show options for delete
  void showOption() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("حذف العليق؟"),
        actions: [
          //cancel
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          //delete
          TextButton(
            onPressed: () {
              context.read<PostCubit>().deleteComment(widget.comment.postId, widget.comment.id);
              Navigator.of(context).pop();
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        children: [
          Text(
            widget.comment.userName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 10),
          Text(widget.comment.text),
          const Spacer(),
          //delete button
          if (isOwnPost)
            GestureDetector(
              
                onTap: showOption,
                child: Icon(Icons.more_horiz, color: Theme.of(context).colorScheme.primary),
              ),
            
        ],
      ),
    );
  }
}
