
import 'package:flutter/material.dart';
import '../store.dart';
import 'register_screen.dart';
import 'customer_home_screen.dart';
import 'admin_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _hidePassword = true;
  bool _isLoggingIn = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (_isLoggingIn) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoggingIn = true;
    });

    final shop = Shop.instance;

    final success = shop.login(
      _emailController.text.trim().toLowerCase(),
      _passwordController.text,
    );

    if (!mounted) return;

    if (!success) {
      setState(() {
        _isLoggingIn = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Incorrect email or password'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Open the correct dashboard based on user role.
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => shop.admin
            ? const AdminDashboardScreen()
            : const CustomerHomeScreen(),
      ),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment:
                CrossAxisAlignment.stretch,
                children: [
                  // LOGIN ICON
                  const Icon(
                    Icons.lock_outline,
                    size: 75,
                    color: Colors.deepOrange,
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Welcome Back',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Login to AutoParts Connect',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // EMAIL ADDRESS
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                      hintText: 'Enter your email',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      final email = value?.trim() ?? '';

                      if (email.isEmpty) {
                        return 'Please enter your email';
                      }

                      if (!RegExp(
                        r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                      ).hasMatch(email)) {
                        return 'Enter a valid email address';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 18),

                  // PASSWORD
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _hidePassword,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _login(),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                      ),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        tooltip: _hidePassword
                            ? 'Show password'
                            : 'Hide password',
                        icon: Icon(
                          _hidePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _hidePassword = !_hidePassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 25),

                  // LOGIN BUTTON
                  SizedBox(
                    height: 52,
                    child: FilledButton.icon(
                      onPressed:
                      _isLoggingIn ? null : _login,
                      icon: const Icon(Icons.login),
                      label: Text(
                        _isLoggingIn
                            ? 'Logging in...'
                            : 'Login',
                        style: const TextStyle(
                          fontSize: 17,
                        ),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // CREATE CUSTOMER ACCOUNT
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                          const RegisterScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      "Don't have an account? Register",
                    ),
                  ),

                  const SizedBox(height: 25),



                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
