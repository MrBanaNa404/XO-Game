import 'package:flutter/material.dart';

class ReplayPage extends StatefulWidget {
  final List moves;

  const ReplayPage({super.key, required this.moves});

  @override
  State<ReplayPage> createState() => _ReplayPageState();
}

class _ReplayPageState extends State<ReplayPage> {
  List<String?> board = List.filled(9, null);
  int currentStep = 0;

  void playNextMove() {
    if (currentStep < widget.moves.length) {
      final move = widget.moves[currentStep];
      final parts = move.split(":");
      setState(() {
        board[int.parse(parts[1])] = parts[0];
        currentStep++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Replay")),
      body: Column(
        children: [
          GridView.builder(
            shrinkWrap: true,
            itemCount: 9,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
            itemBuilder: (context, i) {
              return Card(
                color: Colors.blue[100],
                child: Center(
                  child: Text(
                    board[i] ?? '',
                    style: const TextStyle(fontSize: 40),
                  ),
                ),
              );
            },
          ),
          ElevatedButton(
            onPressed: playNextMove,
            child: const Text("Next Move"),
          )
        ],
      ),
    );
  }
}
