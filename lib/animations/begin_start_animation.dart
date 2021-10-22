import 'package:flutter/material.dart';
import 'base_animation.dart';

class BeginStartAnimation extends BaseAnimation {
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
  Size? _screenSize;

  /****************************************************************************************************
   * Draw this animation on the given canvas.
   * Screen size have to be set in this function,
   * need the size of the screen to draw the animation size correctly.
   ****************************************************************************************************/
  @override
  void drawOnCanvas(Canvas canvas, Size screenSize) {
    _screenSize = screenSize;


  }
}
