import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart' as material;
import 'package:vector_math/vector_math_64.dart';

import 'direction.dart';
import 'food.dart';
import 'game_map.dart';
import 'snake.dart';
import '../pixel_snake.dart';

// The class to store snake game information
class SnakeGame {
  // The relative size that the game area on the screen.
  Size gameAreaSize = const Size(100, 90);

  // The offset of game area.
  Offset gameAreaOffset = const Offset(0, 10);

  // The color of game area
  Color gameAreaColor = const Color(0xFFC8FF64);

  // Store map information
  late GameMap gameMap;
  // Store snake body information
  late Snake snake;
  // Store current food information
  late Food food;

  int currentScore = 0;

  /// Construct by the given map size.
  SnakeGame(int x, int y) {
    gameMap = GameMap(x, y);
    snake = Snake((x/2).ceil() ,(y/2).ceil());
    reset();
  }

  /// Load resource, food image or something else.
  static Future<void> loadResource() async {
    Food.loadResource();
  }

  /// Get a single map unit absolute size.
  /// Warning: _screenSize must be set before this function invoked.
  Size getMapUnitSize({required Vector2 screenSize}) {
    Size mapUnitSize = Size(_toAbsoluteWidth(gameAreaSize.width, screenSize: screenSize) / gameMap.x,
                            _toAbsoluteHeight(gameAreaSize.height, screenSize: screenSize) / gameMap.y);
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
    snake.forwardAndGrow(color : Food.getRandomColor());
    snake.forwardAndGrow(color : Food.getRandomColor());
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
      snake.forwardAndGrow(color: Food.colors[food.imageId]);
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
      x = Random().nextInt(gameMap.x);
      y = Random().nextInt(gameMap.y);
    } while(snake.isPointOnBody(x, y));
    // Check the setting and generate image id
    int imageId;
    do {
      imageId = Random().nextInt(5);
    } while(!PixelSnake.enabledFood[imageId]);
    food = Food(x, y, imageId: imageId);
    return true;
  }

  /// Convert percentage width (0.0 ~ 100.0) to real real width on the screen.
  /// Warning: _screenSize need to be set before this function being invoked.
  double _toAbsoluteWidth(double relativeWidth, {required Vector2 screenSize}) {
    return screenSize.x * relativeWidth / 100.0;
  }

  /// Convert percentage height (0.0 ~ 100.0) to real height on the screen.
  /// Warning: _screenSize need to be set before this function being invoked.
  double _toAbsoluteHeight(double relativeHeight, {required Vector2 screenSize}) {
    return screenSize.x * relativeHeight / 100.0;
  }
}
