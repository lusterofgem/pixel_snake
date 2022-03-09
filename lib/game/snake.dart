import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart' as material;

import 'direction.dart';
import 'food_color.dart';
import 'snake_unit.dart';

/// The class to store snake information
class Snake {
  Point<int> _spawnPoint;

  // Snake body, snake head is body[0]
  List<SnakeUnit> _body;

  // Is the snake still alive
  bool _alive;

  // The color of snake eye
  Color eyeColor;

  /// Construct by given x and y.
  /// Direction is Direction.north.
  Snake(int x, int y)
  :_body = []
  ,_spawnPoint = Point(x, y)
  ,_alive = true
  ,eyeColor = const Color(0xFF000000) {
    _body.add(SnakeUnit(_spawnPoint.x, _spawnPoint.y, direction: Direction.north, color: FoodColor.getRandomColor()));
  }

  // snake body
  List<SnakeUnit> get body => _body;

  /// snake length
  int get length => _body.length;

  /// Reset the snake to default state.
  void reset() {
    _body = [];
    _body.add(SnakeUnit(_spawnPoint.x, _spawnPoint.y, direction: Direction.north, color: FoodColor.getRandomColor()));
    _alive = true;
  }

  /// Set the snake default spawn point
  void setSpawnPoint(int x, int y) {
    _spawnPoint = Point(x, y);
  }

  /// Force move to target point. (May cut the snake into two parts)
  void moveTo(int x, int y) {
    _body[0].x = x;
    _body[0].y = y;
    for(int i = 1; i < _body.length; ++i) {
      _body[i].forward();
      _body[i].direction = _body[i-1].direction;
    }
  }

  /// Force move to target point and grow on the tail. (May cut the snake into two parts)
  void moveToAndGrow(int x, int y, {Color color = const Color(0xFFAAAAAA)}) {
    SnakeUnit newTail = SnakeUnit(0, 0, color: color);
    newTail.x = _body.last.x;
    newTail.y = _body.last.y;
    newTail.direction = _body.last.direction;

    moveTo(x, y);
    _body.add(newTail);
  }

  /// Forward the snake
  void forward() {
//     body[0].forward();
//     for(int i = 1; i < body.length; ++i) {
//       body[i].forward();
//       body[i].direction = body[i-1].direction;
//     }
//     SnakeUnit temp = SnakeUnit(0, 0);
    for(int i = _body.length - 1; i > 0; --i) {
      _body[i].x = _body[i-1].x;
      _body[i].y = _body[i-1].y;
      _body[i].direction = _body[i-1].direction;
    }
    _body.first.forward();
  }

  /// Forward the snake and grow
  void forwardAndGrow({Color color = const Color(0xFFAAAAAA)}) {
    SnakeUnit newTail = SnakeUnit(0, 0, color: color);
    newTail.x = _body.last.x;
    newTail.y = _body.last.y;
    newTail.direction = _body.last.direction;

    forward();
    _body.add(newTail);
  }

  /// Turn snake head to given direction
  void turn(Direction direction) {
    if(_body.length > 1) {
      switch(direction) {
        case Direction.north: {
          if(_body.first.y > _body[1].y) {
            material.debugPrint("Failed to turn north"); //debug!!
            return;
          }
          break;
        }
        case Direction.east: {
          if(_body.first.x < _body[1].x) {
            material.debugPrint("Failed to turn east"); //debug!!
            return;
          }
          break;
        }
        case Direction.south: {
          if(_body.first.y < _body[1].y) {
            material.debugPrint("Failed to turn south"); //debug!!
            return;
          }
          break;
        }
        case Direction.west: {
          if(_body.first.x > _body[1].x) {
            material.debugPrint("Failed to turn west"); //debug!!
            return;
          }
          break;
        }
      }
    }
    material.debugPrint("snake.body.length = ${_body.length}");
    _body[0].direction = direction;
  }

  /// If the snake is alive
  bool isAlive() {
    return _alive;
  }

  /// Is the given point overlapped the snake body
  bool isPointOnBody(int x, int y) {
    for(SnakeUnit snakeUnit in _body) {
      if(snakeUnit.x == x && snakeUnit.y == y) {
        return true;
      }
    }

    return false;
  }

  /// Get the snake faced x coord.
  Point<int> getTargetPoint() {
    final snakeHead = _body.first;
    var targetPoint = Point(snakeHead.x, snakeHead.y);
    switch(snakeHead.direction) {
      case Direction.north: {
        targetPoint -= const Point(0, 1);
        break;
      }
      case Direction.east: {
        targetPoint += const Point(1, 0);
        break;
      }
      case Direction.south: {
        targetPoint += const Point(0, 1);
        break;
      }
      case Direction.west: {
        targetPoint -= const Point(1, 0);
        break;
      }
    }

    return targetPoint;
  }
}
