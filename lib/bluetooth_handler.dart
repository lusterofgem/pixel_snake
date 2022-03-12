import "package:flutter_blue/flutter_blue.dart";

class BluetoothHandler {
  FlutterBlue flutterBlue = FlutterBlue.instance;

  void scan() {
    flutterBlue.startScan(timeout: const Duration(seconds: 4));

    var subscription = flutterBlue.scanResults.listen((results) {
      for(ScanResult result in results) {
        print("${result.device.name} found! rssi: ${result.rssi}");
      }
    });

    flutterBlue.stopScan();
  }
}
