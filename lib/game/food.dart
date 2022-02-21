import 'dart:ui';

// import 'package:flame/flame.dart';

/// The food will decay by the time goes on
class Food {
  /// The x position on the map
  int x = 0;
  /// The y position on the map
  int y = 0;
  /// The name of this food
  String name = 'watermelon';
  /// The appearence of the food is a set of image
  List<Image> image = [];

  /// Set position of the food
  Food(this.x, this.y, {this.name = 'watermelon'});

  // /// Load the png image of the food by the given name and quantity.
  // /// For example: loadPng('apple', 3); will load image 'apple0.png', 'apple1.png and 'apple2.png'.
  // Future<void>? loadPng(String path, int quantity) {
  //   for(int i = 0; i < quantity; i++) {
  //     Flame.images.load('${path}${quantity}.png').then((value) => image.add(value));
  //   }
  // }
}
