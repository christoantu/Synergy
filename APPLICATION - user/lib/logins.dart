import 'dart:convert';
import 'package:aidiet/register.dart';
import 'package:aidiet/userhome.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'forgot password.dart';
import 'ip.dart';

class Ftnesslogin extends StatefulWidget {
  @override
  _FtnessloginState createState() => _FtnessloginState();
}

class _FtnessloginState extends State<Ftnesslogin> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscureText = true; // Added for password visibility toggle
  final _formKey = GlobalKey<FormState>();

  void _login() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      senddata();
    }
  }

  void senddata() async {
    String username = _emailController.text;
    String password = _passwordController.text;

    SharedPreferences sh = await SharedPreferences.getInstance();
    String url = sh.getString('url').toString();
    final urls = Uri.parse(url + "/flutter_login");

    try {
      final response = await http.post(urls, body: {
        'username': username,
        'psw': password,
      });

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        String status = data['status'];
        if (status == 'ok') {
          Fluttertoast.showToast(msg: 'Welcome back!');
          String type = data['type'];
          String lid = data['lid'].toString();
          sh.setString("lid", lid);

          if (type == 'user') {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => DietHome()),
                    (route) => false // Prevents going back to login
            );
          }
        } else {
          Fluttertoast.showToast(msg: 'Invalid credentials');
        }
      } else {
        Fluttertoast.showToast(msg: 'Server Error: ${response.statusCode}');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Connection Failed");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyipsetPage(title: 'Server Configuration')));
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 60),
                    // Replaced image with a modern Deep Purple Icon
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.fitness_center_rounded,
                        size: 80,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Synergy Login',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign in to continue your fitness journey',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    const SizedBox(height: 48),

                    // Email Field
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email Address',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Enter email';
                        if (!value.contains('@')) return 'Enter valid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Password Field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscureText,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _obscureText = !_obscureText),
                        ),
                      ),
                      validator: (value) => (value == null || value.isEmpty) ? 'Enter password' : null,
                    ),

                    const SizedBox(height: 30),

                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          elevation: 0,
                        ),
                        onPressed: _isLoading ? null : _login,
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                          'Login',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
// Register Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('New to AiDiet?', style: TextStyle(color: Colors.grey[700])),
                        TextButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpForm()));
                          },
                          child: const Text(
                            'Create Account',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

// Forgot Password Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => ForgotPasswordScreen()));
                          },
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Register Link
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   children: [
                    //     Text('New to AiDiet?', style: TextStyle(color: Colors.grey[700])),
                    //     TextButton(
                    //       onPressed: () {
                    //         Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpForm()));
                    //       },
                    //       child: const Text(
                    //         'Create Account',
                    //         style: TextStyle(
                    //           fontWeight: FontWeight.bold,
                    //           color: Colors.deepPurple,
                    //         ),
                    //       ),
                    //     ),
                    //     Text('Forgot Password', style: TextStyle(color: Colors.grey[700])),
                    //     TextButton(
                    //       onPressed: () {
                    //         Navigator.push(context, MaterialPageRoute(builder: (context) => ForgotPasswordScreen()));
                    //       },
                    //       child: const Text(
                    //         'Forgot Password',
                    //         style: TextStyle(
                    //           fontWeight: FontWeight.bold,
                    //           color: Colors.deepPurple,
                    //         ),
                    //       ),
                    //     ),
                    //
                    //   ],
                    // ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}