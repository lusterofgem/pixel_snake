import 'dart:ui';

// The history score record
class HistoryRecord {
  int score;
  late List foodEaten;
  late Color snakeHeadColor;
  late Color snakeEyeColor;

  HistoryRecord({this.score = 0, List? foodEaten, this.snakeHeadColor = const Color(0xFFFFFFFF), this.snakeEyeColor = const Color(0xFF777777)}) {
    if(foodEaten == null) {
      this.foodEaten = [0, 0, 0, 0, 0];
    }
    else {
      this.foodEaten = foodEaten;
    }
  }
}
