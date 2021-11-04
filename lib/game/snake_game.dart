import 'dart:ui';
import 'dart:math';

import 'game_map.dart';
import 'snake.dart';
import 'food.dart';
import 'direction.dart';

// The class to store snake game information
class SnakeGame {
  /****************************************************************************************************
   * Setting
   ****************************************************************************************************/


  /****************************************************************************************************
   * Variable
   ****************************************************************************************************/
  // The snake game render area size
  Size? _renderAreaSize;
  // Store map information
  GameMap gameMap = GameMap(0,0); //debug
  // Store snake body information
  Snake snake = Snake(0,0); //debug!!
  // Store food information
  Food food = Food(0,0); //debug!!
  // Random number generater
  Random random = Random();

  /****************************************************************************************************
   * Construct by the given map size.
   ****************************************************************************************************/
  SnakeGame(int x, int y) {
    gameMap = GameMap(x, y);
    snake = Snake((x/2).floor() ,(y/2).floor());
    reset();
  }

  /****************************************************************************************************
   * Render the game on canvas.
   * Game render area size have to be set in this function,
   * need the size of render area to draw the game area correctly.
   ****************************************************************************************************/
  void renderOnCanvas(Canvas canvas, Size renderAreaSize) {
//     print("SnakeGame::renderOnCanvas()"); //debug

    // Set render area size
    _renderAreaSize = renderAreaSize;

    // Draw background on renderArea
    canvas.drawRect(
      Rect.fromLTWH(0, 0, _renderAreaSize!.width, _renderAreaSize!.height),
      Paint()
        ..color = Color(0xFF66FF99),
    );
  }

  /****************************************************************************************************
   * Load resource, food image or something else.
   ****************************************************************************************************/
  Future<void>? loadResource() {
//     food.loadPng('apple', 1);
  }

  /****************************************************************************************************
   * Set map size.
   ****************************************************************************************************/
  void setMapSize(int x, int y) {
    //wip: recount default snake head position
    gameMap.setSize(x, y);
  }

  /****************************************************************************************************
   * Reset the game
   ****************************************************************************************************/
  void reset() {
    snake.reset();
    snake.forwardAndGrow();
    snake.forwardAndGrow();
    createNewFruit();
  }

  /****************************************************************************************************
   * Forward the snake, return false if failed to forward.
   ****************************************************************************************************/
  void forwardSnake() {
    return snake.forward();
  }

  /****************************************************************************************************
   * Force move the snake to target point. (May cut the snake into two parts)
   ****************************************************************************************************/
  void moveSnakeTo(int x, int y) {
    return snake.moveTo(x, y);
  }

  /****************************************************************************************************
   * Turn snake head to given direction
   ****************************************************************************************************/
  void turnSnake(Direction direction) {
    return snake.turn(direction);
  }

  /****************************************************************************************************
   * Create a fruit on a new random point
   ****************************************************************************************************/
  bool createNewFruit() {
    if(snake.length >= gameMap.x * gameMap.y) {
      return false;
    }

    int x = 0;
    int y = 0;
    do {
      int x = random.nextInt(gameMap.x);
      int y = random.nextInt(gameMap.y);
    } while(snake.isPointOnBody(x, y));
    food = Food(x, y);

    return true;
  }

  /****************************************************************************************************
   * Convert percentage width (0.0 ~ 100.0) to real real width on the game render area.
   * Warning: _renderAreaSize need to be set before this function being invoked.
   ****************************************************************************************************/
  double _toAbsoluteWidth(double relativeWidth) {
    final _renderAreaSize = this._renderAreaSize;
    if(_renderAreaSize == null) {
      print("Error: _renderAreaSize need to be set before SnakeGame::_toAbsoluteWidth(double relativeWidth) being invoked.");
      return 0;
    }

    return _renderAreaSize.width * relativeWidth / 100.0;
  }

  /****************************************************************************************************
   * Convert percentage height (0.0 ~ 100.0) to real height on the game render area.
   * Warning: _renderAreaSize need to be set before this function being invoked.
   ****************************************************************************************************/
  double _toAbsoluteHeight(double relativeHeight) {
    final _renderAreaSize = this._renderAreaSize;
    if(_renderAreaSize == null) {
      print("Error: _renderAreaSize need to be set before SnakeGame::_toAbsoluteHeight(double relativeHeight) being invoked.");
      return 0;
    }

    return _renderAreaSize.height * relativeHeight / 100.0;
  }
}
