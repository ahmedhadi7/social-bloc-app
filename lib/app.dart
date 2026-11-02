import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_bloc/features/auth/data/firebase_auth_repo.dart';
import 'package:social_bloc/features/auth/presentation/cubits/auth_cubits.dart';
import 'package:social_bloc/features/auth/presentation/cubits/auth_states.dart';
import 'package:social_bloc/features/auth/presentation/cubits/pages/auth_page.dart';
import 'package:social_bloc/features/home/pages/home_page.dart';
import 'package:social_bloc/features/home/pages/welcome_page.dart';
import 'package:social_bloc/features/post/data/firebase_post_repo.dart';
import 'package:social_bloc/features/post/presentation/cubits/post_cubit.dart';
import 'package:social_bloc/features/profile/data/firebase_profile_repo.dart';
import 'package:social_bloc/features/profile/presentation/pages/cubits/profile_cubit.dart';
import 'package:social_bloc/features/search/data/firebase_search_repo.dart';
import 'package:social_bloc/features/search/presentation/cubits/search_cubits.dart';
import 'package:social_bloc/features/storage/domain/data/firebase_storage_repo.dart';
import 'package:social_bloc/themes/themeCubit.dart';
/*
App - Root Level
-------------------------------------
Repositiories: for the database
-firebase

Bloc Providers: for state management
- auth
- profile
- posts
- search
- themes

Check Auth state
-unauthenticated -> auth page(login/register)
-authenticated -> home page


*/

class MyApp extends StatelessWidget {
  // auth repo
  final firebaseauthRepo = FirebaseAuthRepo();
  // profile repo
  final firebaseprofileRepo = FirebaseProfileRepo();
  //storage repo
  final firebasestorageRepo = FirebaseStorageRepo();

  final firebasePostRepo = FirebasePostRepo();

  final firebaseSearchRepo = FirebaseSearchRepo();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    //provide cubit to app
    return MultiBlocProvider(
      providers: [
        //auth cubit
        BlocProvider<AuthCubits>(
          create: (context) =>
              AuthCubits(authRepo: firebaseauthRepo)..checkAuth(),
        ),
        //profile cubit
        BlocProvider<ProfileCubit>(
          create: (context) => ProfileCubit(
            profileRepo: firebaseprofileRepo,
            storageRepo: firebasestorageRepo,
          ),
        ),
        BlocProvider<PostCubit>(
          create: (context) => PostCubit(
            postRepo: firebasePostRepo,
            storageRepo: firebasestorageRepo,
          ),
        ),

        //search cubit
        BlocProvider<SearchCubits>(
          create: (context) => SearchCubits(firebaseSearchRepo),
        ),

        //theme cubit
        BlocProvider<ThemeCubit>(create: (context) => ThemeCubit()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeData>(
        builder: (context, currentTheme) => MaterialApp(
          debugShowCheckedModeBanner: false,

          theme: currentTheme,
          home: WelcomePage(
            child: BlocConsumer<AuthCubits, AuthState>(
              builder: (context, authState) {
                if (authState is Unauthenticated) {
                  return const AuthPage();
                }
                if (authState is Authenticated) {
                  return const HomePage();
                } else {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
              },
              listener: (context, state) {
                if (state is AuthError) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(state.message)));
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
