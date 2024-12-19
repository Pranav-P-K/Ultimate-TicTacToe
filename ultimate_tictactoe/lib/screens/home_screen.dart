import 'package:flutter/material.dart';
import 'game_screen.dart';
import 'rules_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[700]!, Colors.blue[900]!],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Text(
                'Super Tic Tac Toe',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Image.asset(
                'assets/game_illustration.png',
                height: 200,
              ),
              Column(
                children: [
                  _buildButton(
                    context,
                    'Human vs Bot',
                    () => _navigateToGame(context, true),
                  ),
                  const SizedBox(height: 20),
                  _buildButton(
                    context,
                    'Human vs Human',
                    () => _navigateToGame(context, false),
                  ),
                  const SizedBox(height: 20),
                  _buildButton(
                    context,
                    'Game Rules',
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RulesScreen()),
                    ),
                    isOutlined: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(
    BuildContext context,
    String text,
    VoidCallback onPressed, {
    bool isOutlined = false,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 250,
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          primary: isOutlined ? Colors.transparent : Colors.white,
          onPrimary: isOutlined ? Colors.white : Colors.blue[900],
          side: isOutlined ? const BorderSide(color: Colors.white, width: 2) : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _navigateToGame(BuildContext context, bool isBot) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GameScreen(isBot: isBot),
      ),
    );
  }
}