import 'dart:ui';

import 'package:flutter/material.dart';

class Button {
  /****************************************************************************************************
   * Variable
   ****************************************************************************************************/
  // The screen size of the game
  Size? _screenSize;
  // If the button is clicked
  bool _tapDown = false;
  // Color of this button
  Color color = Colors.yellow;
  // Offset of this button
  Offset offset = Offset(0, 0);
  // Size of this button
  Size size = Size(0, 0);
  // The color when the button is tap down
  Color? downColor;
  // The size when the button is tap down
  Size? downSize;

  /****************************************************************************************************
   * Draw this button on the given canvas
   * Need the size of the screen to draw the button size correctly
   ****************************************************************************************************/
  void drawOnCanvas(Canvas canvas, Size screenSize) {
    _screenSize = screenSize;
    if(!_tapDown) {
      canvas.drawRect(
        Rect.fromLTWH(_toAbsoluteWidth(offset.dx),
                      _toAbsoluteHeight(offset.dy),
                      _toAbsoluteWidth(size.width),
                      _toAbsoluteHeight(size.height)),
        Paint()
          ..color = color,
      );
    } else {
      final downSize = this.downSize ?? size;
      final downColor = this.downColor ?? color;
      canvas.drawRect(
        Rect.fromLTWH(_toAbsoluteWidth(downOffset.dx),
                      _toAbsoluteHeight(downOffset.dy),
                      _toAbsoluteWidth(downSize.width),
                      _toAbsoluteHeight(downSize.height)),
        Paint()
          ..color = downColor,
      );
    }
  }

  /****************************************************************************************************
   * Tap down the button
   ****************************************************************************************************/
  void tapDown() {
    _tapDown = true;
  }

  /****************************************************************************************************
   * Tap up the button
   ****************************************************************************************************/
  void tapUp() {
    _tapDown = false;
  }

  /****************************************************************************************************
   * If the given position is on the button
   ****************************************************************************************************/
  bool isOnButton(double x, double y) {
    if(offset.dx <= x &&
       offset.dy <= y &&
       offset.dx + size.width >= x &&
       offset.dy + size.height >= y) {
      return true;
    }

    return false;
  }

  /****************************************************************************************************
   * Calculate the down offset
   ****************************************************************************************************/
  Offset get downOffset {
    final downSize = this.downSize;
    if(downSize == null) {
      return offset;
    }
    return Offset(offset.dx + (size.width - downSize.width) / 2, offset.dy + (size.height - downSize.height) / 2);
  }
  /****************************************************************************************************
   * Convert percentage width (0.0 ~ 100.0) to real real width on the screen.
   * Warning: _screenSize need to be set before this function being invoked.
   ****************************************************************************************************/
  double _toAbsoluteWidth(double relativeWidth) {
    final _screenSize = this._screenSize;
    if(_screenSize == null) {
      print("Error: _screenSize need to be set before _toAbsoluteWidth(double relativeWidth) being invoked.");
      return 0;
    }

    return _screenSize.width * relativeWidth / 100.0;
  }

  /****************************************************************************************************
   * Convert percentage height (0.0 ~ 100.0) to real height on the screen.
   * Warning: Screen size need to be set before this function being invoked.
   ****************************************************************************************************/
  double _toAbsoluteHeight(double relativeHeight) {
    final _screenSize = this._screenSize;
    if(_screenSize == null) {
      print("Error: _screenSize need to be set before _toAbsoluteHeight(double relativeHeight) being invoked.");
      return 0;
    }

    return _screenSize.height * relativeHeight / 100.0;
  }

}
