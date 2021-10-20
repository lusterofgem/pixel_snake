import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'game_state.dart';
import 'animation_type.dart';
import 'animated_button.dart';

class PixelSnake with Loadable, Game, TapDetector {
  /****************************************************************************************************
   * Settings
   ****************************************************************************************************/
  // How many block in the map, init when the game is start.
  Vector2 mapSize = Vector2(10, 10);

  /****************************************************************************************************
   * Variables
   ****************************************************************************************************/
  // Screen size, update in onGameResize(Vector2).
  Vector2? _size;

  // Running state of the game.
  GameState _gameState = GameState.begin;

  // Store type of running animation.
  AnimationType _animationState = AnimationType.none;

  // Store frame index of running animation.
  int _animationFrame = 0;

  // Store button animation frame of button array of each game state.
//   List<List<AnimatedButton>> _animatedButtons = List.filled(GameState.values.length, []);

  Map<GameState, List<AnimatedButton>> _animatedButtonsMap = Map.fromIterable(
    GameState.values,
    key: (value) => value,
    value: (value) => [],
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
    List<AnimatedButton> animatedButtons = _animatedButtonsMap[GameState.begin] ??= [];
//     if(animatedButtons!=null) {
//       animatedButtons.add(AnimatedButton()); //debug
//     }
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
//         print("render(Canvas) GameState.begin"); //debug

        // Draw background
        // Type promotion Vector2? to Vector
        final _size = this._size;
        if(_size != null) {
          canvas.drawRect(
            Rect.fromLTWH(0, 0, _size.x, _size.y),
            Paint()
              ..color = Colors.green,
          );
        }

        // Draw all buttons
        List<AnimatedButton> animatedButtons = _animatedButtonsMap[GameState.begin] ??= [];
        for(AnimatedButton animatedButton in animatedButtons) {
          print(animatedButton); //debug
        }

        break;
      }

      // The screen when the game is running
      case GameState.running: {
//         print("render(Canvas) GameState.running"); //debug

        // Draw background
        // Type promotion Vector2? to Vector
        final _size = this._size;
        if(_size != null) {
          canvas.drawRect(
            Rect.fromLTWH(0, 0, _size.x, _size.y),
            Paint()
              ..color = Colors.green,
          );
        }

        //Draw all buttons
        List<AnimatedButton> animatedButtons = _animatedButtonsMap[GameState.running] ??= [];
        for(AnimatedButton animatedButton in animatedButtons) {
          print(animatedButton); //debug
        }

        break;
      }

      // The screen when the game is pause
      case GameState.pause: {
//         print("render(Canvas) GameState.pause"); //debug

        // Draw background
        // Type promotion Vector2? to Vector
        final _size = this._size;
        if(_size != null) {
          canvas.drawRect(
            Rect.fromLTWH(0, 0, _size.x, _size.y),
            Paint()
              ..color = Colors.green,
          );
        }

        // Draw all buttons
        List<AnimatedButton> animatedButtons = _animatedButtonsMap[GameState.pause] ??= [];
        for(AnimatedButton animatedButton in animatedButtons) {
          print(animatedButton); //debug
        }

        break;
      }

      // The screen when the game over
      case GameState.gameOver: {
//         print("render(Canvas) GameState.gameOver"); //debug

        // Draw background
        // Type promotion Vector2? to Vector
        final _size = this._size;
        if(_size != null) {
          canvas.drawRect(
            Rect.fromLTWH(0, 0, _size.x, _size.y),
            Paint()
              ..color = Colors.green,
          );
        }

        // Draw all buttons
        List<AnimatedButton> animatedButtons = _animatedButtonsMap[GameState.gameOver] ??=[];
        for(AnimatedButton animatedButton in animatedButtons) {
          print(animatedButton); //debug
        }


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
    _size = size;
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
}
