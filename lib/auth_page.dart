import 'package:flutter/material.dart';

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isLogin = true;

  final _formKey = GlobalKey<FormState>();
  String _email = '', _password = '', _name = '';

  void _toggleForm() {
    setState(() {
      isLogin = !isLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isLogin ? 'Login' : 'Signup'),
        backgroundColor: Colors.blue.shade700,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (!isLogin)
                TextFormField(
                  decoration: InputDecoration(labelText: 'Full Name'),
                  validator: (value) =>
                      value!.isEmpty ? 'Enter your name' : null,
                  onSaved: (value) => _name = value!,
                ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) =>
                    !value!.contains('@') ? 'Enter a valid email' : null,
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
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    print('${isLogin ? "Logging in" : "Signing up"}: $_email');
                  }
                },
                child: Text(isLogin ? 'Login' : 'Create Account'),
              ),
              TextButton(
                onPressed: _toggleForm,
                child: Text(isLogin
                    ? "Don't have an account? Signup"
                    : "Already have an account? Login"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
