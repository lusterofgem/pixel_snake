import 'dart:ui';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'enum/game_state.dart';

class PixelSnake with Loadable, Game, TapDetector {
  // Running state of the game
  GameState gameState = GameState.start;

  /****************************************************************************************************
   * Override from TapDetector. (flame/lib/src/gestures/detectors.dart)
   * Triggered when the user tap down on the screen.
   ****************************************************************************************************/
  @override
  void onTapDown(TapDownInfo info) {
    print("onTapDown()");
  }

  /****************************************************************************************************
   * Override from Loadable. (flame/lib/src/game/mixins/loadable.dart)
   *
   ****************************************************************************************************/
  @override
  Future<void>? onLoad() {
//     print("onLoad()"); //debug
  }

  /****************************************************************************************************
   * Override from Loadable. (flame/lib/src/game/mixins/loadable.dart)
   *
   ****************************************************************************************************/
  @override
  void onMount() {
//     print("onMount()"); //debug
  }

  /****************************************************************************************************
   * Override from Game. (flame/lib/src/game/mixins/game.dart)
   * Triggered 60 times/s when it is not lagged.
   ****************************************************************************************************/
  @override
  void render(Canvas canvas) {
//     print("render()");
  }

  /****************************************************************************************************
   * Override from Game. (flame/lib/src/game/mixins/game.dart)
   * Triggered 60 times/s (0.016666 s/time) when it is not lagged.
   ****************************************************************************************************/
  @override
  void update(double lastLoopElapsedTime) {
//     print("update()");
  }
}
