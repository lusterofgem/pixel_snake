import 'dart:math';
import 'dart:ui';

import 'package:flame/flame.dart';

/// The food will decay by the time goes on
class Food {
  /// Image of the food, default is 'food.png'
  // static Image? image;
  static List<Image> images = [];
  /// The x position on the map
  int x = 0;
  /// The y position on the map
  int y = 0;
  /// The image id of this food (0 ~ 4)
  int foodType;

  Image get image => images[foodType];

  /// Set position of the food
  Food(this.x, this.y)
  :foodType = Random().nextInt(5);

  /// load the image of the food
  static void loadResource() async {
    for(int i = 0; i < 5; ++i) {
      images.add(await Flame.images.load('food/food$i.png'));
    }
  }
}
