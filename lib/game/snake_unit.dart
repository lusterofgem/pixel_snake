import 'dart:ui';
import 'direction.dart';

// The blocks that composite the snake
class SnakeUnit {
  /****************************************************************************************************
   * Variable
   ****************************************************************************************************/
  // X coordinate on the map
  int x = 0;
  // Y coordinate on the map
  int y = 0;
  // Direction of this snake unit
  Direction direction = Direction.north;
  // Color of this block
  Color color = Color(0xFFAAAAAA);

  /****************************************************************************************************
   * Construct by given x and y.
   * Direction is optional, default is Direction.north.
   ****************************************************************************************************/
  SnakeUnit(int x, int y, {Direction direction=Direction.north, Color color = const Color(0xFFAAAAAA)}) {
    this.x = x;
    this.y = y;
    this.direction = direction;
    this.color = color;
  }

  /****************************************************************************************************
   * Forward the snake unit by the direction
   ****************************************************************************************************/
  void forward() {
    switch(direction) {
      case Direction.north: {
        y--;

        break;
      }

      case Direction.east: {
        x++;

        break;
      }

      case Direction.south: {
        y++;

        break;
      }

      case Direction.west: {
        x--;

        break;
      }
    }
  }
}
