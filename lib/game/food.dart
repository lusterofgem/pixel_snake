import "dart:math";
import "dart:ui";

import "package:flame/flame.dart";
import "package:vector_math/vector_math_64.dart";

/// The food will decay by the time goes on
class Food {
  /// Image of the food
  static List<Image> images = [];

  /// Image with white stroke
  static List<Image> imagesWithStroke = [];

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
  /// The position on the map
  Vector2 position;

  Image get image => images[imageId];

  /// Set position of the food
  Food({required this.position, required this.imageId});

  /// load the image of the food
  static void loadResource() async {
    for(int i = 0; i < 5; ++i) {
      images.add(await Flame.images.load("food/food$i.png"));
      imagesWithStroke.add(await Flame.images.load("food/foodWithStroke$i.png"));
    }
  }

  static Color getRandomColor() {
    return colors[Random().nextInt(5)];
  }
}
