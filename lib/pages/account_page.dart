// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:casinoapp/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  String _accountName = '';
  String _email = '';
  double _balance = 0.0;
  bool _isLoading = true;
  final TextEditingController _depositController = TextEditingController();
  final TextEditingController _withdrawalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchAccountDetails();
  }

  Future<void> _fetchAccountDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('current_username');

    if (username != null) {
      final url = Uri.parse(
          'https://casinoapp-fb7bb-default-rtdb.europe-west1.firebasedatabase.app/accounts.json');

      try {
        final response = await http.get(url);
        if (response.statusCode == 200) {
          final Map<String, dynamic>? accounts = json.decode(response.body);

          if (accounts != null) {
            accounts.forEach((key, account) {
              if (account['username'] == username) {
                setState(() {
                  _accountName = account['username'];
                  _email = account['email'];
                  _balance = account['balance'].toDouble();
                  _isLoading = false;
                });
              }
            });
          } else {
            setState(() {
              _isLoading = false;
            });
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Error'),
                  content: Text('No account found for $username.'),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('OK'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          }
        } else {
          setState(() {
            _isLoading = false;
          });
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Error'),
                content:
                    Text('Failed to fetch accounts (${response.statusCode}).'),
                actions: <Widget>[
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: Text('An error occurred: $e'),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('No account logged in.'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _logOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_username');

    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const HomePage()));
  }

  String _formatAmount(String amountStr) {
    double? amount = double.tryParse(amountStr);
    if (amount == null) {
      return '';
    }
    return amount.toStringAsFixed(2);
  }

  bool _isValidAmount(String amountStr) {
    double? amount = double.tryParse(amountStr);
    return amount != null && amount >= 0;
  }

  Future<void> _depositMoney() async {
    String depositAmountStr = _depositController.text;

    if (depositAmountStr.isEmpty || !_isValidAmount(depositAmountStr)) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Please enter a valid amount.'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }

    double depositAmount = double.parse(_formatAmount(depositAmountStr));

    final url = Uri.parse(
        'https://casinoapp-fb7bb-default-rtdb.europe-west1.firebasedatabase.app/accounts.json');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final Map<String, dynamic>? accounts = json.decode(response.body);

      if (accounts != null) {
        accounts.forEach((key, account) {
          if (account['username'] == _accountName) {
            double updatedBalance =
                account['balance'].toDouble() + depositAmount;
            account['balance'] = updatedBalance;

            final updateUrl = Uri.parse(
                'https://casinoapp-fb7bb-default-rtdb.europe-west1.firebasedatabase.app/accounts/$key.json');

            http
                .patch(updateUrl,
                    body: json.encode({'balance': updatedBalance}))
                .then((updateResponse) {
              if (updateResponse.statusCode == 200) {
                setState(() {
                  _balance = updatedBalance;
                  _depositController.clear();
                });
              } else {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Error'),
                      content: const Text('Failed to update balance.'),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('OK'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              }
            });
          }
        });
      }
    }
  }

  Future<void> _withdrawMoney() async {
    String withdrawalAmountStr = _withdrawalController.text;

    if (withdrawalAmountStr.isEmpty || !_isValidAmount(withdrawalAmountStr)) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Please enter a valid amount.'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }

    double withdrawalAmount = double.parse(_formatAmount(withdrawalAmountStr));

    if (_balance - withdrawalAmount < 0) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Insufficient balance.'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }

    final url = Uri.parse(
        'https://casinoapp-fb7bb-default-rtdb.europe-west1.firebasedatabase.app/accounts.json');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final Map<String, dynamic>? accounts = json.decode(response.body);

      if (accounts != null) {
        accounts.forEach((key, account) {
          if (account['username'] == _accountName) {
            double updatedBalance =
                account['balance'].toDouble() - withdrawalAmount;
            account['balance'] = updatedBalance;

            final updateUrl = Uri.parse(
                'https://casinoapp-fb7bb-default-rtdb.europe-west1.firebasedatabase.app/accounts/$key.json');

            http
                .patch(updateUrl,
                    body: json.encode({'balance': updatedBalance}))
                .then((updateResponse) {
              if (updateResponse.statusCode == 200) {
                setState(() {
                  _balance = updatedBalance;
                  _withdrawalController.clear();
                });
              } else {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Error'),
                      content: const Text('Failed to update balance.'),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('OK'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              }
            });
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account page'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : Text(
                          'Welcome back, $_accountName',
                          style: const TextStyle(fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                ),
                Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('Username: $_accountName'),
                        const SizedBox(height: 10),
                        Text('Email: $_email'),
                        const SizedBox(height: 10),
                        Text('Balance: €$_balance'),
                      ],
                    ),
                  ),
                ),
                Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Wallet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _depositController,
                          decoration: const InputDecoration(
                            labelText: 'Deposit Amount',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.orange,
                          ),
                          onPressed: _depositMoney,
                          child: const Text('Deposit'),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _withdrawalController,
                          decoration: const InputDecoration(
                            labelText: 'Withdrawal Amount',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.orange,
                          ),
                          onPressed: _withdrawMoney,
                          child: const Text('Withdraw'),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.red,
                    ),
                    onPressed: _logOut,
                    child: const Text('Log Out'),
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
