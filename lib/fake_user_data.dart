class User {
  final String name;
  final String email;
  final String password;
  double balance;
  final List<String> purchasedMusic;
  DateTime? subscriptionEndDate;

  User({
    required this.name,
    required this.email,
    required this.password,
    required this.balance,
    required this.purchasedMusic,
    this.subscriptionEndDate,
  });

  bool get isSubscriptionActive {
    if (subscriptionEndDate == null) return false;
    return subscriptionEndDate!.isAfter(DateTime.now());
  }

  int get remainingSubscriptionDays {
    if (!isSubscriptionActive) return 0;
    return subscriptionEndDate!.difference(DateTime.now()).inDays;
  }

  bool deductBalance(double amount) {
    if (balance >= amount) {
      balance -= amount;
      return true;
    }
    return false;
  }

  bool hasPurchased(String musicTitle) {
    return purchasedMusic.contains(musicTitle);
  }

  void activatePremiumSubscription({int days = 30}) {
    if (isSubscriptionActive) {
      subscriptionEndDate = subscriptionEndDate!.add(Duration(days: days));
    }
    else {
      subscriptionEndDate = DateTime.now().add(Duration(days: days));
    }
  }

  void addBalance(double amount) {
    if (amount > 0) {
      balance += amount;
    }
  }
}

class FakeUserData {
  static List<User> users = [
    User(
      name: 'Ali Rezaei',
      email: 'ali@example.com',
      password: 'password123',
      balance: 1.0,
      purchasedMusic: ['Song 1', 'Song 2'],
      subscriptionEndDate: null,
    ),
    User(
      name: 'Sara Ahmadi',
      email: 'sara@example.com',
      password: 'password456',
      balance: 20.0,
      purchasedMusic: ['Song 3'],
      subscriptionEndDate: DateTime.now().add(Duration(days: 15)),
    ),
  ];
  static User? currentUser;

  static bool login(String email, String password) {
    try {
      final user = users.firstWhere(
            (user) => user.email == email && user.password == password,
      );
      currentUser = user;
      return true;
    } catch (e) {
      return false;
    }
  }

  static bool signUp(String name, String email, String password) {
    if (users.any((user) => user.email == email)) {
      return false;
    }
    // Create new user with initial balance of 10.0
    final newUser = User(
      name: name,
      email: email,
      password: password,
      balance: 10.0,
      purchasedMusic: [],
      subscriptionEndDate: null,
    );
    users.add(newUser);
    currentUser = newUser;
    return true;
  }

  static bool isLoggedIn() {
    return currentUser != null;
  }

  static void logout() {
    currentUser = null;
  }
}