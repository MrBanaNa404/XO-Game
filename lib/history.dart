import 'package:flutter/material.dart';
import 'dart:convert';
import 'game_database.dart';
import 'replay_page.dart';

class GameHistoryPage extends StatefulWidget {
  const GameHistoryPage({super.key});

  @override
  State<GameHistoryPage> createState() => _GameHistoryPageState();
}

class _GameHistoryPageState extends State<GameHistoryPage> {
  List<Map<String, dynamic>> games = [];

  @override
  void initState() {
    super.initState();
    loadGames();
  }

  void loadGames() async {
    games = await GameDatabase.instance.getGames();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Game History")),
      body: ListView.builder(
        itemCount: games.length,
        itemBuilder: (context, index) {
          final game = games[index];
          final moves = jsonDecode(game['moves']);
          return ListTile(
            title: Text("Winner: ${game['winner']}"),
            subtitle: Text("Moves: ${moves.join(', ')}"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ReplayPage(moves: moves),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
