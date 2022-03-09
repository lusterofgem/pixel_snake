import 'dart:math';
import 'dart:ui';

import 'package:flame/flame.dart';

/// The food will decay by the time goes on
class Food {
  /// Image of the food
  static List<Image> images = [];
  /// The image id of this food (0 ~ 4)
  int imageId = Random().nextInt(5);
  /// The x position on the map
  int x = 0;
  /// The y position on the map
  int y = 0;

  Image get image => images[imageId];

  /// Set position of the food
  Food(this.x, this.y);

  /// load the image of the food
  static void loadResource() async {
    for(int i = 0; i < 5; ++i) {
      images.add(await Flame.images.load('food/food$i.png'));
    }
  }
}
