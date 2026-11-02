import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_bloc/features/profile/presentation/pages/component/user_tile.dart';
import 'package:social_bloc/features/profile/presentation/pages/cubits/profile_cubit.dart';
import 'package:social_bloc/responsive/constrained_scaffold.dart';

class FollowerPage extends StatelessWidget {
  final List<String> followers;
  final List<String> following;
  const FollowerPage({
    super.key,
    required this.followers,
    required this.following,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      //scaffold
      child: ConstrainedScaffold(
        appBar: AppBar(
          bottom: TabBar(
            dividerColor: Colors.transparent,
            labelColor: Theme.of(context).colorScheme.inversePrimary,
            unselectedLabelColor: Theme.of(context).colorScheme.primary,
            tabs: const [
              Tab(text: 'Followers'),
              Tab(text: 'Following'),
            ],
          ),
        ),

        //tab bar view
        body: TabBarView(
          children: [
            //followers
            _buildUserList(followers, "No followers yet", context),

            //following
            _buildUserList(following, "Not following anyone yet", context),
          ],
        ),
      ),
    );
  }

  //build user list,
  Widget _buildUserList(
    List<String> uids,
    String emptyMessage,
    BuildContext context,
  ) {
    return uids.isEmpty
        ? Center(
            child: Text(
              emptyMessage,
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          )
        : ListView.builder(
            itemCount: uids.length,
            itemBuilder: (context, index) {
              final uid = uids[index];

              return FutureBuilder(
                future: context.read<ProfileCubit>().getUserProfile(uid),
                builder: (context, snapshot) {
                  //user loaded
                  if (snapshot.hasData) {
                    final user = snapshot.data!;
                    return UserTile(user: user); 
                  }
                  //loading
                  else if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return ListTile(title: Text("Loading..."));
                  }

                  //error
                  return ListTile(title: Text("Error loading user"));
                },
              );
            },
          );
  }
}
