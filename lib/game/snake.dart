import "dart:ui";

import "package:flutter/material.dart" as material;
import "package:vector_math/vector_math_64.dart";

import "direction.dart";
import "food.dart";
import "snake_unit.dart";

/// The class to store snake information
class Snake {
  Vector2 _spawnPoint;

  // Snake body, snake head is body[0]
  List<SnakeUnit> _body;

  // Is the snake still alive
  bool _alive;

  // The color of snake eye
  Color eyeColor;

  /// Construct by given x and y.
  /// Direction is Direction.north.
  Snake({Vector2? spawnPoint})
  :_body = []
  ,_spawnPoint = spawnPoint ?? Vector2(0, 0)
  ,_alive = true
  ,eyeColor = const Color(0xFF000000) {
    _body.add(SnakeUnit(position: _spawnPoint, direction: Direction.north, color: Food.getRandomColor()));
  }

  // snake body
  List<SnakeUnit> get body => _body;

  /// snake length
  int get length => _body.length;

  /// Reset the snake to default state.
  void reset() {
    _body = [];
    _body.add(SnakeUnit(position: _spawnPoint, direction: Direction.north, color: Food.getRandomColor()));
    _alive = true;
  }

  /// Set the snake default spawn point
  void setSpawnPoint(Vector2 spawnPoint) {
    _spawnPoint = spawnPoint;
  }

  /// Force move to target point. (May cut the snake into two parts)
  void moveTo(Vector2 position) {
    _body[0].position = position.clone();
    for(int i = 1; i < _body.length; ++i) {
      _body[i].forward();
      _body[i].direction = _body[i-1].direction;
    }
  }

  /// Force move to target point and grow on the tail. (May cut the snake into two parts)
  void moveToAndGrow(Vector2 position, {Color color = const Color(0xFFAAAAAA)}) {
    SnakeUnit newTail = SnakeUnit(color: color);
    newTail.position = _body.last.position.clone();
    newTail.direction = _body.last.direction;

    moveTo(position);
    _body.add(newTail);
  }

  /// Forward the snake
  void forward() {
    for(int i = _body.length - 1; i > 0; --i) {
      _body[i].position = _body[i-1].position.clone();
      _body[i].direction = _body[i-1].direction;
    }
    _body.first.forward();
  }

  /// Forward the snake and grow
  void forwardAndGrow({Color color = const Color(0xFFAAAAAA)}) {
    SnakeUnit newTail = SnakeUnit(color: color);
    newTail.position = _body.last.position.clone();
    newTail.direction = _body.last.direction;

    forward();
    _body.add(newTail);
  }

  /// Turn snake head to given direction
  void turn(Direction direction) {
    if(_body.length > 1) {
      switch(direction) {
        case Direction.north: {
          if(_body.first.position.y > _body[1].position.y) {
            material.debugPrint("Failed to turn north"); //debug!!
            return;
          }
          break;
        }
        case Direction.east: {
          if(_body.first.position.x < _body[1].position.x) {
            material.debugPrint("Failed to turn east"); //debug!!
            return;
          }
          break;
        }
        case Direction.south: {
          if(_body.first.position.y < _body[1].position.y) {
            material.debugPrint("Failed to turn south"); //debug!!
            return;
          }
          break;
        }
        case Direction.west: {
          if(_body.first.position.x > _body[1].position.x) {
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
  bool isPointOnBody(Vector2 position) {
    for(SnakeUnit snakeUnit in _body) {
      if(snakeUnit.position == position) {
        return true;
      }
    }

    return false;
  }

  /// Get the snake faced x coord.
  Vector2 getTargetPoint() {
    final snakeHead = _body.first;
    var targetPoint = Vector2(snakeHead.position.x, snakeHead.position.y);
    switch(snakeHead.direction) {
      case Direction.north: {
        --targetPoint.y;
        break;
      }
      case Direction.east: {
        ++targetPoint.x;
        break;
      }
      case Direction.south: {
        ++targetPoint.y;
        break;
      }
      case Direction.west: {
        --targetPoint.x;
        break;
      }
    }

    return targetPoint;
  }
}
