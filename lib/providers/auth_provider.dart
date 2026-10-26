import 'package:flutter/foundation.dart';
import '../models/app_user.dart';
import 'package:uuid/uuid.dart';

// This provider manages user authentication and roles
class AuthProvider with ChangeNotifier {
  //we have a private variable called _currentUser of type AppUser
  AppUser? _currentUser;

  // we have a getter called currentUser which returns the private variable _currentUser
  AppUser? get currentUser => _currentUser;
  // we have a getter called isLoggedIn which returns true if the private variable _currentUser is not null
  bool get isLoggedIn => _currentUser != null;
  // we have a getter called isManager which returns true if the private variable _currentUser is not null and the role of the user is manager
  bool get isManager => _currentUser?.role == UserRole.manager;

  // Demo users (replace with real auth later)
  final List<AppUser> _users = [
    AppUser(
      id: '1',
      username: 'cashier',
      password: '1234',
      role: UserRole.cashier,
    ),
    AppUser(
      id: '2',
      username: 'manager',
      password: 'admin',
      role: UserRole.manager,
    ),
  ];

  Future<bool> login(String username, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));

    try {
      final user = _users.firstWhere(
        //
        (u) => u.username == username && u.password == password,
      );
      _currentUser = user;
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  // Optional: add new user (manager only)
  void addUser(String username, String password, UserRole role) {
    _users.add(AppUser(
      id: const Uuid().v4(),
      username: username,
      password: password,
      role: role,
    ));
    notifyListeners();
  }
}