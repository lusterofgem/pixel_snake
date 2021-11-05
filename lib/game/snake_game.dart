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
  // The relative size that the game area on the screen.
  Size gameAreaSize = Size(100, 90);

  // The offset of game area.
  Offset gameAreaOffset = Offset(0, 10);

  // The color of game area
  Color gameAreaColor = Color(0xFFC8FF64);

  /****************************************************************************************************
   * Variable
   ****************************************************************************************************/
  // The screen size of the game
  Size? _screenSize;
  // Store map information
  GameMap gameMap = GameMap(0,0);
  // Store snake body information
  Snake snake = Snake(0,0);
  // Store food information
  Food food = Food(0,0);
  // Random number generater
  Random random = Random();

  /****************************************************************************************************
   * Construct by the given map size.
   ****************************************************************************************************/
  SnakeGame(int x, int y) {
    gameMap = GameMap(x, y);
    snake = Snake((x/2).ceil() ,(y/2).ceil());
    reset();
  }

  /****************************************************************************************************
   * Render the game on canvas.
   * Game render area size have to be set in this function,
   * need the size of render area to draw the game area correctly.
   ****************************************************************************************************/
  void renderOnCanvas(Canvas canvas, Size screenSize) {
    // Set render area size
    _screenSize = screenSize;

    // Draw game area on canvas
    canvas.drawRect(
      Rect.fromLTWH(
        _toAbsoluteWidth(gameAreaOffset.dx),
        _toAbsoluteHeight(gameAreaOffset.dy),
        _toAbsoluteWidth(gameAreaSize.width),
        _toAbsoluteHeight(gameAreaSize.height),
      ),
      Paint()
        ..color = gameAreaColor,
    );

    final mapUnitSize = this.getMapUnitSize();
    for(final snakeUnit in snake.body) {
      canvas.drawRect(
        Rect.fromLTWH(
          snakeUnit.x * mapUnitSize.width + _toAbsoluteWidth(gameAreaOffset.dx),
          snakeUnit.y * mapUnitSize.height + _toAbsoluteHeight(gameAreaOffset.dy),
          mapUnitSize.width,
          mapUnitSize.height,
        ),
        Paint()
          ..color = snakeUnit.color,
      );
    }
  }

  /****************************************************************************************************
   * Load resource, food image or something else.
   ****************************************************************************************************/
  Future<void>? loadResource() {
//     food.loadPng('apple', 1);
  }

  /****************************************************************************************************
   * Get a single map unit absolute size.
   * Warning: _screenSize must be set before this function invoked.
   ****************************************************************************************************/
  Size getMapUnitSize() {
    final screenSize = _screenSize;
    if(screenSize == null) {
      print("Warning: _screenSize must be set before this SnakeGame::getMapUnitSize() invoked.");
      return Size(0, 0);
    }
    Size mapUnitSize = Size(_toAbsoluteWidth(gameAreaSize.width) / gameMap.x,
                            _toAbsoluteHeight(gameAreaSize.height) / gameMap.y);
    return mapUnitSize;
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
//     snake.forward(); //debug!!
//     snake.forward(); //debug!!
    snake.forwardAndGrow();
    snake.forwardAndGrow();
    snake.forwardAndGrow();
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
   * Convert percentage width (0.0 ~ 100.0) to real real width on the screen.
   * Warning: _screenSize need to be set before this function being invoked.
   ****************************************************************************************************/
  double _toAbsoluteWidth(double relativeWidth) {
    final screenSize = this._screenSize;
    if(screenSize == null) {
      print("Error: _screenSize need to be set before SnakeGame::_toAbsoluteWidth(double relativeWidth) being invoked.");
      return 0;
    }

    return screenSize.width * relativeWidth / 100.0;
  }

  /****************************************************************************************************
   * Convert percentage height (0.0 ~ 100.0) to real height on the screen.
   * Warning: _screenSize need to be set before this function being invoked.
   ****************************************************************************************************/
  double _toAbsoluteHeight(double relativeHeight) {
    final screenSize = this._screenSize;
    if(screenSize == null) {
      print("Error: _screenSize need to be set before SnakeGame::_toAbsoluteHeight(double relativeHeight) being invoked.");
      return 0;
    }

    return screenSize.height * relativeHeight / 100.0;
  }
}
