import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:workout/pages/signup_page.dart';
import 'package:workout/widgets/common_button.dart';
import 'package:workout/pages/navigation_bar_page.dart';
import 'package:workout/widgets/form_container.dart';
import 'package:workout/firebase/firebase_auth_service.dart';

class LogInPage extends StatefulWidget {
  const LogInPage({super.key});

  @override
  State<LogInPage> createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  final FirebaseAuthService auth = FirebaseAuthService();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isSigningIn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              const Icon(
                Icons.fitness_center,
                size: 100,
              ),
              const SizedBox(height: 75),
              const Text(
                'Hello!',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              FormContainer(
                controller: emailController,
                hintText: 'Email',
                isPasswordField: false,
              ),
              const SizedBox(height: 10),
              FormContainer(
                controller: passwordController,
                hintText: 'Password',
                isPasswordField: true,
              ),
              const SizedBox(height: 10),
              isSigningIn
                  ? const CircularProgressIndicator()
                  : CommonButton(
                      height: 100,
                      width: 100,
                      text: 'Log In',
                      onPressed: () => signIn(),
                    ),
              Row(
                children: [
                  const Text('Not a member?'),
                  GestureDetector(
                    onTap: () => Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SignUpPage()),
                      (route) => false,
                    ),
                    child: const Text(
                      'Sign up now.',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void signIn() async {
    FocusScope.of(context).unfocus();

    setState(() {
      isSigningIn = true;
    });

    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    User? user = await auth.signInWithEmailAndPassword(email, password);

    setState(() {
      isSigningIn = false;
    });

    if (user != null) {
      print('User has successfully logged in');
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const NavigationBarPage()),
          (route) => false,
        );
      }
    } else {
      print('Some error occurred');
    }
  }
}
