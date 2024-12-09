import 'package:earthbnb/colors.dart';
import 'package:earthbnb/login.dart';
import 'package:earthbnb/properties.dart';
import 'package:earthbnb/widgets/custom_appbar.dart';
import 'package:earthbnb/widgets/custom_button.dart';
import 'package:earthbnb/widgets/custom_input.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'main.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _auth = FirebaseAuth.instance;
  final _database = FirebaseDatabase.instance.ref();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  String firstName = '', lastName = '', phone = '', email = '', password = '', confirmPassword = '';

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  void _registerUser() async {
    if (_formKey.currentState!.validate()) {
      try {
        final userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        await _database.child('users/${userCredential.user!.uid}').set({
          'firstName': _firstNameController.text,
          'lastName': _lastNameController.text,
          'phone': _phoneController.text,
          'email': _emailController.text,
        });
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
      appBar: const CustomAppBar(appBarText: 'Register'),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                CustomInput(inputText: 'First Name', inputController: _firstNameController, inputValidator: (value) => value!.isEmpty ? 'Enter your first name' : null, textInputType: TextInputType.name, inputMaxLength: 200),
                SizedBox(height: 20),
                CustomInput(inputText: 'Last Name', inputController: _lastNameController, inputValidator: (value) => value!.isEmpty ? 'Enter your last name' : null, textInputType: TextInputType.name, inputMaxLength: 200),
                SizedBox(height: 20),
                CustomInput(inputText: 'Phone Number', inputController: _phoneController, inputValidator: (value) => value!.isEmpty || value.length != 10 ? 'Enter a valid phone number' : null, textInputType: TextInputType.phone, inputMaxLength: 10),
                SizedBox(height: 20),
                CustomInput(inputText: 'Email', inputController: _emailController, inputValidator: (value) => value!.isEmpty || !value.contains('@') ? 'Enter a valid email' : null, textInputType: TextInputType.emailAddress, inputMaxLength: 100),
                SizedBox(height: 20),
                CustomInput(inputText: 'Password', inputController: _passwordController, inputValidator: (value) => value!.length < 6 ? 'Password must be at least 6 characters' : null, textInputType: TextInputType.text, inputMaxLength: 100),
                SizedBox(height: 20),
                CustomInput(inputText: 'Confirm Password', inputController: _confirmPasswordController, inputValidator: (value) => value != _passwordController.text ? 'Passwords do not match' : null, textInputType: TextInputType.text, inputMaxLength: 100),
                SizedBox(height: 20),
                CustomButton(buttonText: 'Register', isColored: 'true', onPressed: _registerUser, buttonColor: AppColors.accentTeal),
                SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/');
                  },
                  child: Text("Already have an account? Login now"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
