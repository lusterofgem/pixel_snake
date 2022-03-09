import 'dart:math';
import 'dart:ui';

import 'package:flame/flame.dart';
import 'package:vector_math/vector_math_64.dart';

/// The color ball on the start screen
class Colorball {
  /// Image of the colorball
  static List<Image> images = [];
  // The image id of the colorball
  int imageId = Random().nextInt(5);

  late Vector2 position;
  late Vector2 velocity;
  Vector2 size = Vector2(5, 5);

  Colorball({required this.position, required this.velocity});

  /// load the image of the colorball
  static void loadResource() async {
    for(int i = 0; i < 5; ++i) {
      images.add(await Flame.images.load('colorball/colorball$i.png'));
    }
  }
}
