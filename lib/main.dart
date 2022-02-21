import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'pixel_snake.dart';

/// entry point
void main() {
  runApp(
    GameWidget(
      game: PixelSnake(),
    ),
  );
}
