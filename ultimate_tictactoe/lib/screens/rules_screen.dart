import 'package:flutter/material.dart';

class RulesScreen extends StatelessWidget {
  const RulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Rules'),
        backgroundColor: Colors.blue[900],
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RuleSection(
              title: 'Game Structure',
              content: '• The game consists of 9 smaller Tic Tac Toe boards arranged in a 3x3 grid.',
            ),
            RuleSection(
              title: 'Objective',
              content: '• Win 3 smaller boards in a row (horizontally, vertically, or diagonally).',
            ),
            RuleSection(
              title: 'How to Play',
              content: '''
• Your move in a small board determines where your opponent must play next.
• If sent to a completed board, your opponent can play anywhere.
• Win small boards like regular Tic Tac Toe.
• Tied boards don't count for either player.''',
            ),
          ],
        ),
      ),
    );
  }
}

class RuleSection extends StatelessWidget {
  final String title;
  final String content;

  const RuleSection({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}