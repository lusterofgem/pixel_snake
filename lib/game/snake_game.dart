import 'dart:math';
import 'dart:ui';

import 'package:flame/sprite.dart';
import 'package:flutter/material.dart' as material;
import 'package:vector_math/vector_math_64.dart';

import 'direction.dart';
import 'food.dart';
import 'food_color.dart';
import 'game_map.dart';
import 'snake.dart';

// The class to store snake game information
class SnakeGame {
  // The relative size that the game area on the screen.
  Size gameAreaSize = const Size(100, 90);

  // The offset of game area.
  Offset gameAreaOffset = const Offset(0, 10);

  // The color of game area
  Color gameAreaColor = const Color(0xFFC8FF64);

  // Map<String, List<Image>> foodImages = {};
  Image? foodImage;

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

  int currentScore = 0;

  /// Construct by the given map size.
  SnakeGame(int x, int y) {
    gameMap = GameMap(x, y);
    snake = Snake((x/2).ceil() ,(y/2).ceil());
    reset();
  }

  /// Render the game on canvas.
  /// Game render area size have to be set in this function,
  /// need the size of render area to draw the game area correctly.
  /// Warning: Need to call loadResource before this function invoked.
  void drawOnCanvas(Canvas canvas, Size screenSize) {
    // Set render area size
    _screenSize = screenSize;

    // Render game area on canvas
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

    final mapUnitSize = getMapUnitSize();
    // Render food on canvas
    var foodImage = food.image;
    Sprite sprite = Sprite(foodImage);
    sprite.render(
      canvas,
      position: Vector2(food.x * mapUnitSize.width + _toAbsoluteWidth(gameAreaOffset.dx), food.y * mapUnitSize.height + _toAbsoluteHeight(gameAreaOffset.dy)),
      size: Vector2(mapUnitSize.width, mapUnitSize.height),
    );

    // Render snake on canvas
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

    // Render snake eye
    // snake head
    final snakeHead = snake.body.first;
    // snake head left up point
    final headOffset = Offset(snakeHead.x * mapUnitSize.width  + _toAbsoluteWidth(gameAreaOffset.dx), snakeHead.y * mapUnitSize.height + _toAbsoluteHeight(gameAreaOffset.dy));
    // snake head eye unit size
    final eyeUnitSize = Size(mapUnitSize.width / 5, mapUnitSize.height / 5);
    // store snake eye size
    Size eyeSize = const Size(0, 0);
    // store snake left eye offset
    Offset leftEyeOffset = const Offset(0, 0);
    // store snake right eye offset
    Offset rightEyeOffset = const Offset(0, 0);
    switch(snakeHead.direction) {
      case Direction.north: {
        leftEyeOffset = Offset(headOffset.dx + eyeUnitSize.width * 1, headOffset.dy + eyeUnitSize.height * 1);
        rightEyeOffset = Offset(headOffset.dx + eyeUnitSize.width * 3, headOffset.dy + eyeUnitSize.height * 1);
        eyeSize = Size(eyeUnitSize.width * 1, eyeUnitSize.height * 2);
        break;
      }
      case Direction.east: {
        leftEyeOffset = Offset(headOffset.dx + eyeUnitSize.width * 2, headOffset.dy + eyeUnitSize.height * 1);
        rightEyeOffset = Offset(headOffset.dx + eyeUnitSize.width * 2, headOffset.dy + eyeUnitSize.height * 3);
        eyeSize = Size(eyeUnitSize.width * 2, eyeUnitSize.height * 1);
        break;
      }
      case Direction.south: {
        leftEyeOffset = Offset(headOffset.dx + eyeUnitSize.width * 3, headOffset.dy + eyeUnitSize.height * 2);
        rightEyeOffset = Offset(headOffset.dx + eyeUnitSize.width * 1, headOffset.dy + eyeUnitSize.height * 2);
        eyeSize = Size(eyeUnitSize.width * 1, eyeUnitSize.height * 2);
        break;
      }
      case Direction.west: {
        leftEyeOffset = Offset(headOffset.dx + eyeUnitSize.width * 1, headOffset.dy + eyeUnitSize.height * 3);
        rightEyeOffset = Offset(headOffset.dx + eyeUnitSize.width * 1, headOffset.dy + eyeUnitSize.height * 1);
        eyeSize = Size(eyeUnitSize.width * 2, eyeUnitSize.height * 1);
        break;
      }
    }
    // Render left eye
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
    // Render right eye
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

  /// Load resource, food image or something else.
  static Future<void> loadResource() async {
    Food.loadResource();
  }

  /// Get a single map unit absolute size.
  /// Warning: _screenSize must be set before this function invoked.
  Size getMapUnitSize() {
    final screenSize = _screenSize;
    if(screenSize == null) {
      material.debugPrint("Warning: _screenSize must be set before this SnakeGame::getMapUnitSize() invoked.");
      return const Size(0, 0);
    }
    Size mapUnitSize = Size(_toAbsoluteWidth(gameAreaSize.width) / gameMap.x,
                            _toAbsoluteHeight(gameAreaSize.height) / gameMap.y);
    return mapUnitSize;
  }

  /// Set map size.
  void setMapSize(int x, int y) {
    //wip: recount default snake head position
    gameMap.setSize(x, y);
  }

  /// Reset the game
  void reset() {
    snake.reset();
    snake.forwardAndGrow(color : FoodColor.getRandomColor());
    snake.forwardAndGrow(color : FoodColor.getRandomColor());
    createNewFood();

    currentScore = 0;
  }

  /// Check if snake can move forward. (Didn't face snake body or map boundary)
  bool canForwardSnake() {
    final targetPoint = snake.getTargetPoint();

    // Hit snake body
    if(snake.isPointOnBody(targetPoint.x, targetPoint.y)) {
      return false;
    }
    // Hit map boudary
    else if(!(targetPoint.x >= 0 && targetPoint.x < gameMap.x)) {
      return false;
    }
    else if(!(targetPoint.y >= 0 && targetPoint.y < gameMap.y)) {
      return false;
    }
    return true;
  }

  /// Forward the snake. (Or forward and grow if hit food).
  void forwardSnake() {
    final targetPoint = snake.getTargetPoint();

    // Touch a food
    if(targetPoint.x == food.x && targetPoint.y == food.y) {
      snake.forwardAndGrow(color: FoodColor.colors[food.imageId]);
      createNewFood();
      ++currentScore;
      material.debugPrint("currentScore: " + currentScore.toString());
    }
    // Didn't touch a food
    else {
      snake.forward();
    }
  }

  /// Force move the snake to target point. (May cut the snake into two parts)
  void moveSnakeTo(int x, int y) {
    return snake.moveTo(x, y);
  }

  /// Turn snake head to given direction
  void turnSnake(Direction direction) {
    return snake.turn(direction);
  }

  /// Create a food on a new random point.
  /// Warning: foodImages must be set before this function invoked.
  bool createNewFood() {
    if(snake.length >= gameMap.x * gameMap.y) {
      return false;
    }

    // Get new point
    int x = 0;
    int y = 0;
    do {
      x = random.nextInt(gameMap.x);
      y = random.nextInt(gameMap.y);
    } while(snake.isPointOnBody(x, y));

    food = Food(x, y);
    return true;
  }

  /// Convert percentage width (0.0 ~ 100.0) to real real width on the screen.
  /// Warning: _screenSize need to be set before this function being invoked.
  double _toAbsoluteWidth(double relativeWidth) {
    final _screenSize = this._screenSize;
    if(_screenSize == null) {
      material.debugPrint("Error: _screenSize need to be set before SnakeGame::_toAbsoluteWidth(double relativeWidth) being invoked.");
      return 0;
    }

    return _screenSize.width * relativeWidth / 100.0;
  }

  /// Convert percentage height (0.0 ~ 100.0) to real height on the screen.
  /// Warning: _screenSize need to be set before this function being invoked.
  double _toAbsoluteHeight(double relativeHeight) {
    final _screenSize = this._screenSize;
    if(_screenSize == null) {
      material.debugPrint("Error: _screenSize need to be set before SnakeGame::_toAbsoluteHeight(double relativeHeight) being invoked.");
      return 0;
    }

    return _screenSize.height * relativeHeight / 100.0;
  }
}
