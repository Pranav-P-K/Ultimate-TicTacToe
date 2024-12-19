import 'package:flutter/material.dart';
import '../models/game_state.dart';

class GameBoard extends StatelessWidget {
  final GameState gameState;
  final Function(int, int) onMove;

  const GameBoard({
    super.key,
    required this.gameState,
    required this.onMove,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: 9,
          itemBuilder: (context, boardIndex) {
            return SmallBoard(
              board: gameState.boards[boardIndex],
              isPlayable: gameState.nextBoard == null || gameState.nextBoard == boardIndex,
              winner: gameState.mainBoard[boardIndex],
              onCellTap: (cellIndex) => onMove(boardIndex, cellIndex),
            );
          },
        ),
      ),
    );
  }
}

class SmallBoard extends StatelessWidget {
  final List<String> board;
  final bool isPlayable;
  final String winner;
  final Function(int) onCellTap;

  const SmallBoard({
    super.key,
    required this.board,
    required this.isPlayable,
    required this.winner,
    required this.onCellTap,
  });

  @override
  Widget build(BuildContext context) {
    if (winner.isNotEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 500),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Text(
                  winner,
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                  ),
                ),
              );
            },
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: isPlayable ? Colors.blue.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: isPlayable
            ? Border.all(color: Colors.blue, width: 2)
            : null,
      ),
      child: GridView.builder(
        padding: const EdgeInsets.all(4),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
        ),
        itemCount: 9,
        itemBuilder: (context, cellIndex) {
          return Cell(
            value: board[cellIndex],
            onTap: isPlayable ? () => onCellTap(cellIndex) : null,
          );
        },
      ),
    );
  }
}

class Cell extends StatelessWidget {
  final String value;
  final VoidCallback? onTap;

  const Cell({
    super.key,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
        child: value.isNotEmpty
            ? TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutBack,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: CustomPaint(
                      painter: XOPainter(
                        value: this.value,
                        progress: value,
                      ),
                    ),
                  );
                },
              )
            : null,
      ),
    );
  }
}

class XOPainter extends CustomPainter {
  final String value;
  final double progress;

  XOPainter({required this.value, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    if (value == 'X') {
      paint.color = Colors.blue[900]!;
      
      // Draw X
      final p1 = Offset(size.width * 0.2, size.height * 0.2);
      final p2 = Offset(size.width * 0.8, size.height * 0.8);
      final p3 = Offset(size.width * 0.8, size.height * 0.2);
      final p4 = Offset(size.width * 0.2, size.height * 0.8);

      if (progress <= 0.5) {
        // First line of X
        final scale = progress * 2;
        canvas.drawLine(p1, Offset.lerp(p1, p2, scale)!, paint);
      } else {
        // Both lines of X
        canvas.drawLine(p1, p2, paint);
        final scale = (progress - 0.5) * 2;
        canvas.drawLine(p3, Offset.lerp(p3, p4, scale)!, paint);
      }
    } else {
      paint.color = Colors.red[700]!;
      
      // Draw O
      final center = Offset(size.width / 2, size.height / 2);
      final radius = size.width * 0.3;
      
      final rect = Rect.fromCircle(center: center, radius: radius);
      canvas.drawArc(rect, 0, progress * 6.28, false, paint);
    }
  }

  @override
  bool shouldRepaint(XOPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}