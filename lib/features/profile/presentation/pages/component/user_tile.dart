import 'package:flutter/material.dart';
import 'package:social_bloc/features/profile/domin/entites/profile_user.dart';
import 'package:social_bloc/features/profile/presentation/pages/profile_page.dart';

class UserTile extends StatelessWidget {
  final ProfileUser user;
  const UserTile({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(user.name),
      subtitle: Text(user.email),
      subtitleTextStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
      leading: Icon(Icons.person, color: Theme.of(context).colorScheme.primary),
      trailing: Icon(Icons.arrow_forward_ios, color: Theme.of(context).colorScheme.primary),
      onTap: () {
        // Navigate to the user's profile page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfilePage(uid: user.uid),
          ),
        );
      },
    );
  }
}