import 'package:earthbnb/login.dart';
import 'package:earthbnb/properties.dart';
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

  String firstName = '', lastName = '', phone = '', email = '', password = '', confirmPassword = '';

  void _registerUser() async {
    if (_formKey.currentState!.validate()) {
      try {
        final userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        await _database.child('users/${userCredential.user!.uid}').set({
          'firstName': firstName,
          'lastName': lastName,
          'phone': phone,
          'email': email,
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
      appBar: AppBar(title: Text('Register')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: 'First Name'),
                  validator: (value) => value!.isEmpty ? 'Enter your first name' : null,
                  onChanged: (value) => firstName = value,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Last Name'),
                  validator: (value) => value!.isEmpty ? 'Enter your last name' : null,
                  onChanged: (value) => lastName = value,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Phone Number (Canadian)'),
                  keyboardType: TextInputType.phone,
                  validator: (value) => value!.isEmpty || value.length != 10 ? 'Enter a valid phone number' : null,
                  onChanged: (value) => phone = value,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => value!.isEmpty || !value.contains('@') ? 'Enter a valid email' : null,
                  onChanged: (value) => email = value,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) => value!.length < 6 ? 'Password must be at least 6 characters' : null,
                  onChanged: (value) => password = value,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Confirm Password'),
                  obscureText: true,
                  validator: (value) => value != password ? 'Passwords do not match' : null,
                  onChanged: (value) => confirmPassword = value,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _registerUser,
                  child: Text('Register'),
                ),
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
