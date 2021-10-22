import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'game_state.dart';
import 'animation_type.dart';
import 'button.dart';
import 'animations.dart';

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

  // Map of Map of Button, example: _buttons[GameState.begin]['start']
  // The first layer of this map will auto generate using the GameState enumeration,
  // but the second layer need to be set up in onLoad().
  Map<GameState, Map<String, Button>> _buttons = Map.fromIterable(
    GameState.values,
    key: (value) => value,
    value: (value) => Map(),
  );

  // The current tapping button name
  String? _tappingButtonName;

  // Map of Map of BaseAnimation, example: _animations["start"]
  // The first layer of this map will auto generate using the GameState enumeration,
  // but the second layer need to be set up in onLoad().
  Map<GameState, Map<String, BaseAnimation>> _animations = Map.fromIterable(
    GameState.values,
    key: (value) => value,
    value: (value) => Map(),
  );

  // The current playing animation name.
  String? _playingAnimationName;

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
    // If animation is playing, ignore tap down event
    if(_playingAnimationName != null) {
      return;
    }

    final x = _toRelativeWidth(info.eventPosition.game.x);
    final y = _toRelativeHeight(info.eventPosition.game.y);
//     print('Tap down on (${x}, ${y})'); //debug

    // Check if click position is on button
    _buttons[_gameState]!.forEach(
      (key, value) => {
        if(value.isOnButton(x, y)) {
          print("${key} button tap down"), //debug
          value.tapDown(),
          _tappingButtonName = key,
        }
      }
    );
  }

  /****************************************************************************************************
   * Override from TapDetector. (flame/lib/src/gestures/detectors.dart)
   * Triggered when the user tap up on the screen.
   * Tap up on button is considered as successful button click.
   ****************************************************************************************************/
  @override
  void onTapUp(TapUpInfo info) {
    final x = _toRelativeWidth(info.eventPosition.game.x);
    final y = _toRelativeHeight(info.eventPosition.game.y);
//     print('Tap up on (${x}, ${y})'); //debug

    final tappingButton = _buttons[_gameState]![_tappingButtonName];
    if(tappingButton != null) {
      tappingButton.tapUp();

      print("${_tappingButtonName} button tapped"); //debug

      // Set the playing animation name to tapping button name if the animation exist.
      // For example: begin screen "start" button click, playing animation will be set to "start",
      // it will not conflict with gameOver screen "start" button because the game state is different.
      final animationName = _tappingButtonName;
      if(_animations[_gameState]![animationName] != null) {
        _playingAnimationName = animationName;
      }

      _tappingButtonName = null;
    }
  }

  /****************************************************************************************************
   * Override from TapDetector. (flame/lib/src/gestures/detectors.dart)
   * Triggered when the user tap down on the screen.
   ****************************************************************************************************/
  @override
  void onTapCancel() {
//     print('Tap cancelled'); //debug
    final tappingButton = _buttons[_gameState]![_tappingButtonName];
    if(tappingButton != null) {
      tappingButton.tapUp();
      _tappingButtonName = null;
    }
  }

  /****************************************************************************************************
   * Override from Loadable. (flame/lib/src/game/mixins/loadable.dart)
   * Load recources like image, audio, etc.
   ****************************************************************************************************/
  @override
  Future<void>? onLoad() {
//     cookieImage = await Flame.images.load('cookie0.png');
    // Load animation in start page
    // start animations
    _animations[GameState.begin]!["start"] = BeginStartAnimation();

    // Load buttons in start page
    // start button
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

    //
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
        _renderBeginScreen(canvas);
        _renderAnimation(canvas);

        break;
      }

      // The screen when the game is playing
      case GameState.playing: {
        _renderPlayingScreen(canvas);

        break;
      }

      // The screen when the game is pause
      case GameState.pause: {
        _renderPlayingScreen(canvas);
        _renderPauseMenu(canvas);

        break;
      }

      // The screen when the game over
      case GameState.gameOver: {
        _renderGameOverScreen(canvas);

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


    // Update animation
    if(_playingAnimationName != null) {
      var playingAnimation = _animations[_gameState]![_playingAnimationName];
      if(playingAnimation != null) {
        // If it is the frame to change game state, change to the target game state. (define in animation class)
        if(playingAnimation.isStateChangingFrame()) {
          final targetGameState = playingAnimation.getTargetGameState();
          if(targetGameState != null) {
            _gameState = targetGameState;
          }
        }

        // Update animation frame
        if(playingAnimation.haveNextFrame()) {
          playingAnimation.toNextFrame();
        } else {
          playingAnimation.reset();
          _playingAnimationName = null;
        }
      }
    }
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
   * Start game, let's play!
   ****************************************************************************************************/
  void _startGame() {
    _playingAnimationName = "startGame";
  }

  /****************************************************************************************************
   * Pause the game.
   ****************************************************************************************************/
  void _pauseGame() {
    _playingAnimationName = "pauseGame";
  }

  /****************************************************************************************************
   * Unpause the game.
   ****************************************************************************************************/
  void _unpauseGame() {
    _playingAnimationName = "unpauseGame";
  }

  /****************************************************************************************************
   * End game, game over!
   ****************************************************************************************************/
  void _gameOver() {
    _playingAnimationName = "gameOver";
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
   * If there are no screen size set, return directly.
   ****************************************************************************************************/
  void _renderBeginScreen(Canvas canvas) {
    // If there are no screen size set, return directly.
    final _screenSize = this._screenSize;
    if(_screenSize == null) {
      return;
    }

    // Draw background
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
   * If there are no screen size set, return directly.
   ****************************************************************************************************/
  void _renderPlayingScreen(Canvas canvas) {
    // If there are no screen size set, return directly.
    final _screenSize = this._screenSize;
    if(_screenSize == null) {
      return;
    }

    // Draw background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, _screenSize.width, _screenSize.height),
      Paint()
        ..color = Colors.orange,
    );
  }

  /****************************************************************************************************
   * Render the game pause menu, used in render(canvas).
   * If there are no screen size set, return directly.
   ****************************************************************************************************/
  void _renderPauseMenu(Canvas canvas) {
    // If there are no screen size set, return directly.
    final _screenSize = this._screenSize;
    if(_screenSize == null) {
      return;
    }

    // Draw background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, _screenSize.width, _screenSize.height),
      Paint()
        ..color = Colors.orange,
    );
  }

  /****************************************************************************************************
   * Render the game over screen, used in render(canvas).
   * If there are no screen size set, return directly.
   ****************************************************************************************************/
  void _renderGameOverScreen(Canvas canvas) {
    // If there are no screen size set, return directly.
    final _screenSize = this._screenSize;
    if(_screenSize == null) {
      return;
    }

    // Draw background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, _screenSize.width, _screenSize.height),
      Paint()
        ..color = Colors.orange,
    );
  }

  /****************************************************************************************************
   * Render the playing animation.
   * If there are no screen size set, return directly.
   * If there are no current playing animaton, return directly.
   ****************************************************************************************************/
  void _renderAnimation(Canvas canvas) {
    // If there are no screen size set, return directly.
    final _screenSize = this._screenSize;
    if(_screenSize == null) {
      return;
    }

    // If there are no current playing animaton, return directly.
    final playingAnimation = _animations[_gameState]![_playingAnimationName];
    if(playingAnimation == null) {
      return;
    }

    // Draw animation
    playingAnimation.drawOnCanvas(canvas, _screenSize);
  }
}
