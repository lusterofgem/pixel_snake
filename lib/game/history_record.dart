// The history score record
class HistoryRecord {
  int score;
  late List foodEaten;

  HistoryRecord({this.score = 0, List? foodEaten}) {
    if(foodEaten == null) {
      this.foodEaten = [0, 0, 0, 0, 0];
    }
    else {
      this.foodEaten = foodEaten;
    }
  }
}
