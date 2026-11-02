import 'package:flutter/material.dart';

class ProfileStats extends StatelessWidget {
  final int postCount;
  final int followersCount;
  final int followingCount;
  final void Function()? onTab;

  const ProfileStats({
    super.key,
    required this.postCount,
    required this.followersCount,
    required this.followingCount,
    required this.onTab,
  });

  @override
  Widget build(BuildContext context) {
    //text  stle
    var textStyleforStats = TextStyle(
      color: Theme.of(context).colorScheme.primary,
    );

    //text style for text
    var textStyleforText = TextStyle(
      fontSize: 16,
      color: Theme.of(context).colorScheme.primary,
    );
    return GestureDetector(
      onTap: onTab,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //posts
          SizedBox(
            width: 100,
            child: Column(
              children: [
                Text(postCount.toString()),
                Text('Posts', style: textStyleforText),
              ],
            ),
          ),

          //followers
          SizedBox(
            width: 100,
            child: Column(
              children: [
                Text(followersCount.toString()),
                Text('Followers', style: textStyleforText),
              ],
            ),
          ),
          //following
          SizedBox(
            width: 100,
            child: Column(
              children: [
                Text(followingCount.toString()),
                Text('Following', style: textStyleforText),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
