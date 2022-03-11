import "dart:ui";

import "package:vector_math/vector_math_64.dart";

import "direction.dart";

/// The blocks that composite the snake
class SnakeUnit {
  /// The position on the game map
  Vector2 position;
  /// Direction of this snake unit
  Direction direction;
  /// Color of this block
  Color color;

  /// Construct by given x and y.
  /// Direction is optional, default is Direction.north.
  SnakeUnit({Vector2? position, this.direction = Direction.north, this.color = const Color(0xFFAAAAAA)})
  :position = position != null ? position.clone() : Vector2(0, 0);

  /// Forward the snake unit by the direction
  void forward() {
    switch(direction) {
      case Direction.north: {
        --position.y;

        break;
      }

      case Direction.east: {
        ++position.x;

        break;
      }

      case Direction.south: {
        ++position.y;

        break;
      }

      case Direction.west: {
        --position.x;

        break;
      }
    }
  }
}
