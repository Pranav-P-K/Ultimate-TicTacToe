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

// lib/models/game_state.dart
class GameState {
  List<List<String>> boards;
  List<String> mainBoard;
  String currentPlayer;
  int? nextBoard;
  String? winner;
  bool isGameOver;

  GameState()
      : boards = List.generate(9, (_) => List.filled(9, '')),
        mainBoard = List.filled(9, ''),
        currentPlayer = 'X',
        nextBoard = null,
        winner = null,
        isGameOver = false;

  bool isValidMove(int boardIndex, int cellIndex) {
    if (isGameOver) return false;
    if (nextBoard != null && boardIndex != nextBoard) return false;
    if (boards[boardIndex][cellIndex].isNotEmpty) return false;
    if (mainBoard[boardIndex].isNotEmpty) return false;
    return true;
  }

  void makeMove(int boardIndex, int cellIndex) {
    if (!isValidMove(boardIndex, cellIndex)) return;

    boards[boardIndex][cellIndex] = currentPlayer;
    checkSmallBoard(boardIndex);
    checkMainBoard();

    nextBoard = mainBoard[cellIndex].isEmpty ? cellIndex : null;
    currentPlayer = currentPlayer == 'X' ? 'O' : 'X';
  }

  void checkSmallBoard(int boardIndex) {
    final board = boards[boardIndex];
    final winPatterns = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // rows
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // columns
      [0, 4, 8], [2, 4, 6], // diagonals
    ];

    for (final pattern in winPatterns) {
      if (board[pattern[0]].isNotEmpty &&
          board[pattern[0]] == board[pattern[1]] &&
          board[pattern[1]] == board[pattern[2]]) {
        mainBoard[boardIndex] = board[pattern[0]];
        return;
      }
    }

    if (!board.contains('')) {
      mainBoard[boardIndex] = 'T'; // Tie
    }
  }

  void checkMainBoard() {
    final winPatterns = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // rows
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // columns
      [0, 4, 8], [2, 4, 6], // diagonals
    ];

    for (final pattern in winPatterns) {
      if (mainBoard[pattern[0]].isNotEmpty &&
          mainBoard[pattern[0]] != 'T' &&
          mainBoard[pattern[0]] == mainBoard[pattern[1]] &&
          mainBoard[pattern[1]] == mainBoard[pattern[2]]) {
        winner = mainBoard[pattern[0]];
        isGameOver = true;
        return;
      }
    }

    if (!mainBoard.contains('')) {
      isGameOver = true;
    }
  }

  BotMove? generateBotMove() {
    // Simple bot implementation - can be improved with minimax algorithm
    if (nextBoard != null) {
      for (int i = 0; i < 9; i++) {
        if (boards[nextBoard!][i].isEmpty) {
          return BotMove(nextBoard!, i);
        }
      }
    } else {
      for (int b = 0; b < 9; b++) {
        if (mainBoard[b].isEmpty) {
          for (int i = 0; i < 9; i++) {
            if (boards[b][i].isEmpty) {
              return BotMove(b, i);
            }
          }
        }
      }
    }
    return null;
  }
}

class BotMove {
  final int boardIndex;
  final int cellIndex;

  BotMove(this.boardIndex, this.cellIndex);
}