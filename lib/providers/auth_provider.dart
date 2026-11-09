// import 'package:flutter/foundation.dart';
// import '../models/app_user.dart';
// import 'package:uuid/uuid.dart';

// // This provider manages user authentication and roles
// class AuthProvider with ChangeNotifier {
//   //we have a private variable called _currentUser of type AppUser
//   AppUser? _currentUser;

//   // we have a getter called currentUser which returns the private variable _currentUser
//   AppUser? get currentUser => _currentUser;
//   // we have a getter called isLoggedIn which returns true if the private variable _currentUser is not null
//   bool get isLoggedIn => _currentUser != null;
//   // we have a getter called isManager which returns true if the private variable _currentUser is not null and the role of the user is manager
//   bool get isManager => _currentUser?.role == UserRole.manager;

//   // Demo users (replace with real auth later)
//   final List<AppUser> _users = [
//     AppUser(
//       id: '1',
//       username: 'cashier',
//       password: '1234',
//       role: UserRole.cashier,
//     ),
//     AppUser(
//       id: '2',
//       username: 'manager',
//       password: 'admin',
//       role: UserRole.manager,
//     ),
//   ];

//   Future<bool> login(String username, String password) async {
//     // Simulate network delay
//     await Future.delayed(const Duration(milliseconds: 600));

//     try {
//       final user = _users.firstWhere(
//         //
//         (u) => u.username == username && u.password == password,
//       );
//       _currentUser = user;
//       notifyListeners();
//       return true;
//     } catch (_) {
//       return false;
//     }
//   }

//   void logout() {
//     _currentUser = null;
//     notifyListeners();
//   }

//   // Optional: add new user (manager only)
//   void addUser(String username, String password, UserRole role) {
//     _users.add(AppUser(
//       id: const Uuid().v4(),
//       username: username,
//       password: password,
//       role: role,
//     ));
//     notifyListeners();
//   }
// }
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// This provider manages user authentication and roles
enum UserRole { cashier, manager }

// This class represents a user in the application
class AppUser {
  final String id;
  final String username;
  final String email;
  final UserRole role;
  final String? fullName;

  // Constructor for the AppUser class
  AppUser({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    this.fullName,
  });

  // Factory method to create an AppUser instance from a map (e.g., from Firestore)
  factory AppUser.fromMap(String id, Map<String, dynamic> data) {
    return AppUser(
      // Assign values from the map to the AppUser properties, providing default values if necessary
      id: id,
      // Use null-aware operators to provide default values if the data is missing
      username: data['username'] ?? '',
      // Use null-aware operators to provide default values if the data is missing
      email: data['email'] ?? '',
      // Determine the user role based on the string value in the data map
      role: data['role'] == 'manager' ? UserRole.manager : UserRole.cashier,
      // Use null-aware operators to provide default values if the data is missing
      fullName: data['fullName'],
    );
  }
}

// This provider manages user authentication and roles
class AuthProvider with ChangeNotifier {
  // Firebase Authentication instance
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Firebase Firestore instance
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Private variable to hold the current user
  AppUser? _currentUser;
  // Getter for the current user
  AppUser? get currentUser => _currentUser;
  // Getter for the login status
  bool get isLoggedIn => _currentUser != null;
  // Getter to check if the current user is a manager
  bool get isManager => _currentUser?.role == UserRole.manager;

  // Method to log in a user with email and password
  Future<String?> login(String email, String password) async {
    // Simulate network delay
    try {
      //this is a function from Firebase Authentication
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      //
      final doc = await _db.collection('users').doc(cred.user!.uid).get();
      // if the user doesnot exist then the return profile not found.
      if (!doc.exists) return 'User profile not found';

      //put the current user details into a map
      _currentUser = AppUser.fromMap(doc.id, doc.data()!);
      //
      notifyListeners();
      return null; // success
    } on FirebaseAuthException catch (e) {
      // if all this fails then return message which says the login has failed.
      return e.message ?? 'Login failed';
    } catch (e) {
      return e.toString();
    }
  }

  //logging out
  Future<void> logout() async {
    await _auth.signOut();
    _currentUser = null;
    notifyListeners();
  }

  // Call this once to create demo users in Firebase Console or from code
  Future<void> registerUser({
    required String email,
    required String password,
    required String username,
    required UserRole role,
    String? fullName,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await _db.collection('users').doc(cred.user!.uid).set({
      'username': username,
      'email': email,
      'role': role == UserRole.manager ? 'manager' : 'cashier',
      'fullName': fullName,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}