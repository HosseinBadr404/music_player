import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'MusicShopPage.dart'; // For globalIsLoggedIn
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'PaymentPage.dart'; // Import PaymentPage

class AccountPage extends StatefulWidget {
  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  // Mock user data
  String username = "User123";
  String email = "user@example.com";
  String password = "********"; // Mock password (not shown in plain text)
  double credit = 10.50; // Mock credit
  String subscriptionType = "Normal"; // Normal or Premium
  String? profileImagePath; // Path to profile image (mock)
  bool isDarkTheme = true; // Theme state (local to AccountPage)

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _usernameController.text = username;
    _emailController.text = email;
    _passwordController.text = password;
  }

  // Mock function to pick profile image
  Future<void> _pickProfileImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          profileImagePath = image.path;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile picture updated')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  // Mock function to open camera
  Future<void> _takeProfilePicture() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        setState(() {
          profileImagePath = image.path;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile picture updated')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error taking picture: $e')),
      );
    }
  }

  // Show dialog to edit user information
  void _editUserInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: Text('Edit Profile', style: Theme.of(context).textTheme.titleLarge),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  filled: true,
                  fillColor: Colors.grey.shade800,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  filled: true,
                  fillColor: Colors.grey.shade800,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  filled: true,
                  fillColor: Colors.grey.shade800,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Mock validation: Password must be at least 8 characters
              if (_passwordController.text.length >= 8) {
                setState(() {
                  username = _usernameController.text;
                  email = _emailController.text;
                  password = _passwordController.text;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Profile updated')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Password must be at least 8 characters')),
                );
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  // Navigate to PaymentPage for credit increase
  void _increaseCredit() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentPage(
          amount: 10.0, // Mock amount
          paymentType: "Credit",
          userPassword: password,
          onCreditUpdate: (amount) {
            setState(() {
              credit += amount;
            });
          },
          onSubscriptionUpdate: (_) {},
        ),
      ),
    );
  }

  // Navigate to PaymentPage for premium subscription
  void _purchasePremiumSubscription(String plan) {
    double amount;
    switch (plan) {
      case 'Monthly':
        amount = 9.99;
        break;
      case '3-Month':
        amount = 24.99;
        break;
      case 'Yearly':
        amount = 89.99;
        break;
      default:
        amount = 9.99;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentPage(
          amount: amount,
          paymentType: "Subscription",
          subscriptionPlan: plan,
          userPassword: password,
          onCreditUpdate: (_) {},
          onSubscriptionUpdate: (plan) {
            setState(() {
              subscriptionType = "Premium";
            });
          },
        ),
      ),
    );
  }

  // Mock function to delete account
  void _deleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: Text('Delete Account', style: Theme.of(context).textTheme.titleLarge),
        content: Text('Are you sure you want to delete your account? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              globalIsLoggedIn = false;
              Navigator.pushReplacementNamed(context, '/music_shop');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Account deleted')),
              );
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  // Mock function to open live chat
  void _openLiveChat() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InAppWebViewPage(url: 'https://example.com/support-chat'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkTheme ? Colors.black : Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: ListView(
            children: [
              // Profile Picture
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: profileImagePath != null
                          ? FileImage(File(profileImagePath!))
                          : AssetImage('assets/images/c1.jpg') as ImageProvider,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: PopupMenuButton<String>(
                        icon: Icon(Icons.edit, color: Colors.white),
                        onSelected: (value) {
                          if (value == 'gallery') {
                            _pickProfileImage();
                          } else if (value == 'camera') {
                            _takeProfilePicture();
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'gallery',
                            child: Text('Choose from Gallery'),
                          ),
                          PopupMenuItem(
                            value: 'camera',
                            child: Text('Take a Picture'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              // Username
              Text(
                'Username: $username',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDarkTheme ? Colors.white : Colors.black,
                ),
              ),
              SizedBox(height: 10),
              // Email
              Text(
                'Email: $email',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDarkTheme ? Colors.white : Colors.black,
                ),
              ),
              SizedBox(height: 10),
              // Subscription Type
              Text(
                'Subscription: $subscriptionType',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDarkTheme ? Colors.white : Colors.black,
                ),
              ),
              SizedBox(height: 10),
              // Credit
              Text(
                'Credit: \$${credit.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDarkTheme ? Colors.white : Colors.black,
                ),
              ),
              SizedBox(height: 20),
              // Edit Profile Button
              ElevatedButton(
                onPressed: _editUserInfo,
                child: Text('Edit Profile'),
              ),
              SizedBox(height: 10),
              // Increase Credit Button
              ElevatedButton(
                onPressed: _increaseCredit,
                child: Text('Increase Credit'),
              ),
              SizedBox(height: 10),
              // Purchase Premium Subscription
              if (subscriptionType == "Normal")
                PopupMenuButton<String>(
                  child: ElevatedButton(
                    onPressed: null,
                    child: Text('Purchase Premium Subscription'),
                  ),
                  onSelected: _purchasePremiumSubscription,
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'Monthly',
                      child: Text('Monthly (\$9.99)'),
                    ),
                    PopupMenuItem(
                      value: '3-Month',
                      child: Text('3-Month (\$24.99)'),
                    ),
                    PopupMenuItem(
                      value: 'Yearly',
                      child: Text('Yearly (\$89.99)'),
                    ),
                  ],
                ),
              SizedBox(height: 10),
              // Theme Toggle
              ListTile(
                title: Text(
                  'Theme: ${isDarkTheme ? "Dark" : "Light"}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDarkTheme ? Colors.white : Colors.black,
                  ),
                ),
                trailing: Switch(
                  value: isDarkTheme,
                  onChanged: (value) {
                    setState(() {
                      isDarkTheme = value;
                    });
                  },
                ),
              ),
              SizedBox(height: 10),
              // Live Chat Support
              ElevatedButton(
                onPressed: _openLiveChat,
                child: Text('Contact Support'),
              ),
              SizedBox(height: 10),
              // Delete Account Button
              ElevatedButton(
                onPressed: _deleteAccount,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text('Delete Account'),
              ),
              SizedBox(height: 10),
              // Logout Button
              ElevatedButton(
                onPressed: () {
                  globalIsLoggedIn = false;
                  Navigator.pushReplacementNamed(context, '/music_shop');
                },
                child: Text('Logout'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InAppWebViewPage extends StatelessWidget {
  final String url;

  const InAppWebViewPage({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Support Chat')),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(url)),
      ),
    );
  }
}