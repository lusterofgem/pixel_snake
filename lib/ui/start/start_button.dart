import 'dart:ui';

import 'package:flutter/material.dart';
import '../../widget/animated_button.dart';

class StartButton implements AnimatedButton {
  /****************************************************************************************************
   * Settings
   ****************************************************************************************************/
  // How many frames does this button animation have
  int _animationLength = 2;
  // Color of this button
  Color _color = Colors.yellow;
  // Offset of this button
  Offset _offset = Offset(20,80);
  // Size of this button
  Size _size = Size(60, 15);

  /****************************************************************************************************
   * Variable
   ****************************************************************************************************/
  // The current frame of this button
  int _frameIndex = 0;

  // The screen size of the game
  Size? _screenSize;
  /****************************************************************************************************
   * Draw this button on the given canvas
   * Need the size of the screen to draw the button size correctly
   ****************************************************************************************************/
  @override
  void drawOnCanvas(Canvas canvas, Size screenSize) {
    // Set the screen size before draw, needed by the _toRealWidth and _toRealHeight
    _screenSize = screenSize;

    switch(_frameIndex) {
      case 0: {
        canvas.drawRect(
          Rect.fromLTWH(_toRealWidth(_offset.dx), _toRealHeight(_offset.dy), _toRealWidth(_size.width), _toRealHeight(_size.height)),
          Paint()
            ..color = _color,
        );

        break;
      }
      case 1: {
        canvas.drawRect(
          Rect.fromLTWH(_toRealWidth(_offset.dx), _toRealHeight(_offset.dy), _toRealWidth(_size.width), _toRealHeight(_size.height)),
          Paint()
            ..color = _color,
        );

        break;
      }
    }
  }

  /****************************************************************************************************
   * If this button have next frame to draw
   ****************************************************************************************************/
  @override
  bool haveNextFrame() {
    return _frameIndex < _animationLength - 1;
  }

  /****************************************************************************************************
   * Change this button to next frame
   * If there are no more frame, directly return false
   ****************************************************************************************************/
  @override
  bool toNextFrame() {
    // No more frame
    if(!haveNextFrame()) {
      return false;
    }
    _frameIndex ++;

    return true;
  }

  /****************************************************************************************************
   * Reset this button animation
   ****************************************************************************************************/
  @override
  void reset() {
    _frameIndex = 0;
  }

  /****************************************************************************************************
   * Convert percentage width (0.0 ~ 100.0) to real real width on the screen.
   * Warning: _screenSize need to be set before this function being invoked.
   ****************************************************************************************************/
  double _toRealWidth(double percentageWidth) {
    final _screenSize = this._screenSize;
    if(_screenSize == null) {
      print("Error: _screenSize need to be set before this function being invoked.");
      return 0;
    }

    return _screenSize.width * percentageWidth / 100.0;
  }

  /****************************************************************************************************
   * Convert percentage height (0.0 ~ 100.0) to real height on the screen.
   * Warning: Screen size need to be set before this function being invoked.
   ****************************************************************************************************/
  double _toRealHeight(double percentageHeight) {
    final _screenSize = this._screenSize;
    if(_screenSize == null) {
      print("Error: _screenSize need to be set before this function being invoked.");
      return 0;
    }

    return _screenSize.height * percentageHeight / 100.0;
  }

}
