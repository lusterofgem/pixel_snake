import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/flame.dart';
import 'game/game_state.dart';
import 'game/direction.dart';
import 'ui/button.dart';
import 'ui/animations.dart';

import 'game/snake_game.dart';

class PixelSnake with Loadable, Game, TapDetector, KeyboardEvents{
  /****************************************************************************************************
   * Settings
   ****************************************************************************************************/
  // How many block units in the map.
//   Size mapSize = Size(10, 10);
  // The snake game
  SnakeGame snakeGame = SnakeGame(30,30);

  /****************************************************************************************************
   * Variables
   ****************************************************************************************************/

  // Screen size, update in onGameResize(Size).
  Size? _screenSize;

  // Running state of the game.
  GameState gameState = GameState.begin;
//   GameState gameState = GameState.playing; //debug!!

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

  // Map of Map of BaseAnimation, example: _animations['start']
  // The first layer of this map will auto generate using the GameState enumeration,
  // but the second layer need to be set up in onLoad().
  Map<GameState, Map<String, BaseAnimation>> _animations = Map.fromIterable(
    GameState.values,
    key: (value) => value,
    value: (value) => Map(),
  );

  // The current playing animation name.
//   String? _playingAnimationName;
  // The current playing animation
  BaseAnimation? _playingAnimation;

  // How many time do snake forward once
  static const double snakeForwardTime = 0.1;
  // The timer to check if
  double snakeForwardTimer = 0;

