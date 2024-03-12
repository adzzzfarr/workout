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
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            top: screenHeight / 5,
            bottom: screenHeight / 4,
          ),
          child: Column(
            children: [
              Icon(
                Icons.fitness_center_rounded,
                size: screenHeight / 5,
                color: colorScheme.primary,
              ),
              SizedBox(height: screenHeight / 200),
              Text(
                'Hi there!',
                style: TextStyle(
                  letterSpacing: 1,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: screenHeight / 30,
                ),
              ),
              SizedBox(height: screenHeight / 50),
              FormContainer(
                controller: nameController,
                hintText: 'Name',
                isPasswordField: false,
              ),
              SizedBox(height: screenHeight / 80),
              FormContainer(
                controller: emailController,
                hintText: 'Email',
                isPasswordField: false,
              ),
              SizedBox(height: screenHeight / 80),
              FormContainer(
                controller: passwordController,
                hintText: 'Password',
                isPasswordField: true,
              ),
              SizedBox(height: screenHeight / 50),
              isSigningUp
                  ? const CircularProgressIndicator()
                  : CommonButton(
                      height: screenHeight / 15,
                      width: screenWidth - 20,
                      text: 'Sign Up',
                      onPressed: () => signUp(),
                    ),
              SizedBox(height: screenHeight / 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenHeight / 50,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LogInPage()),
                        (route) => false),
                    child: Text(
                      'Log in now.',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                        fontSize: screenHeight / 50,
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
