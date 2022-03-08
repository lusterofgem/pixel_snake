import 'dart:ui';

import 'package:flame/sprite.dart';
import 'package:flutter/material.dart' as material;
import 'package:vector_math/vector_math_64.dart';

class Button {
  /// The screen size of the game
  // Size? _screenSize;
  /// If the button is clicked
  bool _tapDown = false;
  /// Color of this button
  final Color _color;
  /// Center of this button
  final Offset _center;
  /// Size of this button
  final Size _size;
  /// The color when the button is tap down
  final Color _downColor;
  /// The size change ratio when the button is tap down
  final double _downSizeRatio = 0.9;
  /// The image of the button
  Image? image;
  /// The image width ratio relative to the button
  final double _imageWidthRatio;
  /// The image hegiht ratio relative to the button
  final double _imageHeightRatio;

  Button({
    Offset center = const Offset(0, 0),
    Size size = const Size(0, 0),
    Color color = material.Colors.yellow,
    Color? downColor,
    double imageWidthRatio = 0.5,
    double imageHeightRatio = 1.0,
    this.image,
  })
  :_center = center
  ,_size = size
  ,_color = color
  ,_downColor = downColor ?? color
  ,_imageWidthRatio = imageWidthRatio
  ,_imageHeightRatio = imageHeightRatio;

  /// Draw this button on the given canvas
  /// Screen size have to be set in this function,
  /// need the size of the screen to draw the button size correctly
  void drawOnCanvas(Canvas canvas, Size screenSize) {
    if(!_tapDown) {
      // draw button color
      canvas.drawRect(
        Rect.fromCenter(center: Offset(_toAbsoluteWidth(_center.dx, screenSize: screenSize), _toAbsoluteHeight(_center.dy, screenSize: screenSize)),
                        width: _toAbsoluteWidth(_size.width, screenSize: screenSize),
                        height: _toAbsoluteHeight(_size.height, screenSize: screenSize)),
        Paint()
          ..color = _color,
      );
      // draw button image
      final image = this.image;
      if(image != null) {
        Sprite sprite = Sprite(image);
        sprite.render(
          canvas,
          position: Vector2(_toAbsoluteWidth(_center.dx - (_size.width * _imageWidthRatio / 2), screenSize: screenSize), _toAbsoluteHeight(_center.dy - (_size.height * _imageHeightRatio / 2), screenSize: screenSize)),
          size: Vector2(_toAbsoluteWidth(_size.width * _imageWidthRatio, screenSize: screenSize), _toAbsoluteHeight(_size.height * _imageHeightRatio, screenSize: screenSize)),
        );
      }
    } else {
      // draw button color
      final _downColor = this._downColor;
      canvas.drawRect(
        Rect.fromCenter(center: Offset(_toAbsoluteWidth(_center.dx, screenSize: screenSize), _toAbsoluteHeight(_center.dy, screenSize: screenSize)),
                        width: _toAbsoluteWidth(_size.width * _downSizeRatio, screenSize: screenSize),
                        height: _toAbsoluteHeight(_size.height * _downSizeRatio, screenSize: screenSize)),
        Paint()
          ..color = _downColor,
      );
      // draw button image
      final image = this.image;
      if(image != null) {
        Sprite sprite = Sprite(image);
        sprite.render(
          canvas,
          position: Vector2(_toAbsoluteWidth(_center.dx - (_size.width * _imageWidthRatio * _downSizeRatio / 2), screenSize: screenSize), _toAbsoluteHeight(_center.dy - (_size.height * _imageHeightRatio * _downSizeRatio / 2), screenSize: screenSize)),
          size: Vector2(_toAbsoluteWidth(_size.width * _imageWidthRatio * _downSizeRatio, screenSize: screenSize), _toAbsoluteHeight(_size.height * _imageHeightRatio * _downSizeRatio, screenSize: screenSize)),
        );
      }
    }
  }

  // /// Check if the button has image to draw
  // bool hasImage() {
  //   if(image == null) {
  //     return false;
  //   }
  //   else {
  //     return true;
  //   }
  // }

  /// Tap down the button
  void tapDown() {
    _tapDown = true;
  }

  /// Tap up the button
  void tapUp() {
    _tapDown = false;
  }

  /// If the given position is on the button
  bool isOnButton(double x, double y) {
    if(_center.dx - _size.width / 2 <= x &&
       _center.dy - _size.height / 2 <= y &&
       _center.dx + _size.width / 2 >= x &&
       _center.dy + _size.height / 2 >= y) {
      return true;
    }

    return false;
  }

  /// Convert percentage width (0.0 ~ 100.0) to real real width on the screen.
  double _toAbsoluteWidth(double relativeWidth, {required Size screenSize}) {
    return screenSize.width * relativeWidth / 100.0;
  }

  /// Convert percentage height (0.0 ~ 100.0) to real height on the screen.
  double _toAbsoluteHeight(double relativeHeight, {required Size screenSize}) {
    return screenSize.height * relativeHeight / 100.0;
  }
}
