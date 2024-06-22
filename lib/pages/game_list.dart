import 'package:casinoapp/pages/account_page.dart';
import 'package:casinoapp/pages/slots.dart';
import 'package:flutter/material.dart';

class GameList extends StatefulWidget {
  const GameList({super.key});

  @override
  State<GameList> createState() => _GameListState();
}

class _GameListState extends State<GameList> {
  final List<String> titles = [
    'Slots',
    'Blackjack',
    'Baccarat',
    'Video poker',
    'Roulette',
    'Pai gow',
    'Keno',
    'Craps',
    'Horse race',
    'Minesweeper',
  ];

  List<String> filteredTitles = [];

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredTitles = titles;
    searchController.addListener(_filterTitles);
  }

  void _filterTitles() {
    String query = searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredTitles = titles;
      } else {
        filteredTitles = titles
            .where((title) => title.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  void handleCardTap(int index) {
    if (index == 0) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const Slots()));
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset('assets/images/logo_bernard.png'),
        ),
        title: const Text('Speel nu', textAlign: TextAlign.center),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const AccountPage()));
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Search',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.search),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredTitles.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        handleCardTap(index);
                      },
                      child: Card(
                        color: const Color.fromARGB(255, 105, 105, 105),
                        margin: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 10,
                        ),
                        child: ListTile(
                          leading: Image.asset(
                            'assets/images/game_${filteredTitles[index]}.png',
                            width: 50,
                            height: 50,
                            fit: BoxFit.fill,
                          ),
                          title: Text(filteredTitles[index]),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
