import 'package:earthbnb/colors.dart';
import 'package:earthbnb/widgets/custom_appbar.dart';
import 'package:earthbnb/widgets/custom_button.dart';
import 'package:earthbnb/widgets/custom_input.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'navigation.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _loadUserData();
  }

  @override
  void dispose() {
    // Dispose controllers when the widget is removed from the tree
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final snapshot = await _database.child('users/${user.uid}').get();

      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        setState(() {
          _firstNameController.text = data['firstName'] ?? '';
          _lastNameController.text = data['lastName'] ?? '';
          _phoneController.text = data['phone'] ?? '';
          _emailController.text = data['email'] ?? user.email!;
        });
      } else {
        print("no data found for the user");
      }
    }
  }

  Future<void> _saveUserData() async {
    final user = _auth.currentUser;

    if (user != null && _formKey.currentState!.validate()) {
      try {
        await _database.child('users/${user.uid}').update({
          'firstName': _firstNameController.text,
          'lastName': _lastNameController.text,
          'phone': _phoneController.text,
          'email': _emailController.text,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
      }
    }
  }

  void _logoutUser() async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: const CustomAppBar(appBarText: 'Profile'),
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
                CustomButton(buttonText: 'Save', isColored: 'true', onPressed: _saveUserData, buttonColor: AppColors.accentTeal),
                SizedBox(height: 20),
                CustomButton(buttonText: 'Logout', isColored: 'true', onPressed: _logoutUser, buttonColor: Colors.black)
              ],
            ),
          ),
        ),
      ),
        bottomNavigationBar: const AppNavigation(selectedIndex: 3)
    );
  }
}
