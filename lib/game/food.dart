import 'dart:math';
import 'dart:ui';

import 'package:flame/flame.dart';

/// The food will decay by the time goes on
class Food {
  /// Image of the food
  static List<Image> images = [];
  /// The represented colors of foods
  static List<Color> colors = [
    const Color(0xFFFF7FED),
    const Color(0xFFFFB27F),
    const Color(0xFFFFD800),
    const Color(0xFF7FFF8E),
    const Color(0xFF7FFFFF),
  ];
  /// The image id of this food (0 ~ 4)
  int imageId;
  /// The x position on the map
  int x = 0;
  /// The y position on the map
  int y = 0;

  Image get image => images[imageId];

  /// Set position of the food
  Food(this.x, this.y, {required this.imageId});

  /// load the image of the food
  static void loadResource() async {
    for(int i = 0; i < 5; ++i) {
      images.add(await Flame.images.load('food/food$i.png'));
    }
  }

  static Color getRandomColor() {
    return colors[Random().nextInt(5)];
  }
}
