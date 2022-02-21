// import 'dart:ui';

import 'package:flutter/material.dart';

class Button {
  /// The screen size of the game
  Size? _screenSize;
  /// If the button is clicked
  bool _tapDown = false;
  /// Color of this button
  Color color = Colors.yellow;
  // /// Offset of this button
  // Offset offset = const Offset(0, 0);
  /// Center of this button
  Offset center = const Offset(0, 0);
  /// Size of this button
  Size size = const Size(0, 0);
  /// The color when the button is tap down
  Color? downColor;
  /// The size change ratio when the button is tap down
  double downSizeRatio = 0.9;
  // /// The image of the button
  // Image? image;

  /// Draw this button on the given canvas
  /// Screen size have to be set in this function,
  /// need the size of the screen to draw the button size correctly
  void renderOnCanvas(Canvas canvas, Size screenSize) {
    _screenSize = screenSize;

    if(!_tapDown) {
      canvas.drawRect(
        Rect.fromCenter(center: Offset(_toAbsoluteWidth(center.dx), _toAbsoluteHeight(center.dy)),
                        width: _toAbsoluteWidth(size.width),
                        height: _toAbsoluteHeight(size.height)),
        Paint()
          ..color = color,
      );
    } else {
      final downColor = this.downColor ?? color;
      canvas.drawRect(
        Rect.fromCenter(center: Offset(_toAbsoluteWidth(center.dx), _toAbsoluteHeight(center.dy)),
                        width: _toAbsoluteWidth(downSize.width),
                        height: _toAbsoluteHeight(downSize.height)),
        Paint()
          ..color = downColor,
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
    if(center.dx - size.width / 2 <= x &&
       center.dy - size.height / 2 <= y &&
       center.dx + size.width / 2 >= x &&
       center.dy + size.height / 2 >= y) {
      return true;
    }

    return false;
  }

  // /// Calculate the down offset
  // Offset get downOffset {
  //   return Offset(offset.dx + (size.width - downSize.width) / 2, offset.dy + (size.height - downSize.height) / 2);
  // }

  /// Calculate the down size
  Size get downSize {
    return size * downSizeRatio;
  }

  /// Convert percentage width (0.0 ~ 100.0) to real real width on the screen.
  /// Warning: _screenSize need to be set before this function being invoked.
  double _toAbsoluteWidth(double relativeWidth) {
    final _screenSize = this._screenSize;
    if(_screenSize == null) {
      debugPrint("Error: _screenSize need to be set before _toAbsoluteWidth(double relativeWidth) being invoked.");
      return 0;
    }

    return _screenSize.width * relativeWidth / 100.0;
  }

  /// Convert percentage height (0.0 ~ 100.0) to real height on the screen.
  /// Warning: _screenSize need to be set before this function being invoked.
  double _toAbsoluteHeight(double relativeHeight) {
    final _screenSize = this._screenSize;
    // _screenSize need to be set before _toAbsoluteHeight(double relativeHeight) being invoked.
    if(_screenSize == null) {
      debugPrint("Error: _screenSize need to be set before _toAbsoluteHeight(double relativeHeight) being invoked.");
      return 0;
    }

    return _screenSize.height * relativeHeight / 100.0;
  }
}