  /****************************************************************************************************
   * Override from TapDetector. (flame/lib/src/gestures/detectors.dart)
   * Triggered when the user tap down on the screen.
   ****************************************************************************************************/
  @override
  void onTapDown(TapDownInfo info) {
    // If animation is playing, ignore tap down event
    if(_playingAnimation != null) {
      return;
    }

    final x = _toRelativeWidth(info.eventPosition.game.x);
    final y = _toRelativeHeight(info.eventPosition.game.y);
//     print('Tap down on (${x}, ${y})'); //debug

    // Check if click position is on button
    _buttons[gameState]!.forEach(
      (key, value) => {
        if(value.isOnButton(x, y)) {
          print('${key} button tap down'), //debug
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

    final tappingButton = _buttons[gameState]![_tappingButtonName];
    if(tappingButton != null) {
      print('${_tappingButtonName} button tapped'); //debug

      // Set the playing animation name to tapping button name if the animation exist.
      // For example: begin screen "start" button click, playing animation will be set to "start",
      // it will not conflict with gameOver screen "start" button because the game state is different.
      final animationName = _tappingButtonName;
      final playingAnimation = _animations[gameState]![animationName];
      if(playingAnimation != null) {
        _playingAnimation = playingAnimation;
      }

      // Reset the tapping button
      tappingButton.tapUp();
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
    final tappingButton = _buttons[gameState]![_tappingButtonName];
    if(tappingButton != null) {
      tappingButton.tapUp();
      _tappingButtonName = null;
    }
  }

  /****************************************************************************************************
   * Override from KeyBoardEvents. (flame/lib/src/game/mixins/keyboard.dart)
   * Triggered when the user input from keyboard.
   ****************************************************************************************************/
  @override
  KeyEventResult onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    // The playing animation will block any key event
    if(_playingAnimation != null) {
      return KeyEventResult.ignored;
    }

    if(event is RawKeyDownEvent) {
      // If game is playing
      if(gameState == GameState.playing) {
        // Snake turn north
        if(keysPressed.contains(LogicalKeyboardKey.keyW) || keysPressed.contains(LogicalKeyboardKey.arrowUp)) {
          snakeGame.turnSnake(Direction.north);
        }
        // Snake turn east
        if(keysPressed.contains(LogicalKeyboardKey.keyD) || keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
          snakeGame.turnSnake(Direction.east);
        }
        // Snake turn south
        if(keysPressed.contains(LogicalKeyboardKey.keyS) || keysPressed.contains(LogicalKeyboardKey.arrowDown)) {
          snakeGame.turnSnake(Direction.south);
        }
        // Snake turn west
        if(keysPressed.contains(LogicalKeyboardKey.keyA) || keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
          snakeGame.turnSnake(Direction.west);
        }
        if(keysPressed.contains(LogicalKeyboardKey.space)) {
          _playingAnimation = _animations[gameState]!["pause"];
        }
      }
      // If game is pause
      else if(gameState == GameState.pause) {
        // Unpause the game
        if(keysPressed.contains(LogicalKeyboardKey.space)) {
          _playingAnimation = _animations[gameState]!["back"];
        }
      }

      return KeyEventResult.handled;
    }

    // The key is not handled
    return KeyEventResult.ignored;
  }

  /****************************************************************************************************
   * Override from Loadable. (flame/lib/src/game/mixins/loadable.dart)
   * Load recources like image, audio, etc.
   ****************************************************************************************************/
  @override
  Future<void>? onLoad() async {
    await snakeGame.loadResource();

    // start button
    _buttons[GameState.begin]!['start'] = Button()
                                                ..center = Offset(50, 87.5)
                                                ..size = Size(60, 15)
                                                ..color = Color(0xFF66FF99)
                                                ..downColor = Color(0xFF52EB85);
//                                                 ..image = Flame.images.load('play.png'); //HERE

    // setting button
    _buttons[GameState.begin]!['setting'] = Button()
                                                ..center = Offset(32.5, 68.75)
                                                ..size = Size(25, 12.5)
                                                ..color = Color(0XFF9999FF)
                                                ..downColor = Color(0XFF7B7BE1);

    // history button
    _buttons[GameState.begin]!['history'] = Button()
                                                ..center = Offset(67.5, 68.75)
                                                ..size = Size(25, 12.5)
                                                ..color = Color(0xFFCC69EB)
                                                ..downColor = Color(0xFFAB69D0);

    // Load buttons in setting page
    // back button
    _buttons[GameState.setting]!['back'] = Button()
                                                ..center = Offset(12.5, 8.75)
                                                ..size = Size(15, 7.5)
                                                ..color = Color(0xFFFFFF66)
                                                ..downColor = Color(0xFFE1E148);

    // Load buttons in history page
    // back button
    _buttons[GameState.history]!['back'] = Button()
                                                ..center = Offset(12.5, 8.75)
                                                ..size = Size(15, 7.5)
                                                ..color = Color(0xFFFFFF66)
                                                ..downColor = Color(0xFFE1E148);

    // Load buttons in playing page
    _buttons[GameState.playing]!['pause'] = Button()
                                                 ..center = Offset(6, 5)
                                                 ..size = Size(10, 7)
                                                 ..color = Color(0xFFEEFF77)
                                                 ..downColor = Color(0xFFD0E159);
    // Load buttons in pause page
    _buttons[GameState.pause]!['back'] = Button()
                                              ..center = Offset(81, 15)
                                              ..size = Size(10, 7)
                                              ..color = Color(0xFFFFC481)
                                              ..downColor = Color(0xFFE1A663);

    // Load animations in begin page
    // start animation
    _animations[GameState.begin]!['start'] = BeginStartAnimation();
    await _animations[GameState.begin]!['start']!.loadResource();
    // setting animation
    _animations[GameState.begin]!['setting'] = BeginSettingAnimation();
    // history animation
    _animations[GameState.begin]!['history'] = BeginHistoryAnimation();

    // Load animations in setting page
    // back animation
    _animations[GameState.setting]!['back'] = SettingBackAnimation();

    // Load animations in history page
    // back animation
    _animations[GameState.history]!['back'] = HistoryBackAnimation();

    // Load animations in playing page
    // pause animation
    _animations[GameState.playing]!['pause'] = PlayingPauseAnimation();
    _animations[GameState.playing]!['gameOver'] = PlayingGameOverAnimation();

    // Load animations in pause page
    _animations[GameState.pause]!['back'] = PauseBackAnimation();
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
    switch(gameState) {
      // The screen before game start
      case GameState.begin: {
        _renderBeginScreen(canvas);

        break;
      }

      // The setting screen (begin -> setting)
      case GameState.setting: {
        _renderSettingScreen(canvas);

        break;
      }

      // The history score screen (begin -> history)
      case GameState.history: {
        _renderHistoryScreen(canvas);

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

    // Render top animation if there have playing animation.
    _renderAnimation(canvas);
  }

  /****************************************************************************************************
   * Override from Game. (flame/lib/src/game/mixins/game.dart)
   * Triggered 60 times/s (0.016666 s/time) when it is not lagged.
   ****************************************************************************************************/
  @override
  void update(double updateTime) {
    // Update animation (and maybe change game state)
    final playingAnimation = _playingAnimation;
    if(playingAnimation != null) {
      // If it is the frame to change game state, change to the target game state. (define in animation class)
      if(playingAnimation.isStateChangingFrame()) {
        final targetGameState = playingAnimation.getTargetGameState();
        if(targetGameState != null) {
          gameState = targetGameState;
        }
      }

      // Update animation frame
      if(playingAnimation.haveNextFrame()) {
        playingAnimation.toNextFrame();
      } else {
        playingAnimation.reset();
        _playingAnimation = null;
      }

      // Update animation will blocking anything else.
      return;
    }

    // If the game status is playing, run game
    if(gameState == GameState.playing) {
      // Update timer
      snakeForwardTimer += updateTime;
      // If hit timer
      if(snakeForwardTimer >= snakeForwardTime) {
        // Reset timer
        snakeForwardTimer = 0;
        // forward snake
        if(snakeGame.canForwardSnake()) {
          snakeGame.forwardSnake();
        }
        // game over
        else {
          _playingAnimation = _animations[gameState]!["gameOver"];
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

    // Render background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, _screenSize.width, _screenSize.height),
      Paint()
        ..color = Color(0xFFFFFF66),
    );

    // Render all button
    _buttons[GameState.begin]!.forEach(
      (key, value) => value.renderOnCanvas(canvas, _screenSize)
    );
  }

  /****************************************************************************************************
   * Render the setting screen, used in render(canvas).
   * If there are no screen size set, return directly.
   ****************************************************************************************************/
  void _renderSettingScreen(Canvas canvas) {
    // If there are no screen size set, return directly.
    final _screenSize = this._screenSize;
    if(_screenSize == null) {
      return;
    }

    // Render background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, _screenSize.width, _screenSize.height),
      Paint()
        ..color = Color(0XFF9999FF),
    );

    // Render all button
    _buttons[GameState.setting]!.forEach(
      (key, value) => value.renderOnCanvas(canvas, _screenSize)
    );
  }

  /****************************************************************************************************
   * Render the game begin screen, used in render(canvas).
   * If there are no screen size set, return directly.
   ****************************************************************************************************/
  void _renderHistoryScreen(Canvas canvas) {
    // If there are no screen size set, return directly.
    final _screenSize = this._screenSize;
    if(_screenSize == null) {
      return;
    }

    // Render background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, _screenSize.width, _screenSize.height),
      Paint()
        ..color = Color(0xFFCC69EB),
    );

    // Render all button
    _buttons[GameState.history]!.forEach(
      (key, value) => value.renderOnCanvas(canvas, _screenSize)
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

    // Render background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, _screenSize.width, _screenSize.height),
      Paint()
        ..color = Color(0xFF66FF99),
    );

    // Render snake game area
    snakeGame.renderOnCanvas(canvas, _screenSize);

    // Render all button
    _buttons[GameState.playing]!.forEach(
      (key, value) => value.renderOnCanvas(canvas, _screenSize)
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

    // Render background
    canvas.drawRect(
      Rect.fromCenter(center: Offset(_screenSize.width * 0.5, _screenSize.height * 0.5),
                      width: _screenSize.width * 0.8,
                      height: _screenSize.height * 0.8),
      Paint()
        ..color = Color(0xAAEEFF77),
    );

    // Render all button
    _buttons[GameState.pause]!.forEach(
      (key, value) => value.renderOnCanvas(canvas, _screenSize)
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

    // Render background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, _screenSize.width, _screenSize.height),
      Paint()
        ..color = Colors.orange,
    );

    // Render all button
    _buttons[GameState.gameOver]!.forEach(
      (key, value) => value.renderOnCanvas(canvas, _screenSize)
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
    final playingAnimation = _playingAnimation;
    if(playingAnimation == null) {
      return;
    }

    // Render animation
    playingAnimation.renderOnCanvas(canvas, _screenSize);
  }
}
