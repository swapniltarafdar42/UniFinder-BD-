import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  bool _isLoading = false; // To show loading when trying to reset password

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _resetPassword() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _auth.sendPasswordResetEmail(email: _emailController.text);
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Password reset email sent. Please check your inbox.'),
      ));
      Navigator.pop(context); // Go back to the login page
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to send password reset email.'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Forgot Password'),
        backgroundColor: Colors.blue.shade700,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Enter your email'),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator() // Show loading when trying to reset
                : ElevatedButton(
                    onPressed: _resetPassword,
                    child: Text('Reset Password'),
                  ),
          ],
        ),
      ),
    );
  }
}
