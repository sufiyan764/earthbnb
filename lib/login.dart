import 'package:earthbnb/colors.dart';
import 'package:earthbnb/properties.dart';
import 'package:earthbnb/register.dart';
import 'package:earthbnb/widgets/custom_appbar.dart';
import 'package:earthbnb/widgets/custom_button.dart';
import 'package:earthbnb/widgets/custom_input.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'main.dart';
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  String email = '', password = '';

  void _loginUser() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _auth.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        Navigator.pushReplacementNamed(context, '/properties');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(appBarText: 'Login'),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomInput(inputText: 'Email', inputController: _emailController, inputValidator: (value) => value!.isEmpty || !value.contains('@') ? 'Enter a valid email' : null, textInputType: TextInputType.emailAddress, inputMaxLength: 200),
              SizedBox(height: 20),
              CustomInput(inputText: 'Password', inputController: _passwordController, inputValidator: (value) => value!.isEmpty ? 'Enter your password' : null, textInputType: TextInputType.name, inputMaxLength: 200),
              SizedBox(height: 20),
              CustomButton(buttonText: 'Login', isColored: 'true', onPressed: _loginUser, buttonColor: AppColors.accentTeal),
              SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/register');
                },
                child: Text("Don't have an account? Register now"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
