import 'package:flutter/material.dart';
import '../base_animation.dart';

class PlayingGameOverAnimation extends BaseAnimation {
  /****************************************************************************************************
   * Setting
   ****************************************************************************************************/
  // The animation length
  int animationLength = 30;
  // Which frame should the game state be switch.
  // If the value is less than 0 or bigger than animationLength - 1, it will never change game state.
  int stateChangingFrame = 0;
  // Changing to which game state when it is the frame to switching state.
  GameState? targetGameState = GameState.gameOver;

  // The start center position of the full screen animation
  Offset startCenter = Offset(50, 50);
  // The end center position of the full screen animation
  Offset endCenter = Offset(50, 50);

  // The start size of the to full screen animation
  Size startSize = Size(0, 0);
  // The end size of the to full screen animation
  Size endSize = Size(100, 100);

  // The start color of the animation
  Color startColor = Color(0xFFFFFF66);
  // The end color of the animation
  Color endColor = Color(0xFFE1E148);

  /****************************************************************************************************
   * Draw this animation on the given canvas.
   * Screen size have to be set in this function,
   * need the size of the screen to draw the animation size correctly.
   ****************************************************************************************************/
  @override
  void renderOnCanvas(Canvas canvas, Size screenSize) {
    this.screenSize = screenSize;
    // Draw animation
    if(frameIndex < animationLength) {
      final currentCenter = getCurrentCenter();
      final currentSize = getCurrentSize();
      final currentColor = getCurrentColor();
      canvas.drawRect(
        Rect.fromCenter(center: Offset(_toAbsoluteWidth(currentCenter.dx), _toAbsoluteHeight(currentCenter.dy)),
                        width: _toAbsoluteWidth(currentSize.width),
                        height: _toAbsoluteHeight(currentSize.height)),
        Paint()
          ..color = currentColor,
      );
    }
    // Warning when the frame index is invalid but this function is called
    else {
      print("Warning: PlayingGameOverAnimation::renderOnCanvas(Canvas, Size) called, but the frameIndex: ${frameIndex} is invalid.");
    }
print("PlayingGameOverAnimation::renderOnCanvas(Canvas, Size)"); //debug!!
  }

  /****************************************************************************************************
   * Calculate current Size.
   * The range is from startCenter to endCenter.
   ****************************************************************************************************/
  Offset getCurrentCenter() {
    Offset currentCenter = Offset(0, 0);

    if(frameIndex <= stateChangingFrame) {
      currentCenter = startCenter;

      // The center changed of each frame
      Offset eachFrameCenterOffset = (endCenter - startCenter) / stateChangingFrame.toDouble();
      // The current center point
      currentCenter += eachFrameCenterOffset * frameIndex.toDouble();
    }
    else if(frameIndex <= animationLength - 1) {
      currentCenter = endCenter;
    }
print("PlayingGameOverAnimation::getCurrentCenter()"); //debug!!
    return currentCenter;
  }

  /****************************************************************************************************
   * Calculate current Size.
   * The range is from startSize to endSize.
   ****************************************************************************************************/
  Size getCurrentSize() {
    Size currentSize = Size(0, 0);

    if(frameIndex <= stateChangingFrame) {
      currentSize = startSize;

      // The size change amount in each frame of the animation
      Offset eachFrameChangedSize = Offset(endSize.width - startSize.width, endSize.height - startSize.height) / stateChangingFrame.toDouble();
      // Calculate the current size
      currentSize += eachFrameChangedSize * frameIndex.toDouble();
    }
    else if(frameIndex <= animationLength - 1) {
      currentSize = endSize;
    }
print("PlayingGameOverAnimation::getCurrentSize()"); //debug!!
    return currentSize;
  }

  /****************************************************************************************************
   * Calculate current color.
   * The range is from startColor to endColor.
   ****************************************************************************************************/
  Color getCurrentColor() {
    Color currentColor = Color(0x00000000);

    if(frameIndex <= stateChangingFrame) {
print("before stateChangingFrame"); //debug!!
      // The color red value change amount in each frame of the animation
      double eachFrameChangedRed = (endColor.red - startColor.red) / stateChangingFrame.toDouble();
      // The color green value change amount in each frame of the animation
      double eachFrameChangedGreen = (endColor.green - startColor.green) / stateChangingFrame.toDouble();
      // The color blue value change amount in each frame of the animation
      double eachFrameChangedBlue = (endColor.blue - startColor.blue) / stateChangingFrame.toDouble();

      currentColor = Color.fromARGB(
        startColor.alpha,
        startColor.red + (eachFrameChangedRed * frameIndex).round(),
        startColor.green + (eachFrameChangedGreen * frameIndex).round(),
        startColor.blue + (eachFrameChangedBlue * frameIndex).round(),
      );
    }
    // Fade out
    else if(frameIndex <= animationLength - 1) {
print("fade out"); //debug!!
      const endAlpha = 0;
      // The color alpha value change amount in each frame of the animation
      double eachFrameChangedAlpha = (endAlpha - startColor.alpha) / (animationLength - 1 - stateChangingFrame).toDouble();

      currentColor = Color.fromARGB(
        endColor.alpha + (eachFrameChangedAlpha * (frameIndex - stateChangingFrame)).round(),
        endColor.red,
        endColor.green,
        endColor.blue,
      );
    }
print("PlayingGameOverAnimation::getCurrentColor()"); //debug!!
    return currentColor;
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
