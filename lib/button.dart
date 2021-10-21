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
  Offset offset = Offset(20,80);
  // Size of this button
  Size size = Size(60, 15);
  // The color when the button is tap down
  Color downColor = Colors.orange;
  // The size when the button is tap down
  Size downSize = Size(0,0);

  /****************************************************************************************************
   * Draw this button on the given canvas
   * Need the size of the screen to draw the button size correctly
   ****************************************************************************************************/
  void drawOnCanvas(Canvas canvas, Size screenSize) {
    if(!_tapDown) {
      canvas.drawRect(
        Rect.fromLTWH(_toRealWidth(offset.dx),
                      _toRealHeight(offset.dy),
                      _toRealWidth(size.width),
                      _toRealHeight(size.height)),
        Paint()
          ..color = color,
      );
    } else {
      canvas.drawRect(
        Rect.fromLTWH(_toRealWidth(downOffset.dx),
                      _toRealHeight(downOffset.dy),
                      _toRealWidth(downSize.width),
                      _toRealHeight(downSize.height)),
        Paint()
          ..color = color,
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
   * If the given point is in the button range
   ****************************************************************************************************/
  bool isPointInRange(int x, int y) {
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
    return Offset(offset.dx + (size.width - downSize.width) / 2, offset.dy + (size.height - downSize.height / 2));
  }
  /****************************************************************************************************
   * Convert percentage width (0.0 ~ 100.0) to real real width on the screen.
   * Warning: _screenSize need to be set before this function being invoked.
   ****************************************************************************************************/
  double _toRealWidth(double percentageWidth) {
    final _screenSize = this._screenSize;
    if(_screenSize == null) {
      print("Error: _screenSize need to be set before this function being invoked.");
      return 0;
    }

    return _screenSize.width * percentageWidth / 100.0;
  }

  /****************************************************************************************************
   * Convert percentage height (0.0 ~ 100.0) to real height on the screen.
   * Warning: Screen size need to be set before this function being invoked.
   ****************************************************************************************************/
  double _toRealHeight(double percentageHeight) {
    final _screenSize = this._screenSize;
    if(_screenSize == null) {
      print("Error: _screenSize need to be set before this function being invoked.");
      return 0;
    }

    return _screenSize.height * percentageHeight / 100.0;
  }

}
