import 'package:earthbnb/colors.dart';
import 'package:earthbnb/thankyou.dart';
import 'package:earthbnb/widgets/custom_appbar.dart';
import 'package:earthbnb/widgets/custom_input.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:earthbnb/PropertiesClass.dart';
import 'widgets/receipt_row.dart';
import 'widgets/custom_button.dart';

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

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final months = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    return "${months[date.month - 1]} ${date.day.toString().padLeft(2, '0')}, ${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    int amount = widget.property.price * widget.numberOfNights;
    double gst = amount * 0.13;
    double totalAmount = amount + gst;

    return Scaffold(
      appBar: const CustomAppBar(appBarText: 'Checkout'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'Personal Details',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                )
              ),
              const SizedBox(height: 20),
              CustomInput(inputText: 'First Name', inputController: _firstNameController, inputValidator: (value) => value!.isEmpty ? 'First Name is required' : null, textInputType: TextInputType.name, inputMaxLength: 200),
              const SizedBox(height: 20),
              CustomInput(inputText: 'Last Name', inputController: _lastNameController, inputValidator: (value) => value!.isEmpty ? 'Last Name is required' : null, textInputType: TextInputType.name, inputMaxLength: 200),
              const SizedBox(height: 20),
              CustomInput(inputText: 'Phone Number', inputController: _phoneController, inputValidator: (value) {
                if (value == null || value.length != 10) {
                  return 'Phone Number must be 10 digits';
                }
                return null;
              },
              textInputType: TextInputType.phone, inputMaxLength: 10),
              const SizedBox(height: 20),
              CustomInput(inputText: 'Email Address', inputController: _emailController, inputValidator: (value) {
                final emailRegex =
                RegExp(r'^[^@]+@[^@]+\.[^@]+$'); // Simple email validation
                if (value == null || !emailRegex.hasMatch(value)) {
                  return 'Enter a valid email address';
                }
                return null;
              }, textInputType: TextInputType.emailAddress, inputMaxLength: 200),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  'Address',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                )
              ),
              const SizedBox(height: 20),
              CustomInput(inputText: 'Street', inputController: TextEditingController(), inputValidator: (value) => value!.isEmpty ? 'Street is required' : null, textInputType: TextInputType.streetAddress, inputMaxLength: 200),
              const SizedBox(height: 20),
              CustomInput(inputText: 'Unit', inputController: TextEditingController(), inputValidator: (value) => value!.isEmpty ? 'Unit is required' : null, textInputType: TextInputType.streetAddress, inputMaxLength: 200),
              const SizedBox(height: 20),
              CustomInput(inputText: 'City', inputController: TextEditingController(), inputValidator: (value) => value!.isEmpty ? 'City is required' : null, textInputType: TextInputType.streetAddress, inputMaxLength: 200),
              const SizedBox(height: 20),
              CustomInput(inputText: 'Province', inputController: TextEditingController(), inputValidator: (value) => value!.isEmpty ? 'Province is required' : null, textInputType: TextInputType.streetAddress, inputMaxLength: 200),
              const SizedBox(height: 20),
              CustomInput(inputText: 'Country', inputController: TextEditingController(), inputValidator: (value) => value!.isEmpty ? 'Country is required' : null, textInputType: TextInputType.streetAddress, inputMaxLength: 200),
              const SizedBox(height: 20),
              CustomInput(inputText: 'Postal Code', inputController: _postalController, inputValidator: (value) {
                final postalRegex = RegExp(r'^[A-Za-z]\d[A-Za-z] \d[A-Za-z]\d$');
                if (value == null || !postalRegex.hasMatch(value)) {
                  return 'Enter a valid Canadian postal code (e.g., N2J 3Y5)';
                }
                return null;
              }, textInputType: TextInputType.streetAddress, inputMaxLength: 7),
              const SizedBox(height: 20),

              const Center(
                child: Text(
                  'Card Details',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              CustomInput(inputText: 'Name on Card', inputController: TextEditingController(), inputValidator: (value) => value!.isEmpty ? 'Name on card is required' : null, textInputType: TextInputType.name, inputMaxLength: 200),
              const SizedBox(height: 20),
              CustomInput(inputText: 'Card Number', inputController: _cardController, inputValidator: (value) {
                if (value == null || value.length != 16) {
                  return 'Card Number must be 16 digits';
                }
                return null;
              }, textInputType: TextInputType.number, inputMaxLength: 16),
              const SizedBox(height: 20),
              CustomInput(inputText: 'CVV', inputController: _cvvController, inputValidator: (value) {
                if (value == null || value.length != 3) {
                  return 'CVV must be 3 digits';
                }
                return null;
              }, textInputType: TextInputType.number, inputMaxLength: 3),
              const SizedBox(height: 20),
              CustomInput(inputText: 'Expiry MMYY', inputController: _expiryController, inputValidator: (value) {
                final expiryRegex = RegExp(r'^(0[1-9]|1[0-2])\d{2}$');
                if (value == null || !expiryRegex.hasMatch(value)) {
                  return 'Enter a valid expiry date (MMYY)';
                }
                return null;
              }, textInputType: TextInputType.number, inputMaxLength: 4),
              const SizedBox(height: 30),
              ReceiptRow(keyText: 'Check-in:', valueText: _formatDate(widget.checkInDate)),
              const SizedBox(height: 8),
              ReceiptRow(keyText: 'Check-out:', valueText: _formatDate(widget.checkOutDate)),
              const SizedBox(height: 8),
              ReceiptRow(keyText: 'Price for ${widget.numberOfNights} nights:', valueText: '\$${amount.toStringAsFixed(2)}'),
              const SizedBox(height: 8),
              ReceiptRow(keyText: 'GST (13%):', valueText: '\$${gst.toStringAsFixed(2)}'),
              const SizedBox(height: 8),
              ReceiptRow(keyText: 'Total Amount:', valueText: '\$${totalAmount.toStringAsFixed(2)}'),
              const SizedBox(height: 30),
              Center(child: CustomButton(buttonText: 'Confirm Payment', isColored: "true", onPressed: _confirmPayment, buttonColor: AppColors.accentTeal)),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String key, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30), // Adjust horizontal padding to control row width
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space between key and value
        children: [
          Expanded(
            child: Text(
              key,
              style: TextStyle(
                fontWeight: key == "Total Amount:" ? FontWeight.bold : FontWeight.normal,
                fontSize: key == "Total Amount:" ? 22 : 18,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: key == "Total Amount:" ? FontWeight.bold : FontWeight.normal,
              fontSize: key == "Total Amount:" ? 22 : 18,
            ),
          ),
        ],
      ),
    );
  }
}
