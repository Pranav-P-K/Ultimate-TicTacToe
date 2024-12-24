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