import 'package:flutter/material.dart';
import 'base_animation.dart';
import '../game_state.dart';

class BeginStartAnimation extends BaseAnimation {
  /****************************************************************************************************
   * Setting
   ****************************************************************************************************/
  // The animation length
  int animationLength = 30;
  // Which frame should the game state be switch.
  // If the value is less than 0 or bigger than animationLength - 1, it will never change game state.
  int stateChangingFrame = 29;
  // Changing to which game state when it is the frame to switching state.
  GameState? targetGameState = GameState.playing;

  /****************************************************************************************************
   * Draw this animation on the given canvas.
   * Screen size have to be set in this function,
   * need the size of the screen to draw the animation size correctly.
   ****************************************************************************************************/
  @override
  void drawOnCanvas(Canvas canvas, Size screenSize) {
    this.screenSize = screenSize;


  }
}
