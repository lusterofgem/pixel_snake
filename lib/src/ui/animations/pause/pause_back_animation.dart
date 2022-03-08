import 'package:flutter/material.dart';
import '../base_animation.dart';

class PauseBackAnimation extends BaseAnimation {
  // When it transformd into button, the last step is fade out, how many frames should it take
  int fadeoutAnimationLength = 10;

  // The start center position of the to button animation
  Offset startCenter = const Offset(50, 50);
  // The end center position of the to button animation
  Offset endCenter = const Offset(6, 5);

  // The start size of the to button animation
  Size startSize = const Size(80, 80);
  // The end size of the to button animation
  Size endSize = const Size(10, 7);


  // The start color of the animation
  Color startColor = const Color(0xFFEEFF77);
  // The end color of the animation
  Color endColor = const Color(0xFFEEFF77);

  /// Constructor
  PauseBackAnimation() {
    animationLength = 30;
    stateChangingFrame = 9;
    targetGameState = GameState.playing;
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
      debugPrint("Warning: PauseBackAnimation::renderOnCanvas(Canvas, Size) called, but the frameIndex: $frameIndex is invalid.");
    }
  }

  /// Calculate current Size.
  /// The range is from startCenter to endCenter.
  Offset getCurrentCenter() {
    Offset currentCenter = const Offset(0, 0);

    if(frameIndex <= stateChangingFrame) {
      currentCenter = startCenter;
    }
    else if(frameIndex <= animationLength - 1 - fadeoutAnimationLength) {
      currentCenter = startCenter;
      // The center changed of each frame
      Offset eachFrameCenterOffset = (endCenter - startCenter) / (animationLength - 1 - stateChangingFrame - fadeoutAnimationLength).toDouble();
      // The current center point
      currentCenter += eachFrameCenterOffset * (frameIndex - stateChangingFrame).toDouble();
    }
    else if(frameIndex <= animationLength - 1) {
      currentCenter = endCenter;
    }

    return currentCenter;
  }

  /// Calculate current Size.
  /// The range is from startSize to endSize.
  Size getCurrentSize() {
    Size currentSize = const Size(0, 0);

    // Fade in
    if(frameIndex <= stateChangingFrame) {
      currentSize = startSize;
    }
    // Transform
    else if(frameIndex <= animationLength - 1 - fadeoutAnimationLength) {
      currentSize = startSize;
      // The size change amount in each frame of the animation
      Offset eachFrameChangedSize = Offset(endSize.width - startSize.width, endSize.height - startSize.height) / (animationLength - 1 - stateChangingFrame - fadeoutAnimationLength).toDouble();
      // Calculate the current size
      currentSize += eachFrameChangedSize * (frameIndex - stateChangingFrame).toDouble();
    }
    // Fade out
    else if(frameIndex <= animationLength - 1) {
      currentSize = endSize;
    }

    return currentSize;
  }

  /// Calculate current color.
  /// The range is from startColor to endColor.
  Color getCurrentColor() {
    Color currentColor = const Color(0x00000000);

    // Fade in
    if(frameIndex <= stateChangingFrame) {
      const startAlpha = 0;
      // The color alpha value change amount in each frame of the animation
      double eachFrameChangedAlpha = (startColor.alpha - startAlpha) / stateChangingFrame.toDouble();

      currentColor = Color.fromARGB(
        startAlpha + (eachFrameChangedAlpha * frameIndex).round(),
        startColor.red,
        startColor.green,
        startColor.blue,
      );
    }
    // Transform
    else if(frameIndex <= animationLength - 1 - fadeoutAnimationLength) {
      // The color red value change amount in each frame of the animation
      double eachFrameChangedRed = (endColor.red - startColor.red) / (animationLength - 1 - fadeoutAnimationLength - stateChangingFrame).toDouble();
      // The color green value change amount in each frame of the animation
      double eachFrameChangedGreen = (endColor.green - startColor.green) / (animationLength - 1 - fadeoutAnimationLength - stateChangingFrame).toDouble();
      // The color blue value change amount in each frame of the animation
      double eachFrameChangedBlue = (endColor.blue - startColor.blue) / (animationLength - 1 - fadeoutAnimationLength - stateChangingFrame).toDouble();

      currentColor = Color.fromARGB(
        startColor.alpha,
        startColor.red + (eachFrameChangedRed * (frameIndex - stateChangingFrame)).round(),
        startColor.green + (eachFrameChangedGreen * (frameIndex - stateChangingFrame)).round(),
        startColor.blue + (eachFrameChangedBlue * (frameIndex - stateChangingFrame)).round(),
      );
    }
    // Fade out
    else if(frameIndex <= animationLength - 1) {
      const endAlpha = 0;
      // The color alpha value change amount in each frame of the animation
      double eachFrameChangedAlpha = (endAlpha - endColor.alpha) / stateChangingFrame.toDouble();

      int currentAlpha = endColor.alpha + (eachFrameChangedAlpha * (frameIndex - stateChangingFrame - (animationLength - stateChangingFrame - fadeoutAnimationLength))).round();
      if(currentAlpha < 0) { // Just make sure
        currentAlpha = 0;
      }
      currentColor = Color.fromARGB(
        currentAlpha,
        endColor.red,
        endColor.green,
        endColor.blue,
      );
    }

    return currentColor;
  }
}
