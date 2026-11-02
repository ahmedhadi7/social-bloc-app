import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_bloc/features/auth/presentation/cubits/auth_cubits.dart';
import 'package:social_bloc/features/home/component/my_drawer_tile.dart';
import 'package:social_bloc/features/profile/presentation/pages/profile_page.dart';
import 'package:social_bloc/features/search/pages/search_page.dart';
import 'package:social_bloc/features/settings/pages/settings_page.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            children: [
              //logp
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 50.0),
                child: Icon(
                  Icons.person,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              Divider(color: Theme.of(context).colorScheme.onSurface),

              //home tile
              MyDrawerTile(
                title: 'الصفحه الرئيسيه',
                icon: Icons.home,
                onTap: () => Navigator.of(context).pop(),
              ),

              MyDrawerTile(
                title: 'الحساب',
                icon: Icons.person,
                onTap: () {
                  Navigator.of(context).pop();
                  //get current user uid
                  final user = context.read<AuthCubits>().currentUser;
                  String? uid = user!.uid;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfilePage(uid: uid),
                    ),
                  );
                },
              ),

              MyDrawerTile(
                title: 'البحث عن المستخدمين',
                icon: Icons.search,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SearchPage()),
                ),
              ),

              MyDrawerTile(
                title: 'الاعدادات',
                icon: Icons.settings,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                ),
              ),
              Spacer(),

              MyDrawerTile(
                title: 'تسجيل الخروج',
                icon: Icons.logout,
                onTap: () {
                  context.read<AuthCubits>().logout();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
