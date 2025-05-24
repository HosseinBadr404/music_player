import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PaymentPage extends StatefulWidget {
  final String userPassword;
  final double amount;
  final bool isSubscription; // اضافه کردن پارامتر

  const PaymentPage({
    Key? key,
    required this.userPassword,
    required this.amount,
    this.isSubscription = false, // مقدار پیش‌فرض
  }) : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  bool _isProcessing = false;
  String? _errorMessage;

  // PIN ثابت برای همه کاربران
  String get _expectedPin {
    return '1234'; // PIN ثابت
  }

  void _processPayment() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isProcessing = true;
        _errorMessage = null;
      });

      // Simulate network delay
      Future.delayed(const Duration(seconds: 2), () {
        if (_pinController.text == _expectedPin) {
          // Payment successful
          _showSuccessDialog();
        } else {
          // Payment failed
          setState(() {
            _isProcessing = false;
            _errorMessage = "Incorrect PIN entered. Please use PIN: 1234";
          });
        }
      });
    }
  }


  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          widget.isSubscription ? "Subscription Activated!" : "Payment Successful",
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 60),
            const SizedBox(height: 20),
            Text(
              widget.isSubscription
                  ? "Your subscription has been activated for 30 days!"
                  : "Payment of \$${widget.amount} was completed successfully",               textAlign: TextAlign.center,             ),           ],         ),         actions: [           TextButton(             onPressed: () {               Navigator.of(context).pop();               Navigator.of(context).pop(true);             },             child: const Text("OK"),           ),         ],       ),     );   }    @override   Widget build(BuildContext context) {     return Scaffold(       appBar: AppBar(         title: Text(widget.isSubscription ? "Subscribe" : "Payment Page"),         centerTitle: true,       ),       body: Directionality(         textDirection: TextDirection.ltr,         child: Padding(           padding: const EdgeInsets.all(16.0),           child: Form(             key: _formKey,             child: Column(               crossAxisAlignment: CrossAxisAlignment.stretch,               children: [                 Container(                   padding: const EdgeInsets.all(16),                   decoration: BoxDecoration(                     color: Colors.grey[800],                     borderRadius: BorderRadius.circular(8),                   ),                   child: Column(                     children: [                       Text(                         widget.isSubscription ? "Subscription Fee:" : "Amount to Pay:",                         style: const TextStyle(fontSize: 16),                       ),                       const SizedBox(height: 8),                       Text(                         "\$${widget.amount}",
    style: const TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: Colors.green,
    ),
  ),
    if (widget.isSubscription)
      const Text(
        "30 days unlimited access",
        style: TextStyle(fontSize: 12, color: Colors.grey),
      ),
  ],
  ),
  ),

    const SizedBox(height: 24),

    // Card number
    TextFormField(
      controller: _cardNumberController,
      decoration: const InputDecoration(
        labelText: "Card Number",
        hintText: "---- ---- ---- ----",
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.credit_card),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(16),
        _CardNumberFormatter(),
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please enter card number";
        }
        if (value.replaceAll(' ', '').length != 16) {
          return "Card number must be 16 digits";
        }
        return null;
      },
    ),

    const SizedBox(height: 16),

    // PIN field
    TextFormField(
      controller: _pinController,
      decoration: const InputDecoration(
        labelText: "Card PIN",
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.lock),
      ),
      obscureText: true,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(4),
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please enter card PIN";
        }
        return null;
      },
    ),

    if (_errorMessage != null) ...[
      const SizedBox(height: 16),
      Text(
        _errorMessage!,
        style: const TextStyle(color: Colors.red),
        textAlign: TextAlign.center,
      ),
    ],

    const SizedBox(height: 24),

    ElevatedButton(
      onPressed: _isProcessing ? null : _processPayment,
      child: _isProcessing
          ? const CircularProgressIndicator()
          : Text(widget.isSubscription ? "Subscribe Now" : "Pay Now"),
    ),
  ],
  ),
  ),
  ),
  ),
  );
  }
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(text[i]);
    }
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}
