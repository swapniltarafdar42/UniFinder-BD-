import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login.dart'; // Navigate to LoginPage after signup

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  String _email = '', _password = '', _name = '';
  bool _isLoading = false; // For showing loading while creating account

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Regex for validating email format
  final RegExp emailRegExp = RegExp(
    r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
  );

  Future<void> _signup() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Create user with email and password
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _email,
        password: _password,
      );

      // Send verification email
      await userCredential.user?.sendEmailVerification();

      // Show a dialog prompting the user to verify their email
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Email Verification'),
          content: Text(
              'A verification email has been sent to your email address. Please check your inbox and verify your email.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                ); // Redirect to LoginPage to log in after verification
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle errors
      print("Signup failed: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Signup failed. Please try again."),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Signup'),
        backgroundColor: Colors.blue.shade700,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Full Name'),
                validator: (value) => value!.isEmpty ? 'Enter your name' : null,
                onSaved: (value) => _name = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your email';
                  }
                  // Check if email matches the correct format using regex
                  if (!emailRegExp.hasMatch(value)) {
                    return 'Please enter a valid email (e.g., example@gmail.com)';
                  }
                  return null;
                },
                onSaved: (value) => _email = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) => value!.length < 6
                    ? 'Password must be at least 6 characters'
                    : null,
                onSaved: (value) => _password = value!,
              ),
              SizedBox(height: 20),
              _isLoading
                  ? CircularProgressIndicator() // Show loading when creating account
                  : ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          _signup();
                        }
                      },
                      child: Text('Create Account'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
