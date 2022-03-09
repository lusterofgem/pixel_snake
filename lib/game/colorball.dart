import 'dart:math';
import 'dart:ui';

import 'package:vector_math/vector_math_64.dart';

/// The color ball on the start screen
class Colorball {
  static Image? image;
  int imageId = Random().nextInt(5);
  late Vector2 position;
  late Vector2 velocity;
  Vector2 size = Vector2(2, 2);

  Colorball({required this.position, required this.velocity}) {

  }
}
