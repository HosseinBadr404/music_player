import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'payment_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // User data
  String username = 'JohnDoe';
  String email = 'john.doe@example.com';
  String subscriptionPlan = 'Standard Plan';
  double credit = 25.60;
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  bool isDarkTheme = true;

  // Theme data
  late ThemeData _currentTheme;

  @override
  void initState() {
    super.initState();
    _updateTheme();
  }

  void _updateTheme() {
    _currentTheme = isDarkTheme ? _darkTheme : _lightTheme;
  }

  // Dark theme
  final ThemeData _darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.black,
    cardColor: const Color(0xFF1A1A1A),
    primaryColor: const Color(0xFF4CAF50),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF4CAF50),
      secondary: Color(0xFF1E2E23),
    ),
  );

  // Light theme
  final ThemeData _lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    cardColor: const Color(0xFFF5F5F5),
    primaryColor: const Color(0xFF4CAF50),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF4CAF50),
      secondary: Color(0xFFE8F5E9),
    ),
  );

  @override
  Widget build(BuildContext context) {
    _updateTheme();

    return Theme(
      data: _currentTheme,
      child: Scaffold(
        backgroundColor: _currentTheme.scaffoldBackgroundColor,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button and Profile title
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios,
                            color: _currentTheme.brightness == Brightness.dark ? Colors.white : Colors.black,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              'Profile',
                              style: TextStyle(
                                color: _currentTheme.brightness == Brightness.dark ? Colors.white : Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 48), // Balance the back button
                      ],
                    ),
                  ),

                  // Profile picture with upload button
                  Center(
                    child: Stack(
                      children: [
                        ClipOval(
                          child: Container(
                            width: 100,
                            height: 100,
                            color: _currentTheme.brightness == Brightness.dark ? Colors.grey[700] : Colors.grey[300],
                            child: _profileImage != null
                                ? Image.file(
                              _profileImage!,
                              fit: BoxFit.cover,
                            )
                                : Icon(
                              Icons.person,
                              size: 60,
                              color: _currentTheme.brightness == Brightness.dark ? Colors.grey : Colors.grey[600],
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: GestureDetector(
                            onTap: _showImagePicker,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Color(0xFF4CAF50),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // User Info Card
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: _currentTheme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        // Username row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Username',
                              style: TextStyle(
                                color: _currentTheme.brightness == Brightness.dark ? Colors.grey : Colors.grey[700],
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              username,
                              style: TextStyle(
                                color: _currentTheme.brightness == Brightness.dark ? Colors.white : Colors.black,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Email row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Email',
                              style: TextStyle(
                                color: _currentTheme.brightness == Brightness.dark ? Colors.grey : Colors.grey[700],
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              email,
                              style: TextStyle(
                                color: _currentTheme.brightness == Brightness.dark ? Colors.white : Colors.black,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Edit Profile Button
                        SizedBox(
                          width: double.infinity,
                          height: 45,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF005701),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: _showEditProfileDialog,
                            child: const Text(
                              'Edit Profile',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Available Credit
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: _currentTheme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Available Credit',
                              style: TextStyle(
                                color: _currentTheme.brightness == Brightness.dark ? Colors.white : Colors.black,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '\$${credit.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Color(0xFF4CAF50),
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _currentTheme.colorScheme.secondary,
                            foregroundColor: const Color(0xFF4CAF50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: () {
                            _showAddCreditOptions();
                          },
                          child: const Text('Add Credit'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Current Subscription
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: _currentTheme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Current Subscription',
                              style: TextStyle(
                                color: _currentTheme.brightness == Brightness.dark ? Colors.white : Colors.black,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              subscriptionPlan,
                              style: TextStyle(
                                color: _currentTheme.brightness == Brightness.dark ? Colors.grey : Colors.grey[700],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _currentTheme.colorScheme.secondary,
                            foregroundColor: const Color(0xFF4CAF50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: _showSubscriptionOptions,
                          child: const Text('Upgrade to Premium'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Dark Theme Toggle
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: _currentTheme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Dark Theme',
                          style: TextStyle(
                            color: _currentTheme.brightness == Brightness.dark ? Colors.white : Colors.black,
                            fontSize: 16,
                          ),
                        ),
                        Switch(
                          value: isDarkTheme,
                          onChanged: (value) {
                            setState(() {
                              isDarkTheme = value;
                              _updateTheme();
                            });
                          },
                          activeColor: const Color(0xFF4CAF50),
                          activeTrackColor: const Color(0xFF1E2E23),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Delete Account Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: _showDeleteAccountConfirmation,
                      child: const Text(
                        'Delete Account',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Show image picker options
  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _currentTheme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Change Profile Picture',
                style: TextStyle(
                  color: _currentTheme.brightness == Brightness.dark ? Colors.white : Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Color(0xFF4CAF50)),
                title: Text(
                  'Choose from Gallery',
                  style: TextStyle(color: _currentTheme.brightness == Brightness.dark ? Colors.white : Colors.black),
                ),
                onTap: () {
                  _getImage(ImageSource.gallery);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFF4CAF50)),
                title: Text(
                  'Take a Photo',
                  style: TextStyle(color: _currentTheme.brightness == Brightness.dark ? Colors.white : Colors.black),
                ),
                onTap: () {
                  _getImage(ImageSource.camera);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Get image from source
  Future<void> _getImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  // Edit profile dialog
  void _showEditProfileDialog() {
    final TextEditingController usernameController = TextEditingController(text: username);
    final TextEditingController emailController = TextEditingController(text: email);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: _currentTheme.cardColor,
          title: Text(
            'Edit Profile',
            style: TextStyle(color: _currentTheme.brightness == Brightness.dark ? Colors.white : Colors.black),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: usernameController,
                  style: TextStyle(color: _currentTheme.brightness == Brightness.dark ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    labelText: 'Username',
                    labelStyle: TextStyle(color: _currentTheme.brightness == Brightness.dark ? Colors.grey : Colors.grey[700]),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: _currentTheme.brightness == Brightness.dark ? Colors.grey : Colors.grey[400]!),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF4CAF50)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  style: TextStyle(color: _currentTheme.brightness == Brightness.dark ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(color: _currentTheme.brightness == Brightness.dark ? Colors.grey : Colors.grey[700]),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: _currentTheme.brightness == Brightness.dark ? Colors.grey : Colors.grey[400]!),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF4CAF50)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel', style: TextStyle(color: _currentTheme.brightness == Brightness.dark ? Colors.grey : Colors.grey[700])),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text('Save', style: TextStyle(color: Color(0xFF4CAF50))),
              onPressed: () {
                if (usernameController.text.isNotEmpty && emailController.text.isNotEmpty) {
                  setState(() {
                    username = usernameController.text;
                    email = emailController.text;
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile updated successfully')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Username and email cannot be empty')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Show subscription options with all three plans
  void _showSubscriptionOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _currentTheme.cardColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Premium Subscription',
                style: TextStyle(
                  color: _currentTheme.brightness == Brightness.dark ? Colors.white : Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Monthly Plan
              _buildSubscriptionOption(
                'Monthly Plan',
                '\$9.99/month',
                'Basic premium access',
                    () {
                  setState(() {
                    subscriptionPlan = 'Premium (Monthly)';
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Subscribed to Monthly Plan')),
                  );
                },
              ),

              const SizedBox(height: 10),

              // 3-Month Plan
              _buildSubscriptionOption(
                '3-Month Plan',
                '\$24.99',
                'Save 16% compared to monthly',
                    () {
                  setState(() {
                    subscriptionPlan = 'Premium (3 Months)';
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Subscribed to 3-Month Plan')),
                  );
                },
              ),

              const SizedBox(height: 10),

              // Yearly Plan
              _buildSubscriptionOption(
                'Yearly Plan',
                '\$99.99/year',
                'Save 17% compared to monthly',
                    () {
                  setState(() {
                    subscriptionPlan = 'Premium (Yearly)';
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Subscribed to Yearly Plan')),
                  );
                },
              ),

              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  // Helper method to build subscription option card
  Widget _buildSubscriptionOption(String title, String price, String description, VoidCallback onSelect) {
    return Container(
      decoration: BoxDecoration(
        color: _currentTheme.brightness == Brightness.dark ? const Color(0xFF242424) : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: _currentTheme.brightness == Brightness.dark ? Colors.white : Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  price,
                  style: const TextStyle(
                    color: Color(0xFF4CAF50),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: _currentTheme.brightness == Brightness.dark ? Colors.grey : Colors.grey[700],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: onSelect,
            child: const Text('Select'),
          ),
        ],
      ),
    );
  }

  // Add credit options
  void _showAddCreditOptions() {
    final amountController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: _currentTheme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Add Credit',
                style: TextStyle(
                  color: _currentTheme.brightness == Brightness.dark ? Colors.white : Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Enter amount',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                  labelStyle: TextStyle(
                    color: _currentTheme.brightness == Brightness.dark ? Colors.white70 : Colors.black87,
                  ),
                ),
                style: TextStyle(
                  color: _currentTheme.brightness == Brightness.dark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        final amount = double.tryParse(amountController.text);
                        if (amount != null && amount > 0) {
                          Navigator.pop(context);
                          _navigateToPaymentPage(amount);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter a valid amount')),
                          );
                        }
                      },
                      child: const Text('Proceed'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Future<void> _navigateToPaymentPage(double amount) async {
    // For demo purposes, we'll use a fixed password
    // In a real app, this would come from your authentication system
    String userPassword = "password1234";

    // Navigate to payment page
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PaymentPage(
          userPassword: userPassword,
          amount: amount,
        ),
      ),
    );

    // Handle the payment result
    if (result == true) {
      setState(() {
        credit += amount; // Update user's credit
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully added \$${amount.toStringAsFixed(2)} to your account'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }


  // Quick amount button for adding credit
  Widget _quickAmountButton(String amount) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: _currentTheme.colorScheme.secondary,
        foregroundColor: const Color(0xFF4CAF50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
      ),
      onPressed: () {
        setState(() {
          credit += double.parse(amount.substring(1));
        });
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$amount has been added to your account')),
        );
      },
      child: Text(amount),
    );
  }

  // Delete account confirmation
  void _showDeleteAccountConfirmation() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: _currentTheme.cardColor,
          title: Text(
            'Delete Account',
            style: TextStyle(color: _currentTheme.brightness == Brightness.dark ? Colors.white : Colors.black),
          ),
          content: Text(
            'Are you sure you want to delete your account? This action cannot be undone.',
            style: TextStyle(color: _currentTheme.brightness == Brightness.dark ? Colors.grey : Colors.grey[700]),
          ),
          actions: [
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(color: _currentTheme.brightness == Brightness.dark ? Colors.grey : Colors.grey[700]),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Account deletion initiated')),
                );
              },
            ),
          ],
        );
      },
    );
  }
}