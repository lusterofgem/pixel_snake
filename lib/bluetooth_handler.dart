import "package:flutter_blue/flutter_blue.dart";

class BluetoothHandler {

  void scan() {
    FlutterBlue.instance.startScan(timeout: const Duration(seconds: 4));

    var subscription = FlutterBlue.instance.scanResults.listen((results) {
      for(ScanResult result in results) {
        print("${result.device.name} found! rssi: ${result.rssi}");
      }
    });

    FlutterBlue.instance.stopScan();
  }
}
