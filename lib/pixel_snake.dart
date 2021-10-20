import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'game_state.dart';
import 'animation_type.dart';
// import 'animated_button.dart';

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
  Size? _size;

  // Running state of the game.
  GameState _gameState = GameState.begin;

  // Store type of playing animation.
  AnimationType _animationState = AnimationType.none;

  // Store frame index of playing animation.
  int _animationFrame = 0;

  // Save animation frame index for animated button.
  // The first layer of this map will auto generate using the GameState enumeration,
  // but the second layer need to be set up in onMount().
  // Example: _animatedButtonFrame[GameState.begin]!["start"] = 0;
  Map<GameState, Map<String, int>> _animatedButtonFrame = Map.fromIterable(
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

  }

  /****************************************************************************************************
   * Override from Loadable. (flame/lib/src/game/mixins/loadable.dart)
   * Init settings.
   ****************************************************************************************************/
  @override
  void onMount() {
    // Save animation frame index for animated button
    _animatedButtonFrame[GameState.begin]!["start"] = 0;
    _animatedButtonFrame[GameState.begin]!["setting"] = 0;
    _animatedButtonFrame[GameState.begin]!["history"] = 0;
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
    _size = Size(size.x, size.y);
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
   * Convert percentage width (0.0 ~ 100.0) to real screen width.
   ****************************************************************************************************/
  double toRealWidth(double percentageWidth) {
    final _size = this._size;
    if(_size == null) {
      return 0;
    }

    return _size.width * percentageWidth / 100.0;
  }

  /****************************************************************************************************
   * Convert percentage height (0.0 ~ 100.0) to real screen width.
   ****************************************************************************************************/
  double toRealHeight(double percentageHeight) {
    final _size = this._size;
    if(_size == null) {
      return 0;
    }

    return _size.height * percentageHeight / 100.0;
  }

  /****************************************************************************************************
   * Convert percentage size to real screen size.
   ****************************************************************************************************/
  Size toRealSize(Size size) {
    final _size = this._size;
    if(_size == null) {
      return Size(0, 0);
    }

    return Size(toRealWidth(size.width), toRealHeight(size.height));
  }

  /****************************************************************************************************
   * Render the game begin screen, used in render(canvas).
   ****************************************************************************************************/
  void renderBeginScreen(Canvas canvas) {
    // Draw background
    // Type promotion Size? to Size
    final _size = this._size;
    if(_size != null) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, _size.width, _size.height),
        Paint()
          ..color = Colors.orange,
      );
    }

    // Draw start button
    canvas.drawRect(
      Rect.fromLTWH(toRealWidth(20), toRealHeight(60), toRealWidth(60), toRealHeight(15)),
      Paint()
        ..color = Colors.yellow,
    );

    // Draw setting button
    canvas.drawRect(
      Rect.fromLTWH(toRealWidth(20), toRealHeight(80), toRealWidth(25), toRealHeight(12.5)),
      Paint()
        ..color = Colors.blue,
    );

    // Draw history score button
    canvas.drawRect(
      Rect.fromLTWH(toRealWidth(55), toRealHeight(80), toRealWidth(25), toRealHeight(12.5)),
      Paint()
        ..color = Colors.purple,
    );

    // Draw all buttons
//     Map<String, AnimatedButton> animatedButtons = _animatedButtonFrame[GameState.begin] ??= Map();
  }

  /****************************************************************************************************
   * Render the game playing screen, used in render(canvas).
   ****************************************************************************************************/
  void renderPlayingScreen(Canvas canvas) {
    // Draw background
    // Type promotion Size? to Size
    final _size = this._size;
    if(_size != null) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, _size.width, _size.height),
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
    final _size = this._size;
    if(_size != null) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, _size.width, _size.height),
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
    final _size = this._size;
    if(_size != null) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, _size.width, _size.height),
        Paint()
          ..color = Colors.green,
      );
    }
  }
}
