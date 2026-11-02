import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_bloc/features/home/component/my_drawer.dart';
import 'package:social_bloc/features/post/presentation/components/post_tile.dart';
import 'package:social_bloc/features/post/presentation/cubits/post_cubit.dart';
import 'package:social_bloc/features/post/presentation/cubits/post_state.dart';
import 'package:social_bloc/features/post/presentation/pages/upload_post_page.dart';
import 'package:social_bloc/responsive/constrained_scaffold.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //post cubit
  late final postCubit = context.read<PostCubit>();

  @override
  void initState() {
    super.initState();

    fetchAllPosts();
  }

  void fetchAllPosts() {
    postCubit.fetchAllPosts();
  }

  void deletePost(String postId) {
    postCubit.deletePost(postId);
    fetchAllPosts();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedScaffold(
      appBar: AppBar(
        title: const Text('القائمه الرئيسيه'),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            iconSize: 37,
            padding: EdgeInsets.only(right: 30),
            
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UploadPostPage()),
              );
            },
          ),
        ],
      ),
      drawer: MyDrawer(),

      body: BlocBuilder<PostCubit, PostState>(
        builder: (context, state) {
          //loading...
          if (state is PostLoading || state is PostUploading) {
            return const Center(child: CircularProgressIndicator());
          }
          //loaded
          if (state is PostsLoaded) {
            final allPosts = state.posts;

            if (allPosts.isEmpty) {
              return const Center(child: Text("لا توجد منشورات"));
            }
            return ListView.builder(
              itemCount: allPosts.length,
              itemBuilder: (context, index) {
                //get individual post
                final post = allPosts[index];
                //image
                return PostTile(
                  post: post,
                  onDeletePressed: () => deletePost(post.id),
                );
              },
            );
          }
          //error
          else if (state is PostError) {
            return Center(child: Text(state.message));
          } else {
            return const SizedBox();
          }
        },
      ),
    );
  }
}
