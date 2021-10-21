import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'game_state.dart';
import 'animation_type.dart';
import 'button.dart';

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

  // Map of Map of button, example: _buttons[GameState.begin]['start']
  // The first layer of this map will auto generate using the GameState enumeration,
  // but the second layer need to be set up in onLoad().
  Map<GameState, Map<String, Button>> _buttons = Map.fromIterable(
    GameState.values,
    key: (value) => value,
    value: (value) => Map(),
  );

  // The current tapping button
  // This variable is to make sure the button to tap up correctly when the tap cancelled
  Button? _tappingButton;

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
    final x = _toRelativeWidth(info.eventPosition.game.x);
    final y = _toRelativeHeight(info.eventPosition.game.y);
//     print('Tap down on (${x}, ${y})'); //debug

    switch(_gameState) {
      case GameState.begin: {
        // Check which button is tap down
        _buttons[GameState.begin]!.forEach(
          (key, value) => {
            if(value.isOnButton(x, y)) {
              print("GameState.begin ${key} button tap down"), //debug
              value.tapDown(),
              _tappingButton = value,
            }
          }
        );

        break;
      }

      case GameState.playing: {
        // Check which button is tap down
        _buttons[GameState.playing]!.forEach(
          (key, value) => {
            if(value.isOnButton(x, y)) {
              print("GameState.playing ${key} button tap down"), //debug
              value.tapDown(),
              _tappingButton = value,
            }
          }
        );

        break;
      }

      case GameState.pause: {
        // Check which button is tap down
        _buttons[GameState.pause]!.forEach(
          (key, value) => {
            if(value.isOnButton(x, y)) {
              print("GameState.pause ${key} button tap down"), //debug
              value.tapDown(),
              _tappingButton = value,
            }
          }
        );

        break;
      }

      case GameState.gameOver: {
        // Check which button is tap down
        _buttons[GameState.gameOver]!.forEach(
          (key, value) => {
            if(value.isOnButton(x, y)) {
              print("GameState.gameOver ${key} button tap down"), //debug
              value.tapDown(),
              _tappingButton = value,
            }
          }
        );

        break;
      }
    }
  }

  /****************************************************************************************************
   * Override from TapDetector. (flame/lib/src/gestures/detectors.dart)
   * Triggered when the user tap up on the screen.
   ****************************************************************************************************/
  @override
  void onTapUp(TapUpInfo info) {
    final x = _toRelativeWidth(info.eventPosition.game.x);
    final y = _toRelativeHeight(info.eventPosition.game.y);
//     print('Tap up on (${x}, ${y})'); //debug

    final _tappingButton = this._tappingButton;
    if(_tappingButton != null) {
      _tappingButton.tapUp();

      switch(_gameState) {
        case GameState.begin: {
          String buttonName = "";
          _buttons[GameState.begin]!.forEach(
            (key, value) => {
              if(value == _tappingButton) {
                buttonName = key,
              },
            },
          );
          print("GameState.begin ${buttonName} button has been tapped");

          // start button clicked
          if(buttonName == "start") {
            _startGame();
          }

          break;
        }

        case GameState.playing: {

          break;
        }

        case GameState.pause: {

          break;
        }

        case GameState.gameOver: {

          break;
        }
      }

      this._tappingButton = null;
    }
  }

  /****************************************************************************************************
   * Override from TapDetector. (flame/lib/src/gestures/detectors.dart)
   * Triggered when the user tap down on the screen.
   ****************************************************************************************************/
  @override
  void onTapCancel() {
//     print('Tap cancelled'); //debug
    final _tappingButton = this._tappingButton;
    if(_tappingButton != null) {
      _tappingButton.tapUp();
      this._tappingButton = null;
    }
  }

  /****************************************************************************************************
   * Override from Loadable. (flame/lib/src/game/mixins/loadable.dart)
   * Load recources like image, audio, etc.
   ****************************************************************************************************/
  @override
  Future<void>? onLoad() {
//     cookieImage = await Flame.images.load('cookie0.png');
    // Load button in start page
    // start button
    final beginPage = _buttons[GameState.begin]!;
    _buttons[GameState.begin]!['start'] = Button()
                                                ..offset = Offset(20, 80)
                                                ..size = Size(60, 15)
                                                ..color = Color(0xFF66FF99)
                                                ..downSize = Size(60 * 0.95, 15 * 0.95)
                                                ..downColor = Color(0xFF66FF66);

    // setting button
    _buttons[GameState.begin]!['setting'] = Button()
                                                ..offset = Offset(20, 62.5)
                                                ..size = Size(25, 12.5)
                                                ..color = Color(0XFF9999FF)
                                                ..downSize = Size(25 * 0.9, 12.5 * 0.9)
                                                ..downColor = Color(0XFF6666FF);

    // history button
    _buttons[GameState.begin]!['history'] = Button()
                                                ..offset = Offset(55, 62.5)
                                                ..size = Size(25, 12.5)
                                                ..color = Color(0xFFCC69EB)
                                                ..downSize = Size(25 * 0.9, 12.5 * 0.9)
                                                ..downColor = Color(0xFFAB69D0);
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
   * Convert real height on the screen to percentage height (0.0 ~ 100.0).
   ****************************************************************************************************/
  double _toRelativeHeight(double absoluteHeight) {
    final _screenSize = this._screenSize;
    if(_screenSize == null) {
      return 0;
    }

    return absoluteHeight / _screenSize.height * 100.0;
  }

  /****************************************************************************************************
   * Convert real width on the screen to percentage width (0.0 ~ 100.0).
   ****************************************************************************************************/
  double _toRelativeWidth(double absoluteWidth) {
    final _screenSize = this._screenSize;
    if(_screenSize == null) {
      return 0;
    }

    return absoluteWidth / _screenSize.width * 100.0;
  }

  /****************************************************************************************************
   * Render the game begin screen, used in render(canvas).
   ****************************************************************************************************/
  void renderBeginScreen(Canvas canvas) {
    // Draw background
    final _screenSize = this._screenSize;
    if(_screenSize == null) {
      return;
    }
    canvas.drawRect(
      Rect.fromLTWH(0, 0, _screenSize.width, _screenSize.height),
      Paint()
        ..color = Color(0xFFFFFF66),
    );

    // Draw all button
    _buttons[GameState.begin]!.forEach(
      (key, value) => value.drawOnCanvas(canvas, _screenSize)
    );
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
          ..color = Colors.orange,
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
          ..color = Colors.orange,
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
          ..color = Colors.orange,
      );
    }
  }
}
