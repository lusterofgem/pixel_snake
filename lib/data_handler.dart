import "dart:ui";

import "package:shared_preferences/shared_preferences.dart";

import "history_record.dart";

class DataHandler {
  late SharedPreferences sharedPreferences;

  // need to call before first use
  Future<void> init() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  void saveVolume(double volume) {
    sharedPreferences.setDouble("volume", volume);
  }
  double getVolume() {
    return sharedPreferences.getDouble("volume") ?? 0.5;
  }

  void saveSnakeForwardTime(double speed) {
    sharedPreferences.setDouble("snakForwardTime", speed);
  }
  double getSnakForwardTime() {
    return sharedPreferences.getDouble("snakForwardTime") ?? 0.35;
  }

  void saveEnabledFood(List enabledFood) {
    for(int i = 0; i < 5; ++i) {
      sharedPreferences.setBool("enabledFood$i", enabledFood[i]);
    }
  }
  List<bool> getEnabledFood() {
    List<bool> enabledFood = [true, true, true, true, true];
    for(int i = 0; i < 5; ++i) {
      enabledFood[i] = sharedPreferences.getBool("enabledFood$i") ?? true;
    }
    return enabledFood;
  }

  void saveHistoryRecords(List<HistoryRecord> historyRecords) {
    for(int i = 0; i < 3; ++i) {
      sharedPreferences.setInt("${i}score", historyRecords[i].score);
      sharedPreferences.setInt("${i}snakeHeadColor", historyRecords[i].snakeHeadColor.value);
      sharedPreferences.setInt("${i}snakeEyeColor", historyRecords[i].snakeEyeColor.value);
      for(int j = 0; j < 5; ++j) {
        sharedPreferences.setInt("${i}foodEaten$j", historyRecords[i].foodEaten[j]);
      }
    }
  }
  List<HistoryRecord> getHistoryRecords() {
    List<HistoryRecord> historyRecords = [HistoryRecord(), HistoryRecord(), HistoryRecord()];
    for(int i = 0; i < 3; ++i) {
      historyRecords[i].score = sharedPreferences.getInt("${i}score") ?? 0;
      historyRecords[i].snakeHeadColor = Color(sharedPreferences.getInt("${i}snakeHeadColor") ?? 0xFFFFFFFF);
      historyRecords[i].snakeEyeColor = Color(sharedPreferences.getInt("${i}snakeEyeColor") ?? 0xFF777777);
      for(int j = 0; j < 5; ++j) {
        historyRecords[i].foodEaten[j] = sharedPreferences.getInt("${i}foodEaten$j") ?? 0;
      }
    }
    return historyRecords;
  }
}
