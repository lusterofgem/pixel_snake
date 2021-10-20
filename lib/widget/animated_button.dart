import 'dart:ui';

import 'widget.dart';

// The button which have animation to play
abstract class AnimatedButton extends Widget {
  // If this button have next frame to draw
  bool haveNextFrame();

  // Change this button to next frame
  // If there are no more frame, directly return false
  bool toNextFrame();

  // Reset this button animation
  void reset();

  //
//   bool get size();

}
