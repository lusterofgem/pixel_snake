import 'dart:ui';

import 'package:flame/flame.dart';

/// The food will decay by the time goes on
class Food {
  /// The x position on the map
  int x = 0;
  /// The y position on the map
  int y = 0;
  /// Image of the food, default is 'food.png'
  static Future<Image>? image;

  /// Set position of the food
  Food(this.x, this.y);

  /// load the image of the food
  static Future<void> loadResource(String path) {
    return Future<void>(() => {
      image = Flame.images.load(path)
    });
  }
}
