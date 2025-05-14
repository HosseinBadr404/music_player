import 'package:flutter/material.dart';
import 'MusicShopPage.dart'; // For globalIsLoggedIn
import 'AccountPage.dart'; // For accessing user data (mock)

// Mock WebSocket simulation
void simulateWebSocketSend(Map<String, dynamic> data) {
  print('Simulating WebSocket send: $data');
  // In a real app, connect to a WebSocket server and send data
}

class PaymentPage extends StatefulWidget {
  final double amount; // Payment amount
  final String paymentType; // "Credit" or "Subscription"
  final String? subscriptionPlan; // Optional: Monthly, 3-Month, Yearly for subscriptions
  final String userPassword; // User's password to derive PIN
  final Function(double) onCreditUpdate; // Callback to update credit
  final Function(String) onSubscriptionUpdate; // Callback to update subscription

  const PaymentPage({
    super.key,
    required this.amount,
    required this.paymentType,
    this.subscriptionPlan,
    required this.userPassword,
    required this.onCreditUpdate,
    required this.onSubscriptionUpdate,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cardPinController = TextEditingController();
  bool _isLoading = false;

  // Validate PIN (last 4 characters of user's password)
  bool _validatePin(String inputPin) {
    String expectedPin = widget.userPassword.length >= 4
        ? widget.userPassword.substring(widget.userPassword.length - 4)
        : widget.userPassword.padRight(4, '0'); // Fallback for short passwords
    return inputPin == expectedPin;
  }

  // Simulate payment and update user data
  void _processPayment() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate network delay
    await Future.delayed(Duration(seconds: 1));

    if (_cardNumberController.text.isEmpty || _cardPinController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    if (!_validatePin(_cardPinController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid PIN. Use the last 4 characters of your password.')),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // Simulate successful payment
    if (widget.paymentType == "Credit") {
      widget.onCreditUpdate(widget.amount);
    } else if (widget.paymentType == "Subscription") {
      widget.onSubscriptionUpdate(widget.subscriptionPlan ?? "Premium");
    }

    // Simulate WebSocket data send
    simulateWebSocketSend({
      'userEmail': 'user@example.com', // Mock email from AccountPage
      'paymentType': widget.paymentType,
      'amount': widget.amount,
      'subscriptionPlan': widget.subscriptionPlan,
      'timestamp': DateTime.now().toIso8601String(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment successful!')),
    );

    // Navigate back to AccountPage
    Navigator.pop(context);

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Payment'),
        backgroundColor: Colors.grey.shade900,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: globalIsLoggedIn
              ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Payment Details',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 20),
              // Card Number
              TextField(
                controller: _cardNumberController,
                decoration: InputDecoration(
                  labelText: 'Card Number',
                  filled: true,
                  fillColor: Colors.grey.shade900,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 10),
              // Card PIN
              TextField(
                controller: _cardPinController,
                decoration: InputDecoration(
                  labelText: 'Card PIN (Last 4 chars of password)',
                  filled: true,
                  fillColor: Colors.grey.shade900,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                obscureText: true,
                keyboardType: TextInputType.text,
              ),
              SizedBox(height: 20),
              // Payment Amount
              Text(
                'Amount: \$${widget.amount.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              // Pay Button
              Center(
                child: _isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                  onPressed: _processPayment,
                  child: Text('Pay Now'),
                ),
              ),
            ],
          )
              : Center(
            child: Text(
              'Please log in to make a payment',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ),
      ),
    );
  }
}