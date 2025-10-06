import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Instance of Firebase Auth
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Text editing controllers to manage input fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // State variables
  bool _isRegistering = false; // Toggles between Login and Register mode
  bool _isLoading = false;    // Shows a loading indicator on buttons
  String? _errorMessage;      // Displays any errors from Firebase

  // --- Authentication Logic ---
  Future<void> _handleAuth() async {
    // Show loading indicator
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_isRegistering) {
        // Create a new user
        await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        // Sign in an existing user
        await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      }
      // onAuthStateChanged in AuthGate will handle navigation
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase errors
      setState(() {
        _errorMessage = e.message;
      });
    } catch (e) {
      // Handle other errors
      setState(() {
        _errorMessage = "An unexpected error occurred.";
      });
    } finally {
      // Hide loading indicator
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- Header ---
                Icon(
                  Feather.activity,
                  size: 50,
                  color: Colors.teal.shade700,
                ),
                const SizedBox(height: 20),
                Text(
                  _isRegistering ? 'Register Worker' : 'Worker Login',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade900,
                  ),
                ),
                Text(
                  'Smart Health Surveillance System',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 30),

                // --- Error Message Display ---
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),

                // --- Email Input Field ---
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Worker Email',
                    prefixIcon: Icon(Feather.user),
                  ),
                ),
                const SizedBox(height: 16),

                // --- Password Input Field ---
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Feather.lock),
                  ),
                ),
                const SizedBox(height: 24),

                // --- Auth Button ---
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleAuth,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(_isRegistering ? 'Register' : 'Login'),
                ),
                const SizedBox(height: 16),

                // --- Toggle Button ---
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isRegistering = !_isRegistering;
                      _errorMessage = null; // Clear errors on toggle
                    });
                  },
                  child: Text(
                    _isRegistering
                        ? 'Already have an account? Login'
                        : "Don't have an account? Register",
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

