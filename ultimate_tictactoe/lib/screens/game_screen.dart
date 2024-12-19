import 'package:flutter/material.dart';
import '../widgets/game_board.dart';
import '../models/game_state.dart';

class GameScreen extends StatefulWidget {
  final bool isBot;

  const GameScreen({super.key, required this.isBot});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameState gameState;

  @override
  void initState() {
    super.initState();
    gameState = GameState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isBot ? 'vs Bot' : 'vs Human'),
        backgroundColor: Colors.blue[900],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Player ${gameState.currentPlayer}\'s Turn',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: GameBoard(
              gameState: gameState,
              onMove: _handleMove,
            ),
          ),
        ],
      ),
    );
  }

  void _handleMove(int boardIndex, int cellIndex) {
    setState(() {
      if (gameState.isValidMove(boardIndex, cellIndex)) {
        gameState.makeMove(boardIndex, cellIndex);
        
        if (widget.isBot && !gameState.isGameOver) {
          // Add delay for bot move
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              setState(() {
                final botMove = gameState.generateBotMove();
                if (botMove != null) {
                  gameState.makeMove(botMove.boardIndex, botMove.cellIndex);
                }
              });
            }
          });
        }
      }
    });

    if (gameState.isGameOver) {
      _showGameOverDialog();
    }
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Game Over!'),
        content: Text(
          gameState.winner != null
              ? 'Player ${gameState.winner} wins!'
              : 'It\'s a tie!',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('New Game'),
          ),
        ],
      ),
    );
  }
}
