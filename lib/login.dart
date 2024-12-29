import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'courses.dart'; // Navigate to CoursesPage upon successful login
import 'signup.dart'; // Navigate to SignUpPage if no account exists
import 'forgot_password.dart'; // Navigate to ForgotPasswordPage

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String _email = '', _password = '';
  bool _obscureText = true; // To hide the password by default
  bool _isLoading = false; // To show loading when trying to login

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: _email,
        password: _password,
      );

      // Check if email is verified
      if (userCredential.user!.emailVerified) {
        // Navigate to CoursesPage on successful login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CoursesPage()),
        );
      } else {
        // If email is not verified, show an alert and prompt for verification
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Please verify your email before logging in."),
        ));
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle errors
      if (e.toString().contains('wrong-password')) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Wrong password. Please try again."),
        ));
      } else if (e.toString().contains('user-not-found')) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("No user found with this email."),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Login failed. Please check your credentials."),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        backgroundColor: Colors.blue.shade700,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) =>
                    !value!.contains('@') ? 'Enter a valid email' : null,
                onSaved: (value) => _email = value!,
              ),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      // Toggle the visibility of the password
                      _obscureText ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                ),
                obscureText: _obscureText, // Show or hide the password
                validator: (value) => value!.length < 6
                    ? 'Password must be at least 6 characters'
                    : null,
                onSaved: (value) => _password = value!,
              ),
              SizedBox(height: 20),
              _isLoading
                  ? CircularProgressIndicator() // Show loading when trying to login
                  : ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          _login();
                        }
                      },
                      child: Text('Login'),
                    ),
              SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  // Navigate to the SignUpPage if no account exists
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignupPage()),
                  );
                },
                child: Text(
                  "Don't have an account? Sign Up",
                  style: TextStyle(fontSize: 16, color: Colors.blue),
                ),
              ),
              SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  // Navigate to ForgotPasswordPage
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ForgotPasswordPage()),
                  );
                },
                child: Text(
                  "Forgot Password?",
                  style: TextStyle(fontSize: 16, color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
