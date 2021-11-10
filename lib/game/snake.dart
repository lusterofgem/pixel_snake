import 'dart:ui';

import 'snake_unit.dart';
import 'direction.dart';

// The class to store snake information
class Snake {
  /****************************************************************************************************
   * Variable
   ****************************************************************************************************/
  // Default snake head spawn point and direction
//   SnakeUnit defaultSnakeHead = SnakeUnit(0,0);
  late SnakeUnit defaultSnakeHead;

  // Snake body, snake head is body[0]
  List<SnakeUnit> body = [];

  // Is the snake still alive
  bool alive = true;

  // The color of snake eye
  Color eyeColor = Color(0xFF000000);

  /****************************************************************************************************
   * Getter
   ****************************************************************************************************/
  int get length => body.length;

  /****************************************************************************************************
   * Construct by given x and y.
   * Direction is optional, default is Direction.north.
   ****************************************************************************************************/
  Snake(int x, int y, {Direction direction=Direction.north}) {
    defaultSnakeHead = SnakeUnit(x, y, direction: direction);
    reset();
  }

  /****************************************************************************************************
   * Reset the snake to default state.
   ****************************************************************************************************/
  void reset() {
    body = [];
    body.add(SnakeUnit(defaultSnakeHead.x, defaultSnakeHead.y, direction: defaultSnakeHead.direction));
    alive = true;
  }

  /****************************************************************************************************
   * Set the snake default spawn point
   ****************************************************************************************************/
  void setSpawnPoint(int x, int y, {Direction direction=Direction.north}) {
    defaultSnakeHead.x = x;
    defaultSnakeHead.y = y;
    defaultSnakeHead.direction = direction;
  }

  /****************************************************************************************************
   * Force move to target point. (May cut the snake into two parts)
   ****************************************************************************************************/
  void moveTo(int x, int y) {
    body[0].x = x;
    body[0].y = y;
    for(int i = 1; i < body.length; ++i) {
      body[i].forward();
      body[i].direction = body[i-1].direction;
    }
  }

  /****************************************************************************************************
   * Force move to target point and grow on the tail. (May cut the snake into two parts)
   ****************************************************************************************************/
  void moveToAndGrow(int x, int y) {
    SnakeUnit newTail = SnakeUnit(0, 0);
    newTail.x = body.last.x;
    newTail.y = body.last.y;
    newTail.direction = body.last.direction;

    moveTo(x, y);
    body.add(newTail);
  }

  /****************************************************************************************************
   * Forward the snake
   ****************************************************************************************************/
  void forward() {
//     body[0].forward();
//     for(int i = 1; i < body.length; ++i) {
//       body[i].forward();
//       body[i].direction = body[i-1].direction;
//     }
//     SnakeUnit temp = SnakeUnit(0, 0);
    for(int i = body.length - 1; i > 0; --i) {
      body[i].x = body[i-1].x;
      body[i].y = body[i-1].y;
      body[i].direction = body[i-1].direction;
    }
    body.first.forward();
  }

  /****************************************************************************************************
   * Forward the snake and grow
   ****************************************************************************************************/
  void forwardAndGrow() {
    SnakeUnit newTail = SnakeUnit(0, 0);
    newTail.x = body.last.x;
    newTail.y = body.last.y;
    newTail.direction = body.last.direction;

    forward();
    body.add(newTail);
  }

  /****************************************************************************************************
   * Turn snake head to given direction
   ****************************************************************************************************/
  void turn(Direction direction) {
    if(body.length > 1) {
      switch(direction) {
        case Direction.north: {
          if(body.first.y > body[1].y) {
            print("Failed to turn north"); //debug!!
            return;
          }
          break;
        }
        case Direction.east: {
          if(body.first.x < body[1].x) {
            print("Failed to turn east"); //debug!!
            return;
          }
          break;
        }
        case Direction.south: {
          if(body.first.y < body[1].y) {
            print("Failed to turn south"); //debug!!
            return;
          }
          break;
        }
        case Direction.west: {
          if(body.first.x > body[1].x) {
            print("Failed to turn west"); //debug!!
            return;
          }
          break;
        }
      }
    }
    final snakeHead = body.first;
    int targetPointX = snakeHead.x;
    int targetPointY = snakeHead.y;
    switch(snakeHead.direction) {
      case Direction.north: {
        --targetPointY;
        break;
      }
      case Direction.east: {
        ++targetPointX;
        break;
      }
      case Direction.south: {
        ++targetPointY;
        break;
      }
      case Direction.west: {
        --targetPointX;
        break;
      }
    }
    print("");
//     print(body.first.x);
//     print(body.first.y);
//     print(body[1].x);
//     print(body[1].y);
    print("snake.body.length = ${body.length}");
    body[0].direction = direction;
  }

  /****************************************************************************************************
   * If the snake is alive
   ****************************************************************************************************/
  bool isAlive() {
    return alive;
  }

  /****************************************************************************************************
   * Is the given point overlapped the snake body
   ****************************************************************************************************/
  bool isPointOnBody(int x, int y) {
    for(SnakeUnit snakeUnit in body) {
      if(snakeUnit.x == x && snakeUnit.y == y) {
        return true;
      }
    }

    return false;
  }

  /****************************************************************************************************
   * Get the snake faced x coord.
   ****************************************************************************************************/
  int getTargetPointX() {
    final snakeHead = body.first;
    int targetPointX = snakeHead.x;
    switch(snakeHead.direction) {
      case Direction.east: {
        ++targetPointX;
        break;
      }
      case Direction.west: {
        --targetPointX;
        break;
      }
    }

    return targetPointX;
  }

  /****************************************************************************************************
   * Get the snake faced y coord.
   ****************************************************************************************************/
  int getTargetPointY() {
    final snakeHead = body.first;
    int targetPointY = snakeHead.y;
    switch(snakeHead.direction) {
      case Direction.north: {
        --targetPointY;
        break;
      }
      case Direction.south: {
        ++targetPointY;
        break;
      }
    }

    return targetPointY;
  }
}
