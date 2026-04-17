import 'dart:math';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:jump_p/player.dart';

import 'platform.dart';
import 'platform_type.dart';

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

  // ================= RESET =================
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

    final startPlatform = Platform.normal(
  position: Vector2(
    size.x / 2 - 40,
    size.y - 40, // 👈 화면 거의 바닥에 붙여줌
  ),
);

    platforms.add(startPlatform);
    add(startPlatform);

    for (int i = 0; i < 9; i++) {
      final p = _createPlatform(
        rand.nextDouble() * (size.x - 80),
        size.y - i * 120,
      );

      platforms.add(p);
      add(p);
    }
  }

  // ================= FACTORY =================
  Platform _createPlatform(double x, double y) {
    final r = rand.nextDouble();

    if (r < 0.7) {
      return Platform.normal(position: Vector2(x, y));
    } else if (r < 0.85) {
      return Platform.jumpBoost(position: Vector2(x, y));
    } else {
      return Platform.breakable(position: Vector2(x, y));
    }
  }

  // ================= UPDATE =================
  @override
  void update(double dt) {
    super.update(dt);

    if (gameOver.value) return;

    velocity.y += gravity * dt;
    player.position += velocity * dt;

    player.position.x += direction * 250 * dt;

    if (player.position.x < 0) player.position.x = size.x;
    if (player.position.x > size.x) player.position.x = 0;

    // scroll
    if (player.position.y < size.y * 0.4) {
      final diff = (size.y * 0.4) - player.position.y;

      player.position.y = size.y * 0.4;

      scrollY += diff;
      score.value = scrollY.toInt();

      for (final p in platforms) {
        p.position.y += diff;
      }
    }

    // 충돌
    for (final p in platforms) {
      if (player.toRect().overlaps(p.toRect()) && velocity.y > 0) {
        switch (p.type) {
          case PlatformType.normal:
            velocity.y = jumpPower;
            break;

          case PlatformType.jumpBoost:
            velocity.y = jumpPower * 1.5;
            break;

          case PlatformType.breakable:
            velocity.y = jumpPower;
            p.removeFromParent();
            break;
        }

        break; // 한 번만 충돌
      }
    }

    // 재사용
    for (final p in platforms) {
      if (!p.isMounted) continue;

      if (p.position.y > size.y) {
        p.position.y = -50;
        p.position.x = rand.nextDouble() * (size.x - 80);
      }
    }

    // 게임오버
    if (player.position.y > size.y + 200) {
      gameOver.value = true;
      pauseEngine();
    }

    platforms.removeWhere((p) => p.isRemoved);
  }

  // ================= INPUT =================
  @override
  void onTapDown(TapDownInfo info) {
    direction = info.eventPosition.global.x < size.x / 2 ? -1 : 1;
  }

  @override
  void onTapUp(TapUpInfo info) {
    direction = 0;
  }

  // ================= RESET =================
  void resetGame() {
    resumeEngine();
    _reset();
  }
}