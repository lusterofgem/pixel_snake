import 'dart:math';
import 'dart:ui';

class FoodColor {
  static List<Color> colors = [
    const Color(0xFFFF7FED),
    const Color(0xFFFFB27F),
    const Color(0xFFFFD800),
    const Color(0xFF7FFF8E),
    const Color(0xFF7FFFFF),
  ];

  static Color getRandomColor() {
    return colors[Random().nextInt(5)];
  }
}
