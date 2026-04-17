import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:jump_p/games/jump_game.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  bool get debugMode => false;

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late final JumpGame game;

  final ButtonStyle gameButtonStyle = ElevatedButton.styleFrom(
    minimumSize: const Size(220, 50),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    textStyle: const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
  );

  @override
  void initState() {
    super.initState();
    game = JumpGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GameWidget(game: game),

          Positioned(
            top: 40,
            left: 20,
            child: ValueListenableBuilder<int>(
              valueListenable: game.score,
              builder: (_, value, __) {
                return Text(
                  'Score: $value',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ),

          ValueListenableBuilder<bool>(
            valueListenable: game.gameOver,
            builder: (_, over, __) {
              if (!over) return const SizedBox.shrink();

              return Container(
                color: Colors.black54,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "GAME OVER",
                        style: TextStyle(
                          fontSize: 40,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 20),

                      ValueListenableBuilder<int>(
                        valueListenable: game.score,
                        builder: (_, value, __) {
                          return Text(
                            "Score: $value",
                            style: const TextStyle(
                              fontSize: 28,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 30),

                      // RESTART
                      ElevatedButton(
                        onPressed: game.resetGame,
                        style: gameButtonStyle.copyWith(
                          backgroundColor:
                              WidgetStateProperty.all(Colors.greenAccent),
                          foregroundColor:
                              WidgetStateProperty.all(Colors.black),
                        ),
                        child: const Text("RESTART"),
                      ),

                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          game.resetGame();
                          Navigator.pop(context);
                        },
                        style: gameButtonStyle.copyWith(
                          backgroundColor:
                              WidgetStateProperty.all(Colors.white),
                          foregroundColor:
                              WidgetStateProperty.all(Colors.black),
                        ),
                        child: const Text("MAIN MENU"),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}