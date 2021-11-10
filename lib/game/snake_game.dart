import 'dart:ui';
import 'dart:math';

import 'package:flame/flame.dart';
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

  // Max food life, example: 5 means => 'watermelon0.png' ~ 'watermelon4.png'
  final maxFoodLife = 5;

  /****************************************************************************************************
   * Resource
   ****************************************************************************************************/
  Map<String, List<Image>> foodImages = Map();

  /****************************************************************************************************
   * Variable
   ****************************************************************************************************/
  // The screen size of the game
  Size? _screenSize;
  // Store map information
  GameMap gameMap = GameMap(0,0);
  // Store snake body information
  Snake snake = Snake(0,0);
  // Store current food information
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
   * Warning: Need to call loadResource before this function invoked.
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
    // Draw food on canvas
    canvas.drawRect(
      Rect.fromLTWH(
        food.x * mapUnitSize.width + _toAbsoluteWidth(gameAreaOffset.dx),
        food.y * mapUnitSize.height + _toAbsoluteHeight(gameAreaOffset.dy),
        mapUnitSize.width,
        mapUnitSize.height,
      ),
      Paint()
        ..color = Color(0xFFFFFFFF), //debug!!
    );

    // Draw snake on canvas
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

    // Draw snake eye
    // snake head
    final snakeHead = snake.body.first;
    // snake head left up point
    final headOffset = Offset(snakeHead.x * mapUnitSize.width  + _toAbsoluteWidth(gameAreaOffset.dx), snakeHead.y * mapUnitSize.height + _toAbsoluteHeight(gameAreaOffset.dy));
    // snake head eye unit size
    final eyeUnitSize = Size(mapUnitSize.width / 5, mapUnitSize.height / 5);
    // store snake eye size
    Size eyeSize = Size(0, 0);
    // store snake left eye offset
    Offset leftEyeOffset = Offset(0, 0);
    // store snake right eye offset
    Offset rightEyeOffset = Offset(0, 0);
    switch(snakeHead.direction) {
      case Direction.north: {
        eyeSize = Size(eyeUnitSize.width * 1, eyeUnitSize.height * 2);
        leftEyeOffset = Offset(headOffset.dx + eyeUnitSize.width * 1, headOffset.dy + eyeUnitSize.height * 1);
        rightEyeOffset = Offset(headOffset.dx + eyeUnitSize.width * 3, headOffset.dy + eyeUnitSize.height * 1);
        break;
      }
      case Direction.east: {
        eyeSize = Size(eyeUnitSize.width * 2, eyeUnitSize.height * 1);
        leftEyeOffset = Offset(headOffset.dx + eyeUnitSize.width * 1, headOffset.dy + eyeUnitSize.height * 3);
        rightEyeOffset = Offset(headOffset.dx + eyeUnitSize.width * 1, headOffset.dy + eyeUnitSize.height * 1);
        break;
      }
      case Direction.south: {
        eyeSize = Size(eyeUnitSize.width * 1, eyeUnitSize.height * 2);
        leftEyeOffset = Offset(headOffset.dx + eyeUnitSize.width * 3, headOffset.dy + eyeUnitSize.height * 2);
        rightEyeOffset = Offset(headOffset.dx + eyeUnitSize.width * 1, headOffset.dy + eyeUnitSize.height * 2);
        break;
      }
      case Direction.west: {
        eyeSize = Size(eyeUnitSize.width * 2, eyeUnitSize.height * 1);
        leftEyeOffset = Offset(headOffset.dx + eyeUnitSize.width * 2, headOffset.dy + eyeUnitSize.height * 1);
        rightEyeOffset = Offset(headOffset.dx + eyeUnitSize.width * 2, headOffset.dy + eyeUnitSize.height * 3);
        break;
      }
    }
    // left eye
    canvas.drawRect(
      Rect.fromLTWH(
        leftEyeOffset.dx,
        leftEyeOffset.dy,
        eyeSize.width,
        eyeSize.height,
      ),
      Paint()
        ..color = snake.eyeColor,
    );
    // right eye
    canvas.drawRect(
      Rect.fromLTWH(
        rightEyeOffset.dx,
        rightEyeOffset.dy,
        eyeSize.width,
        eyeSize.height,
      ),
      Paint()
        ..color = snake.eyeColor,
    );
  }

  /****************************************************************************************************
   * Load resource, food image or something else.
   ****************************************************************************************************/
  Future<void>? loadResources() async {
    foodImages['watermelon'] = [];
    for(int i = 0; i < maxFoodLife; ++i) {
      Flame.images.load('watermelon${i}.png').then((value) => foodImages['watermelon']!.add(value));
    }
    return;
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
   * Create a fruit on a new random point.
   * Warning: foodImages must be set before this function invoked.
   ****************************************************************************************************/
  bool createNewFruit() {
    if(snake.length >= gameMap.x * gameMap.y) {
      return false;
    }

    // Get new point
    int x = 0;
    int y = 0;
    do {
      int x = random.nextInt(gameMap.x);
      int y = random.nextInt(gameMap.y);
    } while(snake.isPointOnBody(x, y));

    // Get new foodName
    if(foodImages.values.length == 0) {
      print("Warning: foodImages must be set before SnakeGame::createNewFruit() invoked.");
      return false;
    }
    int foodNameIndex = random.nextInt(foodImages.length);
    print(foodNameIndex); //debug!!
    String foodName = foodImages.keys.elementAt(foodNameIndex);
    print(foodName); //debug!!

    food = Food(x, y, name: foodName);

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
