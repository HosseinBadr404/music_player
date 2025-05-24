import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'payment_page.dart';
import 'fake_user_data.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String username = '';
  String email = '';
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
    if (FakeUserData.currentUser != null) {
      username = FakeUserData.currentUser!.name;
      email = FakeUserData.currentUser!.email;
      credit = FakeUserData.currentUser!.balance;
    }
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
                        const SizedBox(width: 48),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Username',
                              style: TextStyle(
                                color: _currentTheme.brightness == Brightness.dark ? Colors.grey : Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.edit,
                                color: _currentTheme.brightness == Brightness.dark ? Colors.white : Colors.black,
                                size: 20,
                              ),
                              onPressed: _showEditProfileDialog,
                            ),
                          ],
                        ),
                        Text(
                          username,
                          style: TextStyle(
                            color: _currentTheme.brightness == Brightness.dark ? Colors.white : Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Email',
                          style: TextStyle(
                            color: _currentTheme.brightness == Brightness.dark ? Colors.grey : Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          email,
                          style: TextStyle(
                            color: _currentTheme.brightness == Brightness.dark ? Colors.white : Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Subscription',
                          style: TextStyle(
                            color: _currentTheme.brightness == Brightness.dark ? Colors.white : Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        if (FakeUserData.currentUser?.isSubscriptionActive == true) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.green),
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  'Premium Active',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  '${FakeUserData.currentUser!.remainingSubscriptionDays} days remaining',
                                  style: const TextStyle(color: Colors.green),
                                ),
                              ],
                            ),
                          ),
                        ] else ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.orange),
                            ),
                            child: const Column(
                              children: [
                                Text(
                                  'Standard Plan',
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'Upgrade to Premium for unlimited access',
                                  style: TextStyle(color: Colors.orange),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {  // تغییر این خط
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PaymentPage(
                                      userPassword: "1234",
                                      amount: 9.99,
                                      isSubscription: true,
                                    ),
                                  ),
                                );
                                if (result == true) {
                                  setState(() {
                                    // کاربر را Premium کن
                                    if (FakeUserData.currentUser != null) {
                                      FakeUserData.currentUser!.subscriptionEndDate =
                                          DateTime.now().add(Duration(days: 30));
                                    }
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Premium subscription activated!'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6C63FF),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 15),
                              ),
                              child: const Text(
                                'Upgrade to Premium',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                          ),
                        ],
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Available Credit',
                          style: TextStyle(
                            color: _currentTheme.brightness == Brightness.dark ? Colors.white : Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.blue),
                          ),
                          child: Column(
                            children: [
                              Text(
                                '\$${FakeUserData.currentUser?.balance.toStringAsFixed(2) ?? "0.00"}',
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              const Text(
                                'Current Balance',
                                style: TextStyle(color: Colors.blue),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: Container(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _showAddCreditDialog,
                              icon: const Icon(Icons.add, color: Colors.white),
                              label: const Text(
                                'Add Credit',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0842A8),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Settings
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: _currentTheme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Settings',
                          style: TextStyle(
                            color: _currentTheme.brightness == Brightness.dark ? Colors.white : Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Dark Mode Toggle
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Dark Mode',
                              style: TextStyle(
                                color: _currentTheme.brightness == Brightness.dark ? Colors.white : Colors.black,
                                fontSize: 14,
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
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Logout Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _showLogoutConfirmation,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                            ),
                            child: const Text(
                              'Logout',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Image picker method
  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _currentTheme.cardColor,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Library'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
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
  void _showAddCreditDialog() {
    final TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: _currentTheme.cardColor,
          title: Text(
            'Add Credit',
            style: TextStyle(
              color: _currentTheme.brightness == Brightness.dark ? Colors.white : Colors.black,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Enter amount to add to your account:',
                style: TextStyle(
                  color: _currentTheme.brightness == Brightness.dark ? Colors.white70 : Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Amount (\$)',
                  border: OutlineInputBorder(),
                  prefixText: '\$',
                  labelStyle: TextStyle(
                    color: _currentTheme.brightness == Brightness.dark ? Colors.white70 : Colors.black54,
                  ),
                ),
                style: TextStyle(
                  color: _currentTheme.brightness == Brightness.dark ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final String amountText = amountController.text.trim();
                if (amountText.isNotEmpty) {
                  final double? amount = double.tryParse(amountText);
                  if (amount != null && amount > 0) {
                    Navigator.of(context).pop();
                    _processAddCredit(amount);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please enter a valid amount')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please enter an amount')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF4CAF50),
              ),
              child: Text('Add Credit'),
            ),
          ],
        );
      },
    );
  }

  void _processAddCredit(double amount) async {
    if (FakeUserData.currentUser == null) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentPage(
          userPassword: '1234', // PIN ثابت
          amount: amount,
        ),
      ),
    );

    if (result == true) {
      setState(() {
        FakeUserData.currentUser!.balance += amount;
        credit = FakeUserData.currentUser!.balance;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully added \$${amount.toStringAsFixed(2)} to your account!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _upgradeToPremium() async {
    const double premiumPrice = 9.99;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentPage(
          userPassword: '1234', // PIN ثابت
          amount: premiumPrice,
        ),
      ),
    );

    if (result == true) {
      // Payment successful, upgrade user to premium
      setState(() {
        if (FakeUserData.currentUser != null) {
          FakeUserData.currentUser!.subscriptionEndDate =
              DateTime.now().add(Duration(days: 30));
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully upgraded to Premium!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }


  // Logout confirmation
  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: _currentTheme.cardColor,
          title: Text(
            'Logout',
            style: TextStyle(
              color: _currentTheme.brightness == Brightness.dark ? Colors.white : Colors.black,
            ),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: TextStyle(
              color: _currentTheme.brightness == Brightness.dark ? Colors.grey : Colors.grey[700],
            ),
          ),
          actions: [
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: _currentTheme.brightness == Brightness.dark ? Colors.grey : Colors.grey[700],
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
              onPressed: () {
                FakeUserData.logout();
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to previous screen
              },
            ),
          ],
        );
      },
    );
  }





}
