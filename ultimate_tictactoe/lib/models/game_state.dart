class GameState {
  List<List<String>> boards; // 9 small boards
  List<String> mainBoard; // The main board tracking wins of small boards
  String currentPlayer;
  int? nextBoard; // The board where next player must play (-1 if can play anywhere)
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

    // If the next board is full or already won, player can play anywhere
    nextBoard = mainBoard[cellIndex].isEmpty ? cellIndex : null;
    currentPlayer = currentPlayer == 'X' ? 'O' : 'X';
  }

  void checkSmallBoard(int boardIndex) {
    final board = boards[boardIndex];
    final lines = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // rows
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // columns
      [0, 4, 8], [2, 4, 6] // diagonals
    ];

    for (final line in lines) {
      if (board[line[0]].isNotEmpty &&
          board[line[0]] == board[line[1]] &&
          board[line[1]] == board[line[2]]) {
        mainBoard[boardIndex] = board[line[0]];
        return;
      }
    }

    // Check for tie
    if (!board.contains('')) {
      mainBoard[boardIndex] = 'T';
    }
  }

  void checkMainBoard() {
    final lines = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // rows
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // columns
      [0, 4, 8], [2, 4, 6] // diagonals
    ];

    for (final line in lines) {
      if (mainBoard[line[0]].isNotEmpty &&
          mainBoard[line[0]] != 'T' &&
          mainBoard[line[0]] == mainBoard[line[1]] &&
          mainBoard[line[1]] == mainBoard[line[2]]) {
        winner = mainBoard[line[0]];
        isGameOver = true;
        return;
      }
    }

    // Check for main board tie
    if (!mainBoard.contains('') || !hasValidMoves()) {
      isGameOver = true;
    }
  }

  bool hasValidMoves() {
    if (nextBoard != null) {
      return boards[nextBoard!].contains('');
    }
    
    for (int i = 0; i < 9; i++) {
      if (mainBoard[i].isEmpty && boards[i].contains('')) {
        return true;
      }
    }
    return false;
  }

  // Improved Bot AI using Minimax algorithm
  BotMove? generateBotMove() {
    int bestScore = -1000;
    BotMove? bestMove;

    // If next board is specified, only check moves in that board
    if (nextBoard != null) {
      for (int i = 0; i < 9; i++) {
        if (boards[nextBoard!][i].isEmpty) {
          boards[nextBoard!][i] = 'O';
          int score = minimax(0, false);
          boards[nextBoard!][i] = '';
          
          if (score > bestScore) {
            bestScore = score;
            bestMove = BotMove(nextBoard!, i);
          }
        }
      }
    } else {
      // Check all possible moves in all available boards
      for (int b = 0; b < 9; b++) {
        if (mainBoard[b].isEmpty) {
          for (int i = 0; i < 9; i++) {
            if (boards[b][i].isEmpty) {
              boards[b][i] = 'O';
              int score = minimax(0, false);
              boards[b][i] = '';
              
              if (score > bestScore) {
                bestScore = score;
                bestMove = BotMove(b, i);
              }
            }
          }
        }
      }
    }

    return bestMove;
  }

  int minimax(int depth, bool isMaximizing) {
    // Check if game is over
    checkMainBoard();
    if (isGameOver) {
      if (winner == 'O') return 100 - depth;
      if (winner == 'X') return -100 + depth;
      return 0;
    }

    if (depth >= 4) return evaluatePosition(); // Limit depth for performance

    int bestScore = isMaximizing ? -1000 : 1000;
    String player = isMaximizing ? 'O' : 'X';

    // Generate possible moves
    List<BotMove> moves = [];
    if (nextBoard != null) {
      for (int i = 0; i < 9; i++) {
        if (boards[nextBoard!][i].isEmpty) {
          moves.add(BotMove(nextBoard!, i));
        }
      }
    } else {
      for (int b = 0; b < 9; b++) {
        if (mainBoard[b].isEmpty) {
          for (int i = 0; i < 9; i++) {
            if (boards[b][i].isEmpty) {
              moves.add(BotMove(b, i));
            }
          }
        }
      }
    }

    // Try each move
    for (var move in moves) {
      boards[move.boardIndex][move.cellIndex] = player;
      int score = minimax(depth + 1, !isMaximizing);
      boards[move.boardIndex][move.cellIndex] = '';

      if (isMaximizing) {
        bestScore = score > bestScore ? score : bestScore;
      } else {
        bestScore = score < bestScore ? score : bestScore;
      }
    }

    return bestScore;
  }

  int evaluatePosition() {
    int score = 0;
    final lines = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // rows
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // columns
      [0, 4, 8], [2, 4, 6] // diagonals
    ];

    // Evaluate main board
    for (final line in lines) {
      score += evaluateLine(
        mainBoard[line[0]], 
        mainBoard[line[1]], 
        mainBoard[line[2]]
      ) * 10;
    }

    // Evaluate each small board
    for (int b = 0; b < 9; b++) {
      if (mainBoard[b].isEmpty) {
        for (final line in lines) {
          score += evaluateLine(
            boards[b][line[0]], 
            boards[b][line[1]], 
            boards[b][line[2]]
          );
        }
      }
    }

    return score;
  }

  int evaluateLine(String a, String b, String c) {
    int countO = 0;
    int countX = 0;

    for (String mark in [a, b, c]) {
      if (mark == 'O') countO++;
      if (mark == 'X') countX++;
    }

    if (countO == 3) return 100;
    if (countX == 3) return -100;
    if (countO == 2 && countX == 0) return 10;
    if (countX == 2 && countO == 0) return -10;
    if (countO == 1 && countX == 0) return 1;
    if (countX == 1 && countO == 0) return -1;
    
    return 0;
  }
}

class BotMove {
  final int boardIndex;
  final int cellIndex;

  BotMove(this.boardIndex, this.cellIndex);
}