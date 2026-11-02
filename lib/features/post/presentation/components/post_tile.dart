import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_bloc/componet/my_text_field.dart';
import 'package:social_bloc/features/auth/domain/entities/app_user.dart';
import 'package:social_bloc/features/auth/domain/entities/comment.dart';
import 'package:social_bloc/features/auth/presentation/cubits/auth_cubits.dart';
import 'package:social_bloc/features/post/domain/entities/post.dart';
import 'package:social_bloc/features/post/presentation/components/comment_tile.dart';
import 'package:social_bloc/features/post/presentation/cubits/post_cubit.dart';
import 'package:social_bloc/features/post/presentation/cubits/post_state.dart';
import 'package:social_bloc/features/profile/domin/entites/profile_user.dart';
import 'package:social_bloc/features/profile/presentation/pages/cubits/profile_cubit.dart';
import 'package:social_bloc/features/profile/presentation/pages/profile_page.dart';

class PostTile extends StatefulWidget {
  final Post post;
  final void Function()? onDeletePressed;

  const PostTile({
    super.key,
    required this.post,
    required this.onDeletePressed,
  });

  @override
  State<PostTile> createState() => _PostTileState();
}

class _PostTileState extends State<PostTile> {
  //cubits
  late final postCubit = context.read<PostCubit>();
  late final profileCubit = context.read<ProfileCubit>();
  bool isOwnPost = false;

  //current user
  AppUser? currentUser;
  //post user
  ProfileUser? postUser;
  //on startup

  @override
  void initState() {
    getCurrentUser();
    fetchPostUser();
    super.initState();
  }

  void getCurrentUser() {
    final authCubit = context.read<AuthCubits>();
    currentUser = authCubit.currentUser;
    isOwnPost = widget.post.userId == currentUser!.uid;
  }

  Future<void> fetchPostUser() async {
    final fetchedUser = await profileCubit.getUserProfile(widget.post.userId);
    if (fetchedUser != null) {
      setState(() {
        postUser = fetchedUser;
      });
    }
  }

  /*
  Likes

  */
  //user tapped like button
  void toggleLikePost() {
    //current likes status
    final isLiked = widget.post.likes.contains(currentUser!.uid);

    //optimistically update the UI
    setState(() {
      if (isLiked) {
        widget.post.likes.remove(currentUser!.uid);
      } else {
        widget.post.likes.add(currentUser!.uid);
      }
    });

    //update likes
    postCubit.toggleLikePost(widget.post.id, currentUser!.uid).catchError((
      error,
    ) {
      //revert the UI if there's an error
      setState(() {
        if (isLiked) {
          widget.post.likes.add(currentUser!.uid);
        } else {
          widget.post.likes.remove(currentUser!.uid);
        }
      });
    });
  }

  /*
  COMMENTS
  */
  //comment text field controller
  final commentController = TextEditingController();

  //open comment box -> user wants to type a new comment
  void openCommentBox() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("اكتب تعليق"),
        content: MyTextField(
          controller: commentController,
          hintText: "Type your comment",
          obscureText: false,
        ),
        actions: [
          //cancel button
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("الغاء"),
          ),
          //save button
          TextButton(
            onPressed: () {
              // Handle save action
              addComment();
            },
            child: const Text("حفظ"),
          ),
        ],
      ),
    );
  }

  void addComment() {
    final text = commentController.text.trim();
    if (text.isEmpty) return;

    final newComment = Comment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      postId: widget.post.id,
      userId: currentUser!.uid,
      userName: currentUser!.name,
      text: text,
      timestamp: DateTime.now(),
    );

    postCubit.addComment(widget.post.id, newComment);
    commentController.clear();
  }

  void showOption() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("هل تريد حذف المنشور؟"),
        actions: [
          //cancel
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("الغاء"),
          ),
          //delete
          TextButton(
            onPressed: () {
              widget.onDeletePressed!();
              Navigator.of(context).pop();
            },
            child: const Text("حذف"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.secondary,

      child: Column(
        children: [
          //tap section: profile pic / name / delete button
          GestureDetector(
            onTap: () =>
                // Navigate to the user's profile page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(uid: widget.post.userId),
                  ),
                ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  //profile pic
                  postUser?.profileImageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: postUser!.profileImageUrl,
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.person),
                          imageBuilder: (context, imageProvider) => Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        )
                      : const Icon(Icons.person),
                  const SizedBox(width: 10),

                  Text(widget.post.userName),
                  const Spacer(),
                  //delete button
                  if (isOwnPost)
                    GestureDetector(
                      onTap: showOption,

                      child: Icon(
                        Icons.delete,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                ],
              ),
            ),
          ),

          Builder(
            builder: (context) {
              final imageUrl = widget.post.imageUrl.trim();

              if (imageUrl.isEmpty || !imageUrl.startsWith('https://')) {
                return const SizedBox(
                  height: 300,
                  width: double.infinity,
                  child: Center(
                    child: Icon(Icons.image_not_supported, size: 50),
                  ),
                );
              }

              return CachedNetworkImage(
                imageUrl: imageUrl,
                height: 300,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => const SizedBox(
                  height: 300,
                  child: Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) {
                  debugPrint('IMAGE ERROR: $error');
                  debugPrint('IMAGE URL: $url');

                  return const SizedBox(
                    height: 300,
                    child: Center(child: Icon(Icons.broken_image, size: 50)),
                  );
                },
              );
            },
          ),

          //buttons -> like, comment, timestamp
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                SizedBox(
                  width: 50,
                  child: Row(
                    children: [
                      //like button
                      GestureDetector(
                        onTap: toggleLikePost,
                        child: Icon(
                          widget.post.likes.contains(currentUser!.uid)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: widget.post.likes.contains(currentUser!.uid)
                              ? Colors.red
                              : Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 5),

                      //like count
                      Text(
                        widget.post.likes.length.toString(),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                //comment button
                GestureDetector(
                  onTap: openCommentBox,
                  child: Icon(
                    Icons.comment,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  widget.post.comments.length.toString(),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),

                //timestamp
                Text(widget.post.timestamp.toString()),
              ],
            ),
          ),

          //caption
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 10.0,
            ),
            child: Row(
              children: [
                Text(
                  widget.post.userName,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 10),
                Text(widget.post.text),
              ],
            ),
          ),
          //comment section
          BlocBuilder<PostCubit, PostState>(
            builder: (context, state) {
              //loaded
              if (state is PostsLoaded) {
                final post = state.posts.firstWhere(
                  (post) => (post.id == widget.post.id),
                );

                if (post.comments.isNotEmpty) {
                  //how many comments to show
                  int showCommentCount = post.comments.length;

                  //comment section
                  return ListView.builder(
                    itemCount: showCommentCount,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final comment = post.comments[index];

                      //comment tile ui
                      return CommentTile(comment: comment);
                    },
                  );
                }
              }

              //loading
              if (state is PostLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              //error
              else if (state is PostError) {
                return Center(child: Text("Error: ${state.message}"));
              } else {
                return const SizedBox();
              }
            },
          ),
        ],
      ),
    );
  }
}













 /*
          Image.network(
            post.imageUrl,
            height: 430,
            width: double.infinity,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) {
                print('IMAGE LOADED SUCCESSFULLY');
                return child;
              }
      
              return const SizedBox(
                height: 430,
                child: Center(child: CircularProgressIndicator()),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              print('IMAGE NETWORK ERROR: $error');
              print('STACK: $stackTrace');
              print('URL: ${post.imageUrl}');
      
              return const SizedBox(
                height: 430,
                child: Center(child: Icon(Icons.error)),
              );
            },
          ),*/