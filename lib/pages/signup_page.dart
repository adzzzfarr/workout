import 'package:flutter/material.dart';
import 'package:workout/pages/login_page.dart';
import 'package:workout/pages/navigation_bar_page.dart';
import 'package:workout/widgets/common_button.dart';
import 'package:workout/firebase/firebase_auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:workout/widgets/form_container.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final FirebaseAuthService auth = FirebaseAuthService();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isSigningUp = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Expanded(
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
                controller: nameController,
                hintText: 'Name',
                isPasswordField: false,
              ),
              const SizedBox(height: 10),
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
              isSigningUp
                  ? const CircularProgressIndicator()
                  : CommonButton(
                      height: 100,
                      width: 100,
                      text: 'Sign Up',
                      onPressed: () => signUp(),
                    ),
              Row(
                children: [
                  const Text('Already have an account?'),
                  GestureDetector(
                    onTap: () => Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LogInPage(),
                        ),
                        (route) => false),
                    child: const Text(
                      'Log in now.',
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

  void signUp() async {
    FocusScope.of(context).unfocus();

    setState(() {
      isSigningUp = true;
    });

    String name = nameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    User? user = await auth.signUpWithEmailAndPassword(email, password);

    setState(() {
      isSigningUp = false;
    });

    if (user != null) {
      print('User successfully created');

      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const NavigationBarPage()),
          (route) => false,
        );
      } else {
        print('BuildContext is not mounted.');
      }
    } else {
      print('User could not be created.');
    }
  }
}
