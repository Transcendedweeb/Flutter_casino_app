import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Slots extends StatefulWidget {
  const Slots({super.key});

  @override
  State<Slots> createState() => _SlotsState();
}

class _SlotsState extends State<Slots> {
  final List<String> symbols = ['A', 'B', 'C', '1', '2', '3'];

  List<List<String>> reels = [
    ['A', 'B', 'C', '1', '2', '3'],
    ['A', 'B', 'C', '1', '2', '3'],
    ['A', 'B', 'C', '1', '2', '3'],
  ];

  List<List<int>> selectedIndexes = [
    [0, 0, 0],
    [0, 0, 0],
    [0, 0, 0],
  ];

  double accountBalance = 0.0;
  int betAmount = 10;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAccountBalance();
  }

  Future<void> _fetchAccountBalance() async {
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
                  accountBalance = account['balance'].toDouble();
                  _isLoading = false;
                });
              }
            });
          } else {
            setState(() {
              _isLoading = false;
            });
            _showErrorDialog('No account found for $username.');
          }
        } else {
          setState(() {
            _isLoading = false;
          });
          _showErrorDialog(
              'Failed to fetch accounts (${response.statusCode}).');
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        _showErrorDialog('An error occurred: $e');
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('No account logged in.');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
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

  Future<void> _updateAccountBalance(double newBalance) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('current_username');

    if (username != null) {
      final url = Uri.parse(
          'https://casinoapp-fb7bb-default-rtdb.europe-west1.firebasedatabase.app/accounts.json');

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic>? accounts = json.decode(response.body);

        if (accounts != null) {
          accounts.forEach((key, account) {
            if (account['username'] == username) {
              final updateUrl = Uri.parse(
                  'https://casinoapp-fb7bb-default-rtdb.europe-west1.firebasedatabase.app/accounts/$key.json');

              http
                  .patch(updateUrl, body: json.encode({'balance': newBalance}))
                  .then((updateResponse) {
                if (updateResponse.statusCode == 200) {
                  setState(() {
                    accountBalance = newBalance;
                  });
                } else {
                  _showErrorDialog('Failed to update balance.');
                }
              });
            }
          });
        }
      }
    }
  }

  void spinReels() {
    if (accountBalance < betAmount) {
      _showErrorDialog('Not enough funds to spin.');
      return;
    }

    setState(() {
      selectedIndexes[0][0] = Random().nextInt(reels[0].length);
      selectedIndexes[0][1] = Random().nextInt(reels[0].length);
      selectedIndexes[0][2] = Random().nextInt(reels[0].length);

      selectedIndexes[1][0] = Random().nextInt(reels[1].length);
      selectedIndexes[1][1] = Random().nextInt(reels[1].length);
      selectedIndexes[1][2] = Random().nextInt(reels[1].length);

      selectedIndexes[2][0] = Random().nextInt(reels[2].length);
      selectedIndexes[2][1] = Random().nextInt(reels[2].length);
      selectedIndexes[2][2] = Random().nextInt(reels[2].length);

      if (selectedIndexes[0][0] == selectedIndexes[0][1] &&
              selectedIndexes[0][1] == selectedIndexes[0][2] ||
          selectedIndexes[1][0] == selectedIndexes[1][1] &&
              selectedIndexes[1][1] == selectedIndexes[1][2] ||
          selectedIndexes[2][0] == selectedIndexes[2][1] &&
              selectedIndexes[2][1] == selectedIndexes[2][2]) {
        accountBalance += betAmount * 20;
        showSnackBar('You won! +€${betAmount * 20}');
      } else {
        accountBalance -= betAmount;
        showSnackBar('You lost! -€$betAmount');
      }

      _updateAccountBalance(accountBalance);
    });
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Slot Machine'), centerTitle: true),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Container(
                constraints: const BoxConstraints(maxWidth: 600),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Account Balance: € $accountBalance',
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: accountBalance < betAmount ? null : spinReels,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.orange,
                      ),
                      child: const Text('Spin'),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          for (int horReels = 0; horReels < 3; horReels++)
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  for (int vertReels = 0;
                                      vertReels < 3;
                                      vertReels++)
                                    Flexible(
                                      child: SlotReel(
                                        symbols: reels[horReels],
                                        selectedIndex: selectedIndexes[horReels]
                                            [vertReels],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class SlotReel extends StatelessWidget {
  final List<String> symbols;
  final int selectedIndex;

  const SlotReel({
    super.key,
    required this.symbols,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(width: 1, color: Colors.black),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Center(
        child: Text(
          symbols[selectedIndex],
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
