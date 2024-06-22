// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:casinoapp/pages/home.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';
  bool _isLoading = false;

  void signUpHandler() async {
    String username = _usernameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'All fields are required.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final url = Uri.parse(
        'https://casinoapp-fb7bb-default-rtdb.europe-west1.firebasedatabase.app/accounts.json');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic>? accounts = json.decode(response.body);

        if (accounts != null) {
          bool accountExists = accounts.values.any((account) {
            return account['username'] == username || account['email'] == email;
          });

          if (accountExists) {
            setState(() {
              _errorMessage = 'Username or Email already in use.';
              _isLoading = false;
            });
            return;
          }
        }

        final newAccount = {
          'username': username,
          'email': email,
          'password': password,
          'balance': 0.0,
        };

        final createResponse = await http.post(
          url,
          body: json.encode(newAccount),
        );

        if (createResponse.statusCode == 200) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        } else {
          setState(() {
            _errorMessage = 'Failed to create account. Please try again.';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to fetch accounts. Please try again.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isTablet = constraints.maxWidth > 600;
          double formPadding = isTablet ? 30.0 : 20.0;
          double logoSize = isTablet ? 60.0 : 50.0;
          double inputFontSize = isTablet ? 18.0 : 14.0;
          double buttonHeight = isTablet ? 50.0 : 36.0;
          double cardWidth = isTablet ? 400.0 : double.infinity;

          return Stack(
            fit: StackFit.expand,
            children: [
              Positioned(
                bottom: 0,
                right: 0,
                child: Image.asset(
                  'assets/images/image_front.png',
                  fit: BoxFit.cover,
                  width: MediaQuery.of(context).size.width * 0.35,
                ),
              ),
              Center(
                child: SingleChildScrollView(
                  child: Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    margin: EdgeInsets.symmetric(horizontal: formPadding),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: cardWidth),
                      child: Padding(
                        padding: EdgeInsets.all(formPadding),
                        child: Stack(
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    Image.asset(
                                      'assets/images/logo_bernard.png',
                                      height: logoSize,
                                      width: logoSize,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                TextField(
                                  controller: _usernameController,
                                  decoration: InputDecoration(
                                    labelText: 'Username',
                                    hintText: 'Enter your username',
                                    border: const OutlineInputBorder(),
                                    labelStyle:
                                        TextStyle(fontSize: inputFontSize),
                                    hintStyle:
                                        TextStyle(fontSize: inputFontSize),
                                  ),
                                  style: TextStyle(fontSize: inputFontSize),
                                ),
                                const SizedBox(height: 20),
                                TextField(
                                  controller: _emailController,
                                  decoration: InputDecoration(
                                    labelText: 'Email Address',
                                    hintText: 'Enter your email address',
                                    border: const OutlineInputBorder(),
                                    labelStyle:
                                        TextStyle(fontSize: inputFontSize),
                                    hintStyle:
                                        TextStyle(fontSize: inputFontSize),
                                  ),
                                  style: TextStyle(fontSize: inputFontSize),
                                ),
                                const SizedBox(height: 20),
                                TextField(
                                  controller: _passwordController,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    hintText: 'Enter your password',
                                    border: const OutlineInputBorder(),
                                    labelStyle:
                                        TextStyle(fontSize: inputFontSize),
                                    hintStyle:
                                        TextStyle(fontSize: inputFontSize),
                                  ),
                                  style: TextStyle(fontSize: inputFontSize),
                                ),
                                const SizedBox(height: 20),
                                if (_errorMessage.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 20),
                                    child: Text(
                                      _errorMessage,
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                _isLoading
                                    ? const Center(
                                        child: CircularProgressIndicator())
                                    : ElevatedButton(
                                        onPressed: signUpHandler,
                                        style: ElevatedButton.styleFrom(
                                          minimumSize: Size(
                                              double.infinity, buttonHeight),
                                          foregroundColor: Colors.white,
                                          backgroundColor: Colors.orange,
                                        ),
                                        child: const Text('Sign Up'),
                                      ),
                              ],
                            ),
                            Positioned.fill(
                              child: Align(
                                alignment: Alignment.topCenter,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 10.0),
                                  child: Text(
                                    'Sign-up',
                                    style: Theme.of(context)
                                        .textTheme
                                        .displaySmall
                                        ?.copyWith(
                                          fontSize: isTablet ? 32.0 : 24.0,
                                        ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
