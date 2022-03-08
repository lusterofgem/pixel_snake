import 'package:flutter/material.dart';
import '../base_animation.dart';

class SettingBackAnimation extends BaseAnimation {
  // The start center position of the full screen animation
  Offset startCenter = const Offset(12.5, 8.75);
  // The end center position of the full screen animation
  Offset endCenter = const Offset(50, 50);

  // The start size of the to full screen animation
  Size startSize = const Size(15, 7.5);
  // The end size of the to full screen animation
  Size endSize = const Size(100, 100);

  // The start color of the animation
  Color startColor = const Color(0xFFFFFF66);
  // The end color of the animation
  Color endColor = const Color(0xFFE1E148);

  /// Constructor
  SettingBackAnimation() {
    animationLength = 30;
    stateChangingFrame = 9;
    targetGameState = GameState.begin;
  }

  /// Draw this animation on the given canvas.
  /// Screen size have to be set in this function,
  /// need the size of the screen to draw the animation size correctly.
  @override
  void drawOnCanvas(Canvas canvas, Size screenSize) {
    this.screenSize = screenSize;

    // Draw animation
    if(frameIndex < animationLength) {
      final currentCenter = getCurrentCenter();
      final currentSize = getCurrentSize();
      final currentColor = getCurrentColor();
      canvas.drawRect(
        Rect.fromCenter(center: Offset(toAbsoluteWidth(currentCenter.dx), toAbsoluteHeight(currentCenter.dy)),
                        width: toAbsoluteWidth(currentSize.width),
                        height: toAbsoluteHeight(currentSize.height)),
        Paint()
          ..color = currentColor,
      );
    }
    // Warning when the frame index is invalid but this function is called
    else {
      debugPrint("Warning: SettingBackAnimation::renderOnCanvas(Canvas, Size) called, but the frameIndex: $frameIndex is invalid.");
    }
  }

  /// **************************************************************************************************
  /// Calculate current Size.
  /// The range is from startCenter to endCenter.
  ///***************************************************************************************************/
  Offset getCurrentCenter() {
    Offset currentCenter = const Offset(0, 0);

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

    return currentCenter;
  }

  /// **************************************************************************************************
  /// Calculate current Size.
  /// The range is from startSize to endSize.
  ///***************************************************************************************************/
  Size getCurrentSize() {
    Size currentSize = const Size(0, 0);

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

    return currentSize;
  }

  /// **************************************************************************************************
  /// Calculate current color.
  /// The range is from startColor to endColor.
  ///***************************************************************************************************/
  Color getCurrentColor() {
    Color currentColor = const Color(0x00000000);

    if(frameIndex <= stateChangingFrame) {
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

    return currentColor;
  }
}
