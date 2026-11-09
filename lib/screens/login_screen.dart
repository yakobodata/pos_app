 
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../providers/auth_provider.dart';
// import 'home_screen.dart'; // change to your actual home screen path

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {

//   final _formKey = GlobalKey<FormState>();
//   //This is the code to the username or password
//   final _usernameController = TextEditingController();
//   // this is the password code
//   final _passwordController = TextEditingController();

//   bool _isLoading = false;
//   bool _obscurePassword = true;
//   String? _errorMessage;

//   @override
//   void dispose() {
//     _usernameController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   Future<void> _login() async {
//     //If the form has errors, stop here and don’t continue with the login.
//     if (!_formKey.currentState!.validate()) return;

//     //Start loading and hide any old error message.
//     setState(() {_isLoading = true;_errorMessage = null;});

//     //Get the AuthProvider instance from the widget tree so I can call its login method
//     final auth = context.read<AuthProvider>();

//     final success = await auth.login(
//       _usernameController.text.trim(),
//       _passwordController.text,
//     );

//     //If this screen is already gone, don’t continue.
//     if (!mounted) return;

//     //“Stop showing the loading spinner.”
//     setState(() => _isLoading = false);

//     if (success) {
//       // Navigate to home and remove login from stack
//       Navigator.of(context).pushReplacement(
//         MaterialPageRoute(builder: (_) => const HomeScreen()),
//       );
//     } else {
//       setState(() {
//         _errorMessage = 'Invalid username or password';
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Center(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   // Logo / Title
//                   Icon(
//                     Icons.point_of_sale_rounded,
//                     size: 80,
//                     color: Theme.of(context).colorScheme.primary,
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     'POS System',
//                     style: Theme.of(context).textTheme.headlineMedium?.copyWith(
//                           fontWeight: FontWeight.bold,
//                         ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     'Sign in to continue',
//                     style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//                           color: Colors.grey[600],
//                         ),
//                   ),
//                   const SizedBox(height: 40),

//                   // Username
//                   TextFormField(
//                     controller: _usernameController,
//                     decoration: InputDecoration(
//                       labelText: 'Username',
//                       prefixIcon: const Icon(Icons.person_outline),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     textInputAction: TextInputAction.next,
//                     validator: (value) {
//                       if (value == null || value.trim().isEmpty) {
//                         return 'Please enter username';
//                       }
//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 16),

//                   // Password
//                   TextFormField(
//                     controller: _passwordController,
//                     obscureText: _obscurePassword,
//                     decoration: InputDecoration(
//                       labelText: 'Password',
//                       prefixIcon: const Icon(Icons.lock_outline),
//                       suffixIcon: IconButton(
//                         icon: Icon(
//                           _obscurePassword
//                               ? Icons.visibility_off
//                               : Icons.visibility,
//                         ),
//                         onPressed: () {
//                           setState(() => _obscurePassword = !_obscurePassword);
//                         },
//                       ),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     textInputAction: TextInputAction.done,
//                     onFieldSubmitted: (_) => _login(),
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please enter password';
//                       }
//                       return null;
//                     },
//                   ),

//                   // Error message
//                   if (_errorMessage != null) ...[
//                     const SizedBox(height: 16),
//                     Text(
//                       _errorMessage!,
//                       style: const TextStyle(color: Colors.red, fontSize: 14),
//                     ),
//                   ],

//                   const SizedBox(height: 28),

//                   // Login button
//                   SizedBox(
//                     width: double.infinity,
//                     height: 52,
//                     child: ElevatedButton(
//                       onPressed: _isLoading ? null : _login,
//                       style: ElevatedButton.styleFrom(
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                       ),
//                       child: _isLoading
//                           ? const SizedBox(
//                               width: 24,
//                               height: 24,
//                               child: CircularProgressIndicator(
//                                 strokeWidth: 2.5,
//                                 color: Colors.white,
//                               ),
//                             )
//                           : const Text(
//                               'Login',
//                               style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//                             ),
//                     ),
//                   ),

//                   const SizedBox(height: 24),

//                   // Demo credentials hint
//                   // Container(
//                   //   padding: const EdgeInsets.all(12),
//                   //   decoration: BoxDecoration(
//                   //     color: Colors.grey.shade100,
//                   //     borderRadius: BorderRadius.circular(10),
//                   //   ),
//                   //   child: const Column(
//                   //     children: [
//                   //       Text(
//                   //         'Demo accounts',
//                   //         style: TextStyle(fontWeight: FontWeight.w600),
//                   //       ),
//                   //       SizedBox(height: 6),
//                   //       Text('Cashier → username: cashier  /  password: 1234'),
//                   //       Text('Manager → username: manager  /  password: admin'),
//                   //     ],
//                   //   ),
//                   // ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  //private variable called global key for the form state, and two text editing controllers for the email and password fields. These controllers will be used to retrieve the input values from the text fields.
  //formstate is the class that contorls the flutter form
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // 
  bool _isLoading = false;
  //
  bool _obscurePassword = true;
  //
  String? _errorMessage;

  @override
  // this is done to keep the memory light
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }


  Future<void> _login() async {
    //if everything is alright then return 
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      // 
      _isLoading = true;
      // no error message
      _errorMessage = null;
    });

    //we get the AuthProvider instance from the widget tree so 
    //we can call its login method 
    // final means it cannot be reassigned to another value. 
    //It is a compile-time constant.
    final auth = context.read<AuthProvider>();

    // if nothing returns then the login is successful, 
    //if it returns a string then the login has failed.
    final error = await auth.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    // this is a property of State it is true when the widget 
    //is stall active in the 
    // widget tree.
    if (!mounted) return;

    //In Flutter, a State class holds the data and behavior that can 
    //change while a screen is open.
    //Your login screen’s State class, _LoginScreenState, 
    //manages things like the text fields, 
    //loading status, and login error message. 
    //Flutter calls its build() method to draw the screen, 
    //and setState() tells Flutter to redraw it when that data changes.

    //The State class also provides mounted, 
    //which checks whether the screen is still active 
    //after an asynchronous operation, such as a login request.

    //It changes _isLoading to false and tells Flutter to redraw the screen. 
    //This stops the loading indicator after the login request finishes.
    setState(() => _isLoading = false);

    // if the error is null then the login was successful and 
    //we navigate to the home screen,
    if (error == null) {
      // Login success
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      // Login failed, show error message
      setState(() {
        _errorMessage = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo / Title
                  Icon(
                    Icons.dashboard_customize_rounded,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'VATIVA POS System',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to continue',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 40),

                  // Email
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter email';
                      }
                      if (!value.contains('@')) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _login(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),

                  // Error message
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ],

                  const SizedBox(height: 28),

                  // Login button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Hint
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Column(
                      children: [
                        Text(
                          'Demo accounts (create in Firebase)',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: 6),
                        
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}