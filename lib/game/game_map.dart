// import 'dart:ui';
import 'package:vector_math/vector_math_64.dart';

/// Store map size information for the game
class GameMap {
  Vector2 size;

  /// Construct by given map size.
  GameMap({Vector2? size})
  :size = size ?? Vector2(0, 0);

  /// Set the map size
  void setSize(Vector2 size) {
    this.size = size;
  }

  bool isPointInMap(Vector2 point) {
    if(point.x < 0 || point.x >= size.x || point.y < 0 || point.y >= size.y) {
      return false;
    }
    return true;
  }
}
