import 'package:flutter/material.dart';
import 'package:social_bloc/features/auth/presentation/cubits/pages/login_page.dart';
import 'package:social_bloc/features/auth/presentation/cubits/pages/register_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool showLoadingPage = true;

  //togle betewwn page
  void togglePages() {
    setState(() {
      showLoadingPage = !showLoadingPage;
    });
  }
  @override
  Widget build(BuildContext context) {
if (showLoadingPage) {
      return  LoginPage(togglePages: togglePages);
    } else {
      return  RegisterPage(onTap: togglePages);
    }
  }
}
