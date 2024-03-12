import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:workout/pages/signup_page.dart';
import 'package:workout/widgets/common_button.dart';
import 'package:workout/pages/navigation_bar_page.dart';
import 'package:workout/widgets/form_container.dart';
import 'package:workout/firebase/firebase_auth_service.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:workout/widgets/toast.dart';

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
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.fitness_center_rounded,
                size: screenHeight / 5,
                color: colorScheme.primary,
              ),
              SizedBox(height: screenHeight / 200),
              Text(
                'Ready to work out?',
                style: TextStyle(
                  letterSpacing: 1,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: screenHeight / 30,
                ),
              ),
              SizedBox(height: screenHeight / 50),
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
              SizedBox(height: screenHeight / 40),
              isSigningIn
                  ? const CircularProgressIndicator()
                  : CommonButton(
                      height: screenHeight / 15,
                      width: screenWidth - 20,
                      text: 'Log In',
                      onPressed: () => signIn(),
                    ),
              SizedBox(height: screenHeight / 70),
              CommonButton(
                  height: screenHeight / 15,
                  width: screenWidth - 20,
                  leading: FontAwesomeIcons.google,
                  text: 'Sign In with Google',
                  color: Colors.red,
                  onPressed: () => signInWithGoogle()),
              SizedBox(height: screenHeight / 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Not a member? ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenHeight / 50,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SignUpPage()),
                      (route) => false,
                    ),
                    child: Text(
                      'Sign up now.',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                          fontSize: screenHeight / 50),
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

  void signInWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    try {
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken,
        );

        await FirebaseAuth.instance.signInWithCredential(credential);

        if (context.mounted) {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => const NavigationBarPage()),
              (route) => false);
        }
      }
    } catch (e) {
      showToast(message: 'An error occurred: $e');
    }
  }
}
