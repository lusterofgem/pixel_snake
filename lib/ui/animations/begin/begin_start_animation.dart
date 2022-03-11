import 'dart:ui';

import 'package:flame/flame.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart' as material;

import '../base_animation.dart';

class BeginStartAnimation extends BaseAnimation {
  // The start center position of the full screen animation
  Offset startCenter = const Offset(50, 87.5);
  // The end center position of the full screen animation
  Offset endCenter = const Offset(50, 50);

  // The start size of the to full screen animation
  Size startSize = const Size(60, 15);
  // The end size of the to full screen animation
  Size endSize = const Size(100, 100);

  // The start color of the animation
  Color startColor = const Color(0xFF52EB85);
  // The end color of the animation
  Color endColor = const Color(0xFF66FF99);

  Image? _startImage;

  /// Constructor
  BeginStartAnimation() {
    animationLength = 30;
    stateChangingFrame = 9;
    targetGameState = GameState.playing;
  }

  /// Draw this animation on the given canvas.
  /// Screen size have to be set in this function,
  /// need the size of the screen to draw the animation size correctly.
  @override
  void drawOnCanvas(Canvas canvas, {required Vector2 screenSize}) {
    // Draw animation
    if(frameIndex < animationLength) {
      final currentCenter = _getCurrentCenter();
      final currentSize = _getCurrentSize();
      final currentColor = _getCurrentColor();
      canvas.drawRect(
        Rect.fromCenter(center: Offset(toAbsoluteWidth(currentCenter.dx, screenSize: screenSize), toAbsoluteHeight(currentCenter.dy, screenSize: screenSize)),
                        width: toAbsoluteWidth(currentSize.width, screenSize: screenSize),
                        height: toAbsoluteHeight(currentSize.height, screenSize: screenSize)),
        Paint()
          ..color = currentColor,
      );

      // Draw animation icon
      final _startImage = this._startImage;
      if(_startImage != null) {
        Sprite sprite = Sprite(_startImage);
        sprite.render(
          canvas,
          position: Vector2(toAbsoluteWidth(startCenter.dx - currentSize.width / 2, screenSize: screenSize), toAbsoluteHeight(startCenter.dy - currentSize.height / 2, screenSize: screenSize)),
          size: Vector2(toAbsoluteWidth(currentSize.width, screenSize: screenSize), toAbsoluteHeight(currentSize.height, screenSize: screenSize)),
          overridePaint: Paint()
            ..color = Color.fromARGB(((1 - frameIndex / animationLength) * 255).toInt(), 0, 0, 0)
        );
      }
    }
    // Warning when the frame index is invalid but this function is called
    else {
      material.debugPrint("Warning: BeginStartAnimation::renderOnCanvas(Canvas, Size) called, but the frameIndex: $frameIndex is invalid.");
    }
  }

  /// Calculate current Size.
  /// The range is from startCenter to endCenter.
  Offset _getCurrentCenter() {
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

  /// Calculate current Size.
  /// The range is from startSize to endSize.
  Size _getCurrentSize() {
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

  /// Calculate current color.
  /// The range is from startColor to endColor.
  Color _getCurrentColor() {
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

  /// Load resource.
  /// If the animation have resource, it should be loaded before the animation play.
  @override
  Future<void> loadResource() async {
    _startImage = await Flame.images.load('start.png');
  }
}
