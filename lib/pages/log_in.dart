// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:casinoapp/pages/game_list.dart';

class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  _LogInState createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';
  bool _isLoading = false;

  Future<void> logInHandler() async {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
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
          bool validAccount = false;

          accounts.forEach((key, account) {
            if (account['username'] == username &&
                account['password'] == password) {
              validAccount = true;
            }
          });

          if (validAccount) {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString('current_username', username);

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const GameList()),
            );
          } else {
            setState(() {
              _errorMessage = 'Invalid username or password.';
              _isLoading = false;
            });
          }
        } else {
          setState(() {
            _errorMessage = 'No accounts found.';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to fetch accounts (${response.statusCode}).';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: $e';
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
          double buttonHeight = isTablet ? 50.0 : 36.0;
          double cardWidth =
              isTablet ? 400.0 : MediaQuery.of(context).size.width * 0.8;

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
                                  decoration: const InputDecoration(
                                    labelText: 'Username',
                                    hintText: 'Enter your username',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                TextField(
                                  controller: _passwordController,
                                  obscureText: true,
                                  decoration: const InputDecoration(
                                    labelText: 'Password',
                                    hintText: 'Enter your password',
                                    border: OutlineInputBorder(),
                                  ),
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
                                        onPressed: logInHandler,
                                        style: ElevatedButton.styleFrom(
                                          minimumSize: Size(
                                              double.infinity, buttonHeight),
                                          foregroundColor: Colors.white,
                                          backgroundColor: Colors.orange,
                                        ),
                                        child: const Text('Login'),
                                      ),
                              ],
                            ),
                            Positioned.fill(
                              child: Align(
                                alignment: Alignment.topCenter,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 10.0),
                                  child: Text(
                                    'Log-in',
                                    style: Theme.of(context)
                                        .textTheme
                                        .displaySmall,
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
