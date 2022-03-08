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

  Button({Offset center = const Offset(0, 0), Size size = const Size(0, 0), Color color = material.Colors.yellow, Color? downColor, Image? image})
  :_center = center
  ,_size = size
  ,_color = color
  ,_downColor = downColor ?? color {
    image = image;
  }

  /// Calculate the down size
  Size get downSize {
    return _size * _downSizeRatio;
  }

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
          position: Vector2(_toAbsoluteWidth(_center.dx - (_size.width / 2), screenSize: screenSize), _toAbsoluteHeight(_center.dy, screenSize: screenSize)),
          size: Vector2(_toAbsoluteWidth(_size.width, screenSize: screenSize), _toAbsoluteHeight(_size.height, screenSize: screenSize)),
        );
      }
    } else {
      final _downColor = this._downColor;
      canvas.drawRect(
        Rect.fromCenter(center: Offset(_toAbsoluteWidth(_center.dx, screenSize: screenSize), _toAbsoluteHeight(_center.dy, screenSize: screenSize)),
                        width: _toAbsoluteWidth(downSize.width, screenSize: screenSize),
                        height: _toAbsoluteHeight(downSize.height, screenSize: screenSize)),
        Paint()
          ..color = _downColor,
      );
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
