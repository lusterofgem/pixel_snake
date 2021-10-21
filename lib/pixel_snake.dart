import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'game_state.dart';
import 'animation_type.dart';
import 'widget/animated_button.dart';
import 'ui.dart';

class PixelSnake with Loadable, Game, TapDetector {
  /****************************************************************************************************
   * Settings
   ****************************************************************************************************/
  // How many block units in the map, init when the game is start.
  Size mapSize = Size(10, 10);

  /****************************************************************************************************
   * Variables
   ****************************************************************************************************/
  // Screen size, update in onGameResize(Size).
  Size? _screenSize;

  // Running state of the game.
  GameState _gameState = GameState.begin;

  // Store type of playing animation.
  AnimationType _animationState = AnimationType.none;

  // Store frame index of playing animation.
  int _animationFrame = 0;

  // Save animation frame index for animated button.
  // The first layer of this map will auto generate using the GameState enumeration,
  // but the second layer need to be set up in onLoad().
  Map<GameState, Map<String, AnimatedButton>> _animatedButtons = Map.fromIterable(
    GameState.values,
    key: (value) => value,
    value: (value) => Map(),
  );

  /****************************************************************************************************
   * Image
   ****************************************************************************************************/
//   Image? cookieImage;

  /****************************************************************************************************
   * Override from TapDetector. (flame/lib/src/gestures/detectors.dart)
   * Triggered when the user tap down on the screen.
   ****************************************************************************************************/
  @override
  void onTapDown(TapDownInfo info) {

  }

  /****************************************************************************************************
   * Override from TapDetector. (flame/lib/src/gestures/detectors.dart)
   * Triggered when the user tap up on the screen.
   ****************************************************************************************************/
  @override
  void onTapUp(TapUpInfo info) {

  }

  /****************************************************************************************************
   * Override from Loadable. (flame/lib/src/game/mixins/loadable.dart)
   * Load recources like image, audio, etc.
   ****************************************************************************************************/
  @override
  Future<void>? onLoad() {
//     cookieImage = await Flame.images.load('cookie0.png');
    // Load button
    _animatedButtons[GameState.begin]!["start"] = BeginStartButton();
//     _animatedButtons[GameState.begin]!["pause"] = BeginPauseButton();
//     _animatedButtons[GameState.begin]!["history"] = BeginHistoryButton();
  }

  /****************************************************************************************************
   * Override from Loadable. (flame/lib/src/game/mixins/loadable.dart)
   * Init settings.
   ****************************************************************************************************/
  @override
  void onMount() {

  }

  /****************************************************************************************************
   * Override from Game. (flame/lib/src/game/mixins/game.dart)
   * Triggered 60 times/s when it is not lagged.
   ****************************************************************************************************/
  @override
  void render(Canvas canvas) {
    switch(_gameState) {
      // The screen before game start
      case GameState.begin: {
        renderBeginScreen(canvas);

        break;
      }

      // The screen when the game is playing
      case GameState.playing: {
        renderPlayingScreen(canvas);

        break;
      }

      // The screen when the game is pause
      case GameState.pause: {
        renderPlayingScreen(canvas);
        renderPauseMenu(canvas);

        break;
      }

      // The screen when the game over
      case GameState.gameOver: {
        renderGameOverScreen(canvas);

        break;
      }
    }
  }

  /****************************************************************************************************
   * Override from Game. (flame/lib/src/game/mixins/game.dart)
   * Triggered 60 times/s (0.016666 s/time) when it is not lagged.
   ****************************************************************************************************/
  @override
  void update(double updateTime) {

  }

