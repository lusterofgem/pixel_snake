import 'package:flutter/material.dart';
import '../game_state.dart';

class BaseAnimation {
  /****************************************************************************************************
   * Setting
   ****************************************************************************************************/
  // The animation length
  int animationLength = 0;
  // Which frame should the game state be switch. (-1 for never switch game state)
  int stateSwitchingFrame = -1;
  // Switch to which game state when it is the frame to switching state.
  GameState? targetGameState;

  /****************************************************************************************************
   * Variable
   ****************************************************************************************************/
  // The screen size of the game
  Size? screenSize;
  // The current frame of this animation
  int frameIndex = 0;


  /****************************************************************************************************
   * Draw this animation on the given canvas.
   * Screen size have to be set in this function,
   * need the size of the screen to draw the animation size correctly.
   ****************************************************************************************************/
  void drawOnCanvas(Canvas canvas, Size screenSize) {
    this.screenSize = screenSize;


  }

  /****************************************************************************************************
   * If this animation have next frame to draw.
   ****************************************************************************************************/
  bool haveNextFrame() {
    return frameIndex < animationLength - 1;
  }

  /****************************************************************************************************
   * Change this animation to next frame.
   * If there are no more frame, directly return false.
   ****************************************************************************************************/
  bool toNextFrame() {
    // No more frame
    if(!haveNextFrame()) {
      return false;
    }
    frameIndex ++;

    return true;
  }

  /****************************************************************************************************
   * Reset this button animation.
   ****************************************************************************************************/
  void reset() {
    frameIndex = 0;
  }

  /****************************************************************************************************
   * If the current frame is game state switch frame.
   ****************************************************************************************************/
  bool isStateSwitchingFrame() {
    return frameIndex == stateSwitchingFrame;
  }

  /****************************************************************************************************
   * Get the game state to switch.
   ****************************************************************************************************/
  GameState? getTargetGameState() {
    return targetGameState;
  }

  /****************************************************************************************************
   * Convert percentage width (0.0 ~ 100.0) to real real width on the screen.
   * Warning: screenSize need to be set before this function being invoked.
   ****************************************************************************************************/
  double _toAbsoluteWidth(double relativeWidth) {
    final screenSize = this.screenSize;
    if(screenSize == null) {
      print("Error: screenSize need to be set before _toAbsoluteWidth(double relativeWidth) being invoked.");
      return 0;
    }

    return screenSize.width * relativeWidth / 100.0;
  }

  /****************************************************************************************************
   * Convert percentage height (0.0 ~ 100.0) to real height on the screen.
   * Warning: screenSize need to be set before this function being invoked.
   ****************************************************************************************************/
  double _toAbsoluteHeight(double relativeHeight) {
    final screenSize = this.screenSize;
    if(screenSize == null) {
      print("Error: screenSize need to be set before _toAbsoluteHeight(double relativeHeight) being invoked.");
      return 0;
    }

    return screenSize.height * relativeHeight / 100.0;
  }
}
