import 'package:flutter/material.dart';
import '../base_animation.dart';

class BeginStartAnimation extends BaseAnimation {
  /****************************************************************************************************
   * Setting
   ****************************************************************************************************/
  // The animation length
  int animationLength = 10;
  // Which frame should the game state be switch.
  // If the value is less than 0 or bigger than animationLength - 1, it will never change game state.
  int stateChangingFrame = 9;
  // Changing to which game state when it is the frame to switching state.
  GameState? targetGameState = GameState.playing;
  // The start center position of the full screen animation
  Offset startCenter = Offset(50, 87.5);
  // The start size of the to full screen animation
  Size startSize = Size(60, 15);
  // The end size of the to full screen animation
  Size endSize = Size(100, 100);

  /****************************************************************************************************
   * Draw this animation on the given canvas.
   * Screen size have to be set in this function,
   * need the size of the screen to draw the animation size correctly.
   ****************************************************************************************************/
  @override
  void drawOnCanvas(Canvas canvas, Size screenSize) {
    this.screenSize = screenSize;

    // draw
    final currentRect = getCurrentRect();
    canvas.drawRect(
      Rect.fromCenter(center: Offset(_toAbsoluteWidth(currentRect.left), _toAbsoluteHeight(currentRect.top)),
                      width: _toAbsoluteWidth(currentRect.width),
                      height: _toAbsoluteHeight(currentRect.height)),
      Paint()
        ..color = Color(0xFF66FF99),
    );
  }

  /****************************************************************************************************
   * Calculate current animation square rect.
   * The size range is from startSize to endSize.
   ****************************************************************************************************/
  Rect getCurrentRect() {
    // The size change amount in each frame of the animation
    Offset eachFrameChangedSize = Offset(endSize.width - startSize.width, endSize.height - startSize.height) / stateChangingFrame.toDouble();
    // Calculate the current size
    Size currentSize = startSize + eachFrameChangedSize * frameIndex.toDouble();

    // The end center should at the center of the screen
    final endCenter = Offset(50, 50);
    // The center changed of each frame
    Offset eachFrameCenterOffset = (endCenter - startCenter) / stateChangingFrame.toDouble();
    // The current center point
    Offset currentCenter = startCenter + eachFrameCenterOffset * frameIndex.toDouble();

    print(currentCenter);

//     return Rect.fromLTWH(0, 0, currentSize.width, currentSize.height);
    return Rect.fromLTWH(currentCenter.dx, currentCenter.dy, currentSize.width, currentSize.height);
  }

  /****************************************************************************************************
   * Convert percentage width (0.0 ~ 100.0) to real real width on the game render area.
   * Warning: screenSize need to be set before this function being invoked.
   ****************************************************************************************************/
  double _toAbsoluteWidth(double relativeWidth) {
    final screenSize = this.screenSize;
    if(screenSize == null) {
      print("Error: screenSize need to be set before BeginStartAnimation::_toAbsoluteWidth(double relativeWidth) being invoked.");
      return 0;
    }

    return screenSize.width * relativeWidth / 100.0;
  }

  /****************************************************************************************************
   * Convert percentage height (0.0 ~ 100.0) to real height on the game render area.
   * Warning: screenSize need to be set before this function being invoked.
   ****************************************************************************************************/
  double _toAbsoluteHeight(double relativeHeight) {
    final screenSize = this.screenSize;
    if(screenSize == null) {
      print("Error: screenSize need to be set before BeginStartAnimation::_toAbsoluteHeight(double relativeHeight) being invoked.");
      return 0;
    }

    return screenSize.height * relativeHeight / 100.0;
  }
}