  /****************************************************************************************************
   * Override from Game. (flame/lib/src/game/mixins/game.dart)
   * Triggered when the game is resize.
   ****************************************************************************************************/
  @override
  @mustCallSuper // import 'package:flutter/material.dart'
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _screenSize = Size(size.x, size.y);
  }

  /****************************************************************************************************
   * Active animation
   ****************************************************************************************************/
  void _activeAnimation(AnimationType animationType) {
    _animationState = animationType;
    _animationFrame = 0;
  }

  /****************************************************************************************************
   * Stop animation
   ****************************************************************************************************/
  void _stopAnimation() {
    _animationState = AnimationType.none;
  }

  /****************************************************************************************************
   * Start game, let's play!
   ****************************************************************************************************/
  void _startGame() {
    _activeAnimation(AnimationType.starting);
  }

  /****************************************************************************************************
   * Pause the game.
   ****************************************************************************************************/
  void _pauseGame() {
    _activeAnimation(AnimationType.pausing);
  }

  /****************************************************************************************************
   * Unpause the game.
   ****************************************************************************************************/
  void _unpauseGame() {
    _activeAnimation(AnimationType.unpausing);
  }

  /****************************************************************************************************
   * End game, game over!
   ****************************************************************************************************/
  void _gameOver() {
    _activeAnimation(AnimationType.gameOver);
  }

  /****************************************************************************************************
   * Convert percentage width (0.0 ~ 100.0) to real width on the screen.
   ****************************************************************************************************/
  double toRealWidth(double percentageWidth) {
    final _screenSize = this._screenSize;
    if(_screenSize == null) {
      return 0;
    }

    return _screenSize.width * percentageWidth / 100.0;
  }

  /****************************************************************************************************
   * Convert percentage height (0.0 ~ 100.0) to real height on the screen.
   ****************************************************************************************************/
  double toRealHeight(double percentageHeight) {
    final _screenSize = this._screenSize;
    if(_screenSize == null) {
      return 0;
    }

    return _screenSize.height * percentageHeight / 100.0;
  }

  /****************************************************************************************************
   * Render the game begin screen, used in render(canvas).
   ****************************************************************************************************/
  void renderBeginScreen(Canvas canvas) {
    // Draw background
    // Type promotion Size? to Size
    final _screenSize = this._screenSize;
    if(_screenSize == null) {
      return;
    }
    canvas.drawRect(
      Rect.fromLTWH(0, 0, _screenSize.width, _screenSize.height),
      Paint()
        ..color = Colors.orange,
    );

    // Draw all button
//     _animatedButtons[GameState.begin]!.forEach(
//       (key, value) => value.drawOnCanvas(canvas, _screenSize)
//     );

    // Draw start button
//     final _startButton = this._startButton;
//     if(_startButton != null) {
//       _startButton.drawOnCanvas(canvas, _screenSize);
//     }

    // Draw setting button
//     switch(_animatedButtonFrame[GameState.begin]!["setting"]) {
//       case 0: {
//         canvas.drawRect(
//           Rect.fromLTWH(toRealWidth(20), toRealHeight(62.5), toRealWidth(25), toRealHeight(12.5)),
//           Paint()
//             ..color = Colors.blue,
//         );
//
//         break;
//       }
//
//       case 1: {
//         canvas.drawRect(
//           Rect.fromLTWH(toRealWidth(20), toRealHeight(62.5), toRealWidth(25), toRealHeight(12.5)),
//           Paint()
//             ..color = Colors.blue,
//         );
//
//         break;
//       }
//
//       default: {
//         canvas.drawRect(
//           Rect.fromLTWH(toRealWidth(20), toRealHeight(62.5), toRealWidth(25), toRealHeight(12.5)),
//           Paint()
//             ..color = Colors.blue,
//         );
//
//         break;
//       }
//     }

    // Draw history score button
//     switch(_animatedButtonFrame[GameState.begin]!["history"]) {
//       case 0: {
//         canvas.drawRect(
//           Rect.fromLTWH(toRealWidth(55), toRealHeight(62.5), toRealWidth(25), toRealHeight(12.5)),
//           Paint()
//             ..color = Colors.purple,
//         );
//
//         break;
//       }
//
//       case 1: {
//         canvas.drawRect(
//           Rect.fromLTWH(toRealWidth(55), toRealHeight(62.5), toRealWidth(25), toRealHeight(12.5)),
//           Paint()
//             ..color = Colors.purple,
//         );
//
//         break;
//       }
//
//       default: {
//         canvas.drawRect(
//           Rect.fromLTWH(toRealWidth(55), toRealHeight(62.5), toRealWidth(25), toRealHeight(12.5)),
//           Paint()
//             ..color = Colors.purple,
//         );
//
//         break;
//       }
//     }
  }

  /****************************************************************************************************
   * Render the game playing screen, used in render(canvas).
   ****************************************************************************************************/
  void renderPlayingScreen(Canvas canvas) {
    // Draw background
    // Type promotion Size? to Size
    final _screenSize = this._screenSize;
    if(_screenSize != null) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, _screenSize.width, _screenSize.height),
        Paint()
          ..color = Colors.green,
      );
    }
  }

  /****************************************************************************************************
   * Render the game pause menu, used in render(canvas).
   ****************************************************************************************************/
  void renderPauseMenu(Canvas canvas) {
    // Draw background
    // Type promotion Size? to Size
    final _screenSize = this._screenSize;
    if(_screenSize != null) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, _screenSize.width, _screenSize.height),
        Paint()
          ..color = Colors.green,
      );
    }
  }

  /****************************************************************************************************
   * Render the game over screen, used in render(canvas).
   ****************************************************************************************************/
  void renderGameOverScreen(Canvas canvas) {
    // Draw background
    // Type promotion Size? to Size
    final _screenSize = this._screenSize;
    if(_screenSize != null) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, _screenSize.width, _screenSize.height),
        Paint()
          ..color = Colors.green,
      );
    }
  }
}
