import 'dart:ui';

import 'snake_unit.dart';
import 'direction.dart';

// The class to store snake information
class Snake {
  /****************************************************************************************************
   * Setting
   ****************************************************************************************************/
  // The color of snake left eye
  Color leftEyeColor = Color(0x00000000);

  // The color of snake right eye (If it is null, it will be the left eye color)
  Color? rightEyeColor;

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
    body.add(defaultSnakeHead);
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
    for(int i = 1; i < body.length; i++) {
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
    body[0].forward();
    for(int i = 1; i < body.length; i++) {
      body[i].forward();
      body[i].direction = body[i-1].direction;
    }
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

}
