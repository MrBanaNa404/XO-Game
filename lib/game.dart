import 'package:demo_1/main.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'game_database.dart';
import 'history.dart';

class Game extends StatelessWidget {
  const Game({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: XOGame(),
    );
  }
}

class XOGame extends StatefulWidget {
  const XOGame({super.key});

  @override
  XOBoard createState() => XOBoard();
}

class XOBoard extends State<XOGame> {
  List<String> board = List.filled(9, "");
  bool PlayerTurn = true;
  String winner = "";
  List<String> moveHistory = [];

  void TouchTap(int index) {
    if (board[index] == "" && winner == "" && PlayerTurn) {
      setState(() {
        board[index] = "X";
        moveHistory.add("X:$index");
        PlayerTurn = false;
        winner = checkWinner();
      });

      if (winner == "") {
        Future.delayed(const Duration(milliseconds: 500), () {
          aiMove();
        });
      } else {
        saveHistoryIfEnd();
      }
    }
  }

  void aiMove() {
    int bestMove = BestMove();
    if (bestMove != -1) {
      setState(() {
        board[bestMove] = "O";
        moveHistory.add("O:$bestMove");
        PlayerTurn = true;
        winner = checkWinner();
      });

      if (winner != "") {
        saveHistoryIfEnd();
      }
    }
  }

  int BestMove() {
    int bestScore = -1000;
    int bestMove = -1;
    for (int i = 0; i < 9; i++) {
      if (board[i] == "") {
        board[i] = "O";
        int score = minimax(board, 0, false);
        board[i] = "";
        if (score > bestScore) {
          bestScore = score;
          bestMove = i;
        }
      }
    }
    return bestMove;
  }

  int minimax(List<String> board, int depth, bool Max) {
    String result = checkWinner();
    if (result == "X") return -10 + depth;
    if (result == "O") return 10 - depth;
    if (!board.contains("")) return 0;

    if (Max) {
      int bestScore = -1000;
      for (int i = 0; i < 9; i++) {
        if (board[i] == "") {
          board[i] = "O";
          int score = minimax(board, depth + 1, false);
          board[i] = "";
          bestScore = max(score, bestScore);
        }
      }
      return bestScore;
    } else {
      int bestScore = 1000;
      for (int i = 0; i < 9; i++) {
        if (board[i] == "") {
          board[i] = "X";
          int score = minimax(board, depth + 1, true);
          board[i] = "";
          bestScore = min(score, bestScore);
        }
      }
      return bestScore;
    }
  }

  String checkWinner() {
    List<List<int>> winpatterns = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6]
    ];
    for (var pattern in winpatterns) {
      String  a = board[pattern[0]],
              b = board[pattern[1]],
              c = board[pattern[2]];
      if (a != "" && a == b && b == c) return a;
    }
    return board.contains("") ? "" : "Draw";
  }

  void restartgame() {
    setState(() {
      board = List.filled(9, "");
      PlayerTurn = true;
      winner = "";
      moveHistory.clear();
    });
  }

  void saveHistoryIfEnd() async {
    if (winner != "") {
      await GameDatabase.instance.insertGame(
        moves: moveHistory,
        winner: winner,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
           Builder(
            builder: (context) {
              String message;
              if (winner == "") {
                if (PlayerTurn) {
                  message = "Your Turn (X)";
                } else {
                  message = "AI's Turn (O)";
                }
              } else if (winner == "Draw") {
                message = "Draw!";
              } else {
                message = "Winner: $winner!";
              }
              return Text(message, 
              style: const TextStyle(fontSize: 50, fontWeight: FontWeight.bold, color: Colors.white)
              );
            },
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3),
            itemCount: 9,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => TouchTap(index),
                child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.blue[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      board[index],
                      style: const TextStyle(
                          fontSize: 40, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton(
              onPressed: restartgame,
              child: const Text("Restart", style: TextStyle(fontSize: 24))),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const History()));
            },
            child: const Text("History", style: TextStyle(fontSize: 24)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MyApp(),
                ),
              );
            },
            child: const Text("Home", style: TextStyle(fontSize: 24)),
          ),
        ],
      ),
    );
  }
}
