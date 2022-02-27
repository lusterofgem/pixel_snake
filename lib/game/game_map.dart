// import 'dart:ui';

/// Store map size information for the game
class GameMap {
  int x = 0;
  int y = 0;

  /// Construct by given map size.
  GameMap(this.x, this.y);

  /// Set the map size
  void setSize(int x, int y) {
    this.x = x;
    this.y = y;
  }
}
