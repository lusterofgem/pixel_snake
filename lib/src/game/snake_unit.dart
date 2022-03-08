import 'dart:ui';

import 'direction.dart';

/// The blocks that composite the snake
class SnakeUnit {
  /// X coordinate on the map
  int x;
  /// Y coordinate on the map
  int y;
  /// Direction of this snake unit
  Direction direction;
  /// Color of this block
  Color color;

  /// Construct by given x and y.
  /// Direction is optional, default is Direction.north.
  SnakeUnit(this.x, this.y, {this.direction = Direction.north, this.color = const Color(0xFFAAAAAA)});

  /// Forward the snake unit by the direction
  void forward() {
    switch(direction) {
      case Direction.north: {
        --y;

        break;
      }

      case Direction.east: {
        ++x;

        break;
      }

      case Direction.south: {
        ++y;

        break;
      }

      case Direction.west: {
        --x;

        break;
      }
    }
  }
}
