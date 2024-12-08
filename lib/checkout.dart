import 'package:earthbnb/colors.dart';
import 'package:earthbnb/thankyou.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:earthbnb/PropertiesClass.dart';

class CheckoutScreen extends StatefulWidget {
  final Property property;
  final int numberOfNights;
  final DateTime? checkInDate;
  final DateTime? checkOutDate;

  const CheckoutScreen({
    Key? key,
    required this.property,
    required this.numberOfNights,
    required this.checkInDate,
    required this.checkOutDate,
  }) : super(key: key);


  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _firstNameController = TextEditingController();
  late TextEditingController _lastNameController = TextEditingController();
  late TextEditingController _phoneController = TextEditingController();
  late TextEditingController _emailController = TextEditingController();
  final TextEditingController _postalController = TextEditingController();
  final TextEditingController _cardController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();

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
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _postalController.dispose();
    _cardController.dispose();
    _cvvController.dispose();
    _expiryController.dispose();
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

  void _confirmPayment() async {
    if (_formKey.currentState!.validate()) {
      // Save booking details to Firebase
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final tripsRef = FirebaseDatabase.instance.ref('trips/${user.uid}');

      // Fetch the current wishlist
      final snapshot = await tripsRef.get();
      List<dynamic> trips = [];
      if (snapshot.exists) {
        trips = List<dynamic>.from(snapshot.value as List);
      }

      trips.add({
        'property': widget.property.id,
        'amount': widget.property.price,
        'numberOfNights': widget.numberOfNights,
        'checkInDate': widget.checkInDate?.toIso8601String(),
        'checkOutDate': widget.checkOutDate?.toIso8601String(),
      });

      await tripsRef.set(trips);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ThankYouScreen(
            property: widget.property,
            checkInDate: widget.checkInDate,
            checkOutDate: widget.checkOutDate,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    int amount = widget.property.price * widget.numberOfNights;
    double gst = amount * 0.13;
    double totalAmount = amount + gst;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Personal Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: 'First Name'),
                validator: (value) =>
                value!.isEmpty ? 'First Name is required' : null,
              ),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Last Name'),
                validator: (value) =>
                value!.isEmpty ? 'Last Name is required' : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                    labelText: 'Phone Number',
                  counterText: '',
                ),
                keyboardType: TextInputType.phone,
                maxLength: 10,
                validator: (value) {
                  if (value == null || value.length != 10) {
                    return 'Phone Number must be 10 digits';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email Address'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  final emailRegex =
                  RegExp(r'^[^@]+@[^@]+\.[^@]+$'); // Simple email validation
                  if (value == null || !emailRegex.hasMatch(value)) {
                    return 'Enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Address',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Street'),
                validator: (value) =>
                value!.isEmpty ? 'Street is required' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Unit'),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'City'),
                validator: (value) =>
                value!.isEmpty ? 'City is required' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Province'),
                validator: (value) =>
                value!.isEmpty ? 'Province is required' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Country'),
                validator: (value) =>
                value!.isEmpty ? 'Country is required' : null,
              ),
              TextFormField(
                controller: _postalController,
                decoration: const InputDecoration(
                    labelText: 'Postal Code',
                  counterText: '',
                ),
                maxLength: 7,
                validator: (value) {
                  final postalRegex = RegExp(r'^[A-Za-z]\d[A-Za-z] \d[A-Za-z]\d$');
                  if (value == null || !postalRegex.hasMatch(value)) {
                    return 'Enter a valid Canadian postal code (e.g., N2J 3Y5)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Card Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Name on Card'),
                validator: (value) =>
                value!.isEmpty ? 'Name on card is required' : null,
              ),
              TextFormField(
                controller: _cardController,
                decoration: const InputDecoration(
                    labelText: 'Card Number',
                  counterText: '',
                ),
                keyboardType: TextInputType.number,
                maxLength: 16,
                validator: (value) {
                  if (value == null || value.length != 16) {
                    return 'Card Number must be 16 digits';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _cvvController,
                decoration: const InputDecoration(
                    labelText: 'CVV',
                  counterText: '',
                ),
                keyboardType: TextInputType.number,
                maxLength: 3,
                validator: (value) {
                  if (value == null || value.length != 3) {
                    return 'CVV must be 3 digits';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _expiryController,
                decoration: const InputDecoration(
                    labelText: 'Expiry MMYY',
                  counterText: '',
                ),
                keyboardType: TextInputType.number,
                maxLength: 4,
                validator: (value) {
                  final expiryRegex = RegExp(r'^(0[1-9]|1[0-2])\d{2}$');
                  if (value == null || !expiryRegex.hasMatch(value)) {
                    return 'Enter a valid expiry date (MMYY)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Amount: \$${amount.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 16),
              ),
              Text(
                'GST (13%): \$${gst.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 16),
              ),
              Text(
                'Total Amount: \$${totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _confirmPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentTeal,
                  foregroundColor: AppColors.backgroundWhite,
                ),
                child: const Text('Confirm Payment',),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
