import 'package:music_player/socket_service.dart';

/// Represents a user entity.
class User {
  final String name;
  final String email;
  final String password;
  final double balance;
  final List<String> purchasedMusic;
  final DateTime? subscriptionEndDate;

  User({
    required this.name,
    required this.email,
    required this.password,
    required this.balance,
    required this.purchasedMusic,
    this.subscriptionEndDate,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'] as String? ?? 'Unknown',
      email: json['email'] as String? ?? '',
      password: json['password'] as String? ?? '',
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      purchasedMusic: (json['purchasedMusic'] as List<dynamic>?)?.cast<String>() ?? [],
      subscriptionEndDate: json['subscriptionEndDate'] != null
          ? DateTime.parse(json['subscriptionEndDate'] as String)
          : null,
    );
  }
}

/// Manages user-related operations.
class UserData {
  static final SocketService _socketService = SocketService(host: '10.0.2.2', port: 8081);
  static User? currentUser;

  /// Logs in a user with email and password.
  static Future<bool> login(String email, String password) async {
    try {
      final response = await _socketService.send(
        action: 'login',
        data: {'email': email, 'password': password},
      );
      if (response['status'] == 'success' && response['data'] != null) {
        currentUser = User.fromJson(response['data'] as Map<String, dynamic>);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Signs up a new user.
  static Future<bool> signUp(String name, String email, String password) async {
    try {
      final response = await _socketService.send(
        action: 'signUp',
        data: {'name': name, 'email': email, 'password': password},
      );
      if (response['status'] == 'success' && response['data'] != null) {
        currentUser = User.fromJson(response['data'] as Map<String, dynamic>);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Retrieves user information.
  static Future<User?> getUserInfo() async {
    if (currentUser == null) return null;
    try {
      final response = await _socketService.send(
        action: 'get_user_info',
        data: {'userEmail': currentUser!.email},
      );
      if (response['status'] == 'success' && response['data'] != null) {
        currentUser = User.fromJson(response['data'] as Map<String, dynamic>);
        return currentUser;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Adds balance to the user's account.
  static Future<bool> addBalance(double amount) async {
    if (currentUser == null || amount <= 0) return false;
    try {
      final response = await _socketService.send(
        action: 'addBalance',
        data: {
          'userEmail': currentUser!.email,
          'amount': amount,
        },
      );
      if (response['status'] == 'success' && response['data'] != null) {
        currentUser = User.fromJson(response['data'] as Map<String, dynamic>);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Updates user information.
  static Future<bool> updateUserInfo(String newName, String newEmail) async {
    if (currentUser == null) return false;
    try {
      final response = await _socketService.send(
        action: 'update_user_info',
        data: {
          'oldEmail': currentUser!.email,
          'newName': newName,
          'newEmail': newEmail,
        },
      );
      if (response['status'] == 'success' && response['data'] != null) {
        currentUser = User.fromJson(response['data'] as Map<String, dynamic>);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Checks if the user has an active subscription.
  static Future<bool> isSubscriptionActive() async {
    if (currentUser == null) return false;
    try {
      final response = await _socketService.send(
        action: 'check_subscription',
        data: {'userEmail': currentUser!.email},
      );
      if (response['status'] == 'success' && response['data'] != null) {
        return (response['data'] as Map<String, dynamic>)['isActive'] as bool;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Retrieves remaining subscription days.
  static Future<int> remainingSubscriptionDays() async {
    if (currentUser == null) return 0;
    try {
      final response = await _socketService.send(
        action: 'check_subscription',
        data: {'userEmail': currentUser!.email},
      );
      if (response['status'] == 'success' && response['data'] != null) {
        return (response['data'] as Map<String, dynamic>)['remainingDays'] as int;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  /// Checks if the user has purchased a music item.
  static Future<bool> hasPurchased(String musicTitle) async {
    if (currentUser == null) return false;
    try {
      final response = await _socketService.send(
        action: 'check_purchase',
        data: {
          'userEmail': currentUser!.email,
          'musicTitle': musicTitle,
        },
      );
      if (response['status'] == 'success' && response['data'] != null) {
        return (response['data'] as Map<String, dynamic>)['hasPurchased'] as bool;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Checks if the user is logged in.
  static bool isLoggedIn() {
    return currentUser != null;
  }

  /// Logs out the current user.
  static Future<bool> logout() async {
    if (currentUser == null) return true;
    try {
      final response = await _socketService.send(
        action: 'logout',
        data: {'userEmail': currentUser!.email},
      );
      currentUser = null;
      return response['status'] == 'success';
    } catch (e) {
      currentUser = null;
      return true;
    }
  }
}