import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'platform_type.dart';

class Platform extends RectangleComponent {
  final PlatformType type;

  Platform._({
    required this.type,
    required Vector2 position,
    required Color color,
  }) : super(
          size: Vector2(80, 15),
          position: position,
          paint: Paint()..color = color,
        );

  // ================= NORMAL =================
  factory Platform.normal({
    required Vector2 position,
  }) {
    return Platform._(
      type: PlatformType.normal,
      position: position,
      color: const Color(0xFF8B4513),
    );
  }

  // ================= JUMP BOOST =================
  factory Platform.jumpBoost({
    required Vector2 position,
  }) {
    return Platform._(
      type: PlatformType.jumpBoost,
      position: position,
      color: Colors.blue,
    );
  }

  // ================= BREAKABLE =================
  factory Platform.breakable({
    required Vector2 position,
  }) {
    return Platform._(
      type: PlatformType.breakable,
      position: position,
      color: Colors.red,
    );
  }
}