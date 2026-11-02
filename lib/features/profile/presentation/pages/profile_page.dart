import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_bloc/features/auth/domain/entities/app_user.dart';
import 'package:social_bloc/features/auth/presentation/cubits/auth_cubits.dart';
import 'package:social_bloc/features/post/presentation/components/post_tile.dart';
import 'package:social_bloc/features/post/presentation/cubits/post_cubit.dart';
import 'package:social_bloc/features/post/presentation/cubits/post_state.dart';
import 'package:social_bloc/features/profile/presentation/pages/component/bio_box.dart';
import 'package:social_bloc/features/profile/presentation/pages/component/follow_button.dart';
import 'package:social_bloc/features/profile/presentation/pages/component/profile_stats.dart';
import 'package:social_bloc/features/profile/presentation/pages/cubits/profile_cubit.dart';
import 'package:social_bloc/features/profile/presentation/pages/cubits/profile_state.dart';
import 'package:social_bloc/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:social_bloc/features/profile/presentation/pages/follower_page.dart';
import 'package:social_bloc/responsive/constrained_scaffold.dart';

class ProfilePage extends StatefulWidget {
  final String uid;
  const ProfilePage({super.key, required this.uid});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  //cubit
  late final authCubits = context.read<AuthCubits>();
  late final profileCubit = context.read<ProfileCubit>();
  //currentUser
  late AppUser? currentUser = authCubits.currentUser;

  //posts
  int PostCount = 0;

  //on startup
  @override
  void initState() {
    super.initState();
    // load user profile data
    profileCubit.fetchProfileUser(widget.uid);
  }

  /*
  follow unfollow
  */
  void followButtonPressed() {
    final profileState = profileCubit.state;
    if (profileState is! ProfileLoaded) {
      return; // return is profile is not loaded
    }

    final profileUser = profileState.profileUser;
    final isFollowing = profileUser.followers.contains(currentUser!.uid);

    //optimistically updateUI
    setState(() {
      //unfollow
      if (isFollowing) {
        profileUser.followers.remove(currentUser!.uid);
      }
      //follow
      else {
        profileUser.followers.add(currentUser!.uid);
      }
    });

    //perform actualtoggle in cubit
    profileCubit.toggleFollow(currentUser!.uid, widget.uid).catchError((error) {
      //revert update if theres an error
      setState(() {
        //unfollow
        if (isFollowing) {
          profileUser.followers.add(currentUser!.uid);
        }
        //follow
        else {
          profileUser.followers.remove(currentUser!.uid);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    //isown post
    bool isOwnPost = (widget.uid == currentUser!.uid);
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        //loaded
        if (state is ProfileLoaded) {
          //get loaded user
          final user = state.profileUser;
          return ConstrainedScaffold(
            appBar: AppBar(
              title: Text(user.name, style: TextStyle(color: Colors.black)),
              foregroundColor: Theme.of(context).colorScheme.primary,
              actions: [
                //edit profile button
                if (isOwnPost)
                  IconButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProfilePage(user: user),
                      ),
                    ),
                    icon: Icon(Icons.settings),
                  ),
              ],
            ),

            //body
            body: ListView(
              children: [
                //email
                Text(
                  user.email,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 25),

                //profile pic
                CachedNetworkImage(
                  imageUrl: user.profileImageUrl,

                  //loading
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),

                  //error -> failed to load
                  errorWidget: (context, url, error) => Icon(
                    Icons.person,
                    size: 72,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  //loaded
                  imageBuilder: (context, imageProvider) => Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                //profile stats
                ProfileStats(
                  postCount: PostCount,
                  followersCount: user.followers.length,
                  followingCount: user.following.length,
                  onTab: () {
                    //navigate to followers page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FollowerPage(
                          followers: user.followers,
                          following: user.following,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 25),

                //follow button
                if (!isOwnPost)
                  FollowButton(
                    onPressed: followButtonPressed,
                    isFollowing: user.followers.contains(currentUser!.uid),
                  ),

                const SizedBox(height: 25),

                //bio box
                Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: Row(
                    children: [
                      Text(
                        "Bio",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                BioBox(text: user.bio),
                const SizedBox(height: 25),

                Padding(
                  padding: const EdgeInsets.only(left: 25.0, top: 10.0),
                  child: Row(
                    children: [
                      Text(
                        "Posts",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                //list of posts from this user
                BlocBuilder<PostCubit, PostState>(
                  builder: (context, state) {
                    if (state is PostsLoaded) {
                      //filter posts by userId

                      //final isOwnPost = post.userId == currentUser?.uid;
                      final userPosts = state.posts
                          .where((post) => post.userId == widget.uid)
                          .toList();

                      PostCount = userPosts.length;

                      return ListView.builder(
                        itemCount: PostCount,
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          //get individual posts
                          final post = userPosts[index];

                          //return list tile for each post
                          return PostTile(
                            post: post,
                            onDeletePressed: () =>
                                context.read<PostCubit>().deletePost(post.id),
                          );
                        },
                      );
                    } else if (state is PostLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else {
                      return const Center(child: Text("No posts found"));
                    }
                  },
                ),
              ],
            ),
          );
        }
        //loading
        else if (state is ProfileLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else {
          return const Center(child: Text("No profile found"));
        }
      },
    );
  }
}
