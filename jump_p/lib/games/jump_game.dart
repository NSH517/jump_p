import 'dart:math';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';

import '../player.dart';

// ================= PLATFORM =================
class Platform extends RectangleComponent {
  Platform()
      : super(
          size: Vector2(80, 15),
          paint: Paint()..color = const Color(0xFF8B4513),
        );
}

// ================= GAME =================
class JumpGame extends FlameGame with TapDetector {
  final Random rand = Random();

  late Player player;
  final List<Platform> platforms = [];

  Vector2 velocity = Vector2.zero();
  final double gravity = 900;
  final double jumpPower = -600;

  double scrollY = 0;
  int direction = 0;

  final ValueNotifier<bool> gameOver = ValueNotifier(false);
  final ValueNotifier<int> score = ValueNotifier(0);

  @override
  Color backgroundColor() => const Color(0xFFFFFFFF);

  @override
  Future<void> onLoad() async {
    _reset();
  }

  void _reset() {
    removeAll(children);
    platforms.clear();

    velocity = Vector2.zero();
    scrollY = 0;
    direction = 0;

    gameOver.value = false;
    score.value = 0;

    player = Player()
      ..position = Vector2(size.x / 2 - 20, size.y - 150);

    add(player);

    final startPlatform = Platform()
      ..position = Vector2(size.x / 2 - 40, size.y - 80);

    platforms.add(startPlatform);
    add(startPlatform);

    for (int i = 0; i < 9; i++) {
      final p = Platform()
        ..position = Vector2(
          rand.nextDouble() * (size.x - 80),
          size.y - i * 120,
        );

      platforms.add(p);
      add(p);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (gameOver.value) return;

    velocity.y += gravity * dt;
    player.position += velocity * dt;

    player.position.x += direction * 250 * dt;

    if (player.position.x < 0) player.position.x = size.x;
    if (player.position.x > size.x) player.position.x = 0;

    if (player.position.y < size.y * 0.4) {
      double diff = (size.y * 0.4) - player.position.y;

      player.position.y = size.y * 0.4;

      scrollY += diff;
      score.value = scrollY.toInt();

      for (final p in platforms) {
        p.position.y += diff;
      }
    }

    for (final p in platforms) {
      if (player.toRect().overlaps(p.toRect()) && velocity.y > 0) {
        velocity.y = jumpPower;
      }
    }

    for (final p in platforms) {
      if (p.position.y > size.y) {
        p.position.y = -50;
        p.position.x = rand.nextDouble() * (size.x - 80);
      }
    }

    if (player.position.y > size.y + 200) {
      gameOver.value = true;
      pauseEngine();
    }
  }

  @override
  void onTapDown(TapDownInfo info) {
    direction = info.eventPosition.global.x < size.x / 2 ? -1 : 1;
  }

  @override
  void onTapUp(TapUpInfo info) {
    direction = 0;
  }

  void resetGame() {
    resumeEngine();
    _reset();
  }
}

// ================= GAME PAGE UI =================
class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late final JumpGame game;

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

          ValueListenableBuilder<bool>(
            valueListenable: game.gameOver,
            builder: (context, over, _) {
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

                      const SizedBox(height: 10),

                      ValueListenableBuilder<int>(
                        valueListenable: game.score,
                        builder: (context, value, _) {
                          return Text(
                            "Score: $value",
                            style: const TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 20),

                      ElevatedButton(
                        onPressed: game.resetGame,
                        child: const Text("RESTART"),
                      ),

                      const SizedBox(height: 10),

                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "BACK",
                          style: TextStyle(color: Colors.white),
                        ),
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