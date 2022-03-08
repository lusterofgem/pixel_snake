import 'dart:ui';

import 'package:flame/flame.dart';
import 'package:flame/sprite.dart';

/// The food will decay by the time goes on
class Food {
  /// The x position on the map
  int x = 0;
  /// The y position on the map
  int y = 0;
  /// Image of the food, default is 'food.png'
  // static Future<Image>? image;
  static Image? image;
  // static Sprite? sprite;


  /// Set position of the food
  Food(this.x, this.y);

  /// load the image of the food
  static void loadResource(String path) async {
    // return Future<void>(() => {
    //   image = Flame.images.load(path)
    // });

    image = await Flame.images.load(path);

    // sprite = Sprite(await Flame.images.load(path));
  }
}
