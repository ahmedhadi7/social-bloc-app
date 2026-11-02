import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_bloc/features/profile/presentation/pages/component/user_tile.dart';
import 'package:social_bloc/features/search/presentation/cubits/search_cubits.dart';
import 'package:social_bloc/features/search/presentation/cubits/search_states.dart';
import 'package:social_bloc/responsive/constrained_scaffold.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController searchController = TextEditingController();
  late final searchCubit = context.read<SearchCubits>();

  void onSearchChanged() {
    final query = searchController.text;
    searchCubit.searchUser(query);
  }

  @override
  void initState() {
    super.initState();
    searchController.addListener(onSearchChanged);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedScaffold(
      appBar: AppBar(
        title: TextField(
          controller: searchController,
          decoration: InputDecoration(
            hintText: "Search users...",
            hintStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
        ),
      ),

      //search Results
      body: BlocBuilder<SearchCubits, SearchStates>(
        builder: (context, state) {
          if (state is SearchLoaded) {
            if (state.users.isEmpty) {
              return const Center(child: Text("No users found"));
            }
            return ListView.builder(
              itemCount: state.users.length,
              itemBuilder: (context, index) {
                final user = state.users[index];
                return UserTile(user: user!);
              },
            );
          } else if (state is SearchLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is SearchError) {
            return Center(child: Text(state.message));
          }
          return const Center(child: Text("Search for users"));
        },
      ),
    );
  }
}
