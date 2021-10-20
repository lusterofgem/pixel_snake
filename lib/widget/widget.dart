import 'dart:ui';

// The base component that can draw on canvas
abstract class Widget {
  // Draw this widget on the given canvas
  // Need the size of the screen to draw the button size correctly
  void drawOnCanvas(Canvas canvas, Size screenSize);
}
