enum UserRole { 
  cashier,
  manager }

// This class represents a user in the app
class AppUser {
  final String id;
  final String username;
  final String password;       // In real app use hashed + auth
  final UserRole role;

  //
  AppUser({
    required this.id,
    required this.username,
    required this.password,
    required this.role,
  });
}