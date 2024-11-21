import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String email = '';
  String password = '';
  bool isSignIn = true; // Track whether the user is signing in or signing up
  final _formKey = GlobalKey<FormState>(); // Key for form validation

  // Function to display errors via SnackBar
  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    ));
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return; // Skip if validation fails

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // Navigate to the GameScreen upon successful sign-in
      Navigator.pushReplacementNamed(context, '/quiz-type');
    } on FirebaseAuthException catch (e) {
      showError(e.message ?? 'An error occurred during sign-in.');
    }
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return; // Skip if validation fails

    try {
      // Attempt to create a new user with the provided email and password
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // Clear previous error messages (handled by showError)
      Navigator.pushReplacementNamed(
        context,
        '/quiz-type',
        arguments: userCredential.user,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        showError(
            'The email address is already in use. Please log in instead.');
      } else {
        showError(e.message ?? 'An error occurred during sign-up.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isSignIn ? 'Sign In' : 'Sign Up'),
        titleTextStyle: TextStyle(
            color: Colors.white, fontSize: 20, fontFamily: 'SourGummy'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo at the top
                  Center(
                    child: Image.asset(
                      'assets/logo.png', // Replace with your logo's asset path
                      height: 250, // Adjust size as needed
                      width: 300,
                    ),
                  ),

                  // Email Input Field
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(color: Colors.deepPurple),
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email, color: Colors.deepPurple),
                    ),
                    onChanged: (value) {
                      email = value;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      return null; // Return null if validation is successful
                    },
                  ),
                  SizedBox(height: 16.0),

                  // Password Input Field
                  TextFormField(
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(color: Colors.deepPurple),
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock, color: Colors.deepPurple),
                    ),
                    onChanged: (value) {
                      password = value;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null; // Return null if validation is successful
                    },
                  ),
                  SizedBox(height: 20),

                  // Sign In/Sign Up Button
                  ElevatedButton(
                    onPressed: isSignIn ? _signIn : _signUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.deepPurple, // Corrected to backgroundColor
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      shadowColor: Colors.deepPurpleAccent,
                      elevation: 5,
                    ),
                    child: Text(
                      isSignIn ? 'Sign In' : 'Sign Up',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Toggle Between Sign In and Sign Up
                  TextButton(
                    onPressed: () {
                      setState(() {
                        isSignIn = !isSignIn;
                      });
                    },
                    child: Text(
                      isSignIn
                          ? 'Don\'t have an account? Sign Up'
                          : 'Already have an account? Sign In',
                      style: TextStyle(color: Colors.deepPurple),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
