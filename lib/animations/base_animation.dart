import 'package:flutter/material.dart';

class BaseAnimation {
  /****************************************************************************************************
   * Setting
   ****************************************************************************************************/
  // The animation length
  int _animationLength = 0;
  // Which frame should the game state be switch. (-1 for never switch game state)
  int _stateSwitchingFrame = -1;

  /****************************************************************************************************
   * Variable
   ****************************************************************************************************/
  // The screen size of the game
  Size? _screenSize;
  // The current frame of this animation
  int _frameIndex = 0;


  /****************************************************************************************************
   * Draw this animation on the given canvas.
   * Screen size have to be set in this function,
   * need the size of the screen to draw the animation size correctly.
   ****************************************************************************************************/
  void drawOnCanvas(Canvas canvas, Size screenSize) {
    this._screenSize = screenSize;

    // Draw
  }

  /****************************************************************************************************
   * If this animation have next frame to draw.
   ****************************************************************************************************/
  bool haveNextFrame() {
    return _frameIndex < _animationLength - 1;
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
    _frameIndex ++;

    return true;
  }

  /****************************************************************************************************
   * Reset this button animation.
   ****************************************************************************************************/
  void reset() {
    _frameIndex = 0;
  }

  /****************************************************************************************************
   * If the current frame is game state switch frame.
   ****************************************************************************************************/
  bool isStateSwitchingFrame() {
    return _frameIndex == _stateSwitchingFrame;
  }

  /****************************************************************************************************
   * Convert percentage width (0.0 ~ 100.0) to real real width on the screen.
   * Warning: _screenSize need to be set before this function being invoked.
   ****************************************************************************************************/
  double _toAbsoluteWidth(double relativeWidth) {
    final _screenSize = this._screenSize;
    if(_screenSize == null) {
      print("Error: _screenSize need to be set before _toAbsoluteWidth(double relativeWidth) being invoked.");
      return 0;
    }

    return _screenSize.width * relativeWidth / 100.0;
  }

  /****************************************************************************************************
   * Convert percentage height (0.0 ~ 100.0) to real height on the screen.
   * Warning: Screen size need to be set before this function being invoked.
   ****************************************************************************************************/
  double _toAbsoluteHeight(double relativeHeight) {
    final _screenSize = this._screenSize;
    if(_screenSize == null) {
      print("Error: _screenSize need to be set before _toAbsoluteHeight(double relativeHeight) being invoked.");
      return 0;
    }

    return _screenSize.height * relativeHeight / 100.0;
  }
}
