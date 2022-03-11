import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart';
export 'package:vector_math/vector_math_64.dart';

import '../../../game/game_state.dart';
export '../../../game/game_state.dart';


class BaseAnimation {
  // The animation length
  int animationLength = 0;
  // Which frame should the game state be change.
  // If the value is less than 0 or bigger than animationLength, it will never change game state.
  int stateChangingFrame = -1;
  // Change to which game state when it is the frame to changing state.
  GameState? targetGameState;

  // The current frame of this animation
  int frameIndex = 0;


  /// Draw this animation on the given canvas.
  /// Screen size have to be set in this function,
  /// need the size of the screen to draw the animation size correctly.
  void drawOnCanvas(Canvas canvas, {required Vector2 screenSize}) {

  }

  /// If this animation have next frame to draw.
  bool haveNextFrame() {
    return frameIndex < (animationLength - 1);
  }

  /// Change this animation to next frame.
  /// If there are no more frame, directly return false.
  bool toNextFrame() {
    // No more frame
    if(haveNextFrame()) {
      frameIndex ++;
      return true;
    }

    return false;
  }

  /// Reset this button animation.
  void reset() {
    frameIndex = 0;
  }

  /// If the current frame is game state changing frame.
  bool isStateChangingFrame() {
    return frameIndex == stateChangingFrame;
  }

  /// Get the game state to change.
  GameState? getTargetGameState() {
    return targetGameState;
  }

  /// Load resource.
  /// If the animation have resource, it should be loaded before the animation play.
  Future<void>? loadResource() => null;

  /// Convert percentage x (0.0 ~ 100.0) to absolute x.
  @protected
  double toAbsoluteX(double relativeX, {required Vector2 screenSize}) {
    return screenSize.x * relativeX / 100.0;
  }

  /// Convert percentage y (0.0 ~ 100.0) to absolute y.
  @protected
  double toAbsoluteY(double relativeY, {required Vector2 screenSize}) {
    return screenSize.y * relativeY / 100.0;
  }
}
