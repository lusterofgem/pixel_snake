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
  Vector2 gameAreaSize = Vector2(100, 90);

  // The offset of game area.
  Vector2 gameAreaOffset = Vector2(0, 10);

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
  SnakeGame({required Vector2 mapSize}) {
    gameMap = GameMap(size: mapSize);
    snake = Snake(spawnPoint: Vector2((mapSize.x ~/ 2).toDouble() , (mapSize.y ~/ 2).toDouble()));
    reset();
  }

  static get size => null;

  /// Load resource, food image or something else.
  static Future<void> loadResource() async {
    Food.loadResource();
  }

  /// Get a single map unit absolute size.
  /// Warning: _screenSize must be set before this function invoked.
  Size getMapUnitSize({required Vector2 screenSize}) {
    Size mapUnitSize = Size(_toAbsoluteWidth(gameAreaSize.x, screenSize: screenSize) / gameMap.size.x,
                            _toAbsoluteHeight(gameAreaSize.y, screenSize: screenSize) / gameMap.size.y);
    return mapUnitSize;
  }

  /// Set map size.
  void setMapSize(Vector2 size) {
    //wip: recount default snake head position
    gameMap.setSize(size);
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
    if(snake.isPointOnBody(targetPoint)) {
      return false;
    }
    // Hit map boudary
    else if(!gameMap.isPointInMap(targetPoint)) {
      return false;
    }
    return true;
  }

  /// Forward the snake. (Or forward and grow if hit food).
  void forwardSnake() {
    final targetPoint = snake.getTargetPoint();

    // Touch a food
    if(targetPoint.x == food.position.x && targetPoint.y == food.position.y) {
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
  void moveSnakeTo(Vector2 point) {
    return snake.moveTo(point);
  }

  /// Turn snake head to given direction
  void turnSnake(Direction direction) {
    return snake.turn(direction);
  }

  /// Create a food on a new random point.
  /// Warning: foodImages must be set before this function invoked.
  bool createNewFood() {
    if(snake.length >= gameMap.size.x * gameMap.size.y) {
      return false;
    }

    // Get new point
    Vector2 position = Vector2(0, 0);
    do {
      position = Vector2(Random().nextInt(gameMap.size.x.toInt()).toDouble(), Random().nextInt(gameMap.size.y.toInt()).toDouble());
    } while(snake.isPointOnBody(position));
    // Check the setting and generate image id
    int imageId;
    do {
      imageId = Random().nextInt(5);
    } while(!PixelSnake.enabledFood[imageId]);
    food = Food(position: position, imageId: imageId);
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
