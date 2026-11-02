import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_bloc/componet/my_button.dart';
import 'package:social_bloc/componet/my_text_field.dart';
import 'package:social_bloc/features/auth/presentation/cubits/auth_cubits.dart';
import 'package:social_bloc/responsive/constrained_scaffold.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;

  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameController = TextEditingController();

  final emailController = TextEditingController();
  final pwController = TextEditingController();
  final confirmPwController = TextEditingController();

  //register page method
  void register() {
    //prepare name, email, and password
    final String name = nameController.text;
    final String email = emailController.text;
    final String pw = pwController.text;
    final String confirmPw = confirmPwController.text;

    // auth cubit
    final authCubits = context.read<AuthCubits>();

    //ensure that the email and pw fiels are not empty
    if (name.isNotEmpty &&
        email.isNotEmpty &&
        pw.isNotEmpty &&
        confirmPw.isNotEmpty) {
          //ensure password match
          if (pw == confirmPw) {
      authCubits.register(name, email, pw);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
        ),
      );
    }
    }
    //display error message if email or pw is empty
    else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter all fields')));
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    pwController.dispose();
    confirmPwController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedScaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_open,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 50),

                //create
                Text(
                  'Create Account',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 30,
                  ),
                ),
                const SizedBox(height: 25),

                MyTextField(
                  controller: nameController,
                  hintText: 'Name',
                  obscureText: false,
                ),
                const SizedBox(height: 10),

                MyTextField(
                  controller: emailController,
                  hintText: 'Email',
                  obscureText: false,
                ),
                const SizedBox(height: 10),

                MyTextField(
                  controller: pwController,
                  hintText: 'Password',
                  obscureText: true,
                ),
                const SizedBox(height: 10),

                //confirm password textfield
                MyTextField(
                  controller: confirmPwController,
                  hintText: 'Confirm Password',
                  obscureText: true,
                ),
                const SizedBox(height: 25),

                MyButton(
                  onTap: () {
                    //register user
                    register();
                  },
                  text: 'Register',
                ),
                const SizedBox(height: 50),

                //not a member? register now
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Not a member?',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: Text(
                        ' Login now',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
