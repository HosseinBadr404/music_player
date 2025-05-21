class User {
  final String name;
  final String email;
  final String password;
  final double balance;
  final List<String> purchasedMusic;

  User({
    required this.name,
    required this.email,
    required this.password,
    required this.balance,
    required this.purchasedMusic,
  });
}

class FakeUserData {
  static List<User> users = [
    User(
      name: 'Ali Rezaei',
      email: 'ali@example.com',
      password: 'password123',
      balance: 50.0,
      purchasedMusic: ['Song 1', 'Song 2'],
    ),
    User(
      name: 'Sara Ahmadi',
      email: 'sara@example.com',
      password: 'password456',
      balance: 20.0,
      purchasedMusic: ['Song 3'],
    ),
  ];

  // کاربر فعلی که لاگین کرده
  static User? currentUser;

  // چک کردن لاگین
  static bool login(String email, String password) {
    final user = users.firstWhere(
          (user) => user.email == email && user.password == password,
      orElse: () => User(
        name: '',
        email: '',
        password: '',
        balance: 0.0,
        purchasedMusic: [],
      ),
    );
    if (user.email.isNotEmpty) {
      currentUser = user;
      return true;
    }
    return false;
  }

  // ثبت‌نام کاربر جدید
  static bool signUp(String name, String email, String password) {
    if (users.any((user) => user.email == email)) {
      return false; // ایمیل قبلاً ثبت شده
    }
    final newUser = User(
      name: name,
      email: email,
      password: password,
      balance: 10.0, // موجودی اولیه
      purchasedMusic: [],
    );
    users.add(newUser);
    currentUser = newUser;
    return true;
  }

  // چک کردن وضعیت لاگین
  static bool isLoggedIn() {
    return currentUser != null;
  }

  // خروج از حساب
  static void logout() {
    currentUser = null;
  }
}