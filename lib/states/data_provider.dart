import 'dart:async';
import 'package:cardiogram/services/firebase_service.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class DataProvider extends ChangeNotifier {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  List<FlSpot> heartSpots = [];
  List<FlSpot> oxygenSpots = [];
  List<FlSpot> temperatureSpots = [];
  late DatabaseReference _heartRateRef;
  late DatabaseReference _temperatureRef;
  late DatabaseReference _oxygenRef;
  String deviceId = '';

  bool heartRisk =false;
  bool oxygenRisk =false;
  bool temperatureRisk =false;
  List<String>heartRiskLog=[];
  List<String>oxygenRiskLog=[];
  List<String>temperatureRiskLog=[];
  
  var heartRate = 0;
  int temperature = 0;
  int oxygen = 0;

  DataProvider() {
    // Make the constructor asynchronous
    _initializeData();
  }

  Future<void> _initializeData() async {
    // Use await when calling setDeviceId
    await setDeviceId();

    _heartRateRef = FirebaseDatabase.instance.ref('/$deviceId/heartrate');
    _temperatureRef = FirebaseDatabase.instance.ref('/$deviceId/temperature');
    _oxygenRef = FirebaseDatabase.instance.ref('/$deviceId/oxygen');

    _heartRateRef.onValue.listen((event) {
      heartRate = event.snapshot.value as int;
      updateheartSpots();
      predictHeartCondition(); // Call prediction function
      notifyListeners();
    });

    _temperatureRef.onValue.listen((event) {
      temperature = event.snapshot.value as int;
      updateTemperatureSpots();
      predictHeartCondition(); // Call prediction function
      notifyListeners();
    });

    _oxygenRef.onValue.listen((event) {
      oxygen = event.snapshot.value as int;
      updateOxygenSpots();
      predictHeartCondition(); // Call prediction function
      notifyListeners();
    });
  }

  void setHeartRate(int heartRate) {
    this.heartRate = heartRate;
    notifyListeners();
  }

  void updateheartSpots() {
    if (heartSpots.length > 20) {
      // Remove the first point
      heartSpots.removeAt(0);

      // Shift all indices to the left
      for (int i = 0; i < heartSpots.length; i++) {
        heartSpots[i] = FlSpot(i.toDouble(), heartSpots[i].y);
      }
    }

    // Add the new point at the end
    heartSpots.add(FlSpot(heartSpots.length.toDouble(), heartRate.toDouble()));

    print(heartSpots);
    notifyListeners();
  }

  void updateOxygenSpots() {
    if (oxygenSpots.length > 20) {
      // Remove the first point
      oxygenSpots.removeAt(0);
      // Shift all indices to the left
      for (int i = 0; i < oxygenSpots.length; i++) {
        oxygenSpots[i] = FlSpot(i.toDouble(), oxygenSpots[i].y);
      }
    }

    // Add the new point at the end
    oxygenSpots.add(FlSpot(oxygenSpots.length.toDouble(), oxygen.toDouble()));

    // print(oxygenSpots);
    notifyListeners();
  }

  void updateTemperatureSpots() {
    if (temperatureSpots.length > 20) {
      // Remove the first point
      temperatureSpots.removeAt(0);

      // Shift all indices to the left
      for (int i = 0; i < temperatureSpots.length; i++) {
        temperatureSpots[i] = FlSpot(i.toDouble(), temperatureSpots[i].y);
      }
    }

    // Add the new point at the end
    temperatureSpots.add(
        FlSpot(temperatureSpots.length.toDouble(), temperature.toDouble()));

    print(temperatureSpots);
    notifyListeners();
  }

  void predictHeartCondition() {
    // Define thresholds for normal and abnormal values
    final heartRateThresholds = {'bradycardia': 60, 'tachycardia': 100};
    final spo2Thresholds = {'normal_low': 95, 'abnormal_low': 90};
    final temperatureThresholds = {'fever': 100.4, 'low': 95};

    // Additional thresholds
    final heartRateVariabilityThreshold =
        10; // Example threshold for high variability
    final spo2DropThreshold = 5; // Example threshold for a rapid drop in SpO2

    // Check heart rate
    if (heartRate < heartRateThresholds['bradycardia']! && !heartRisk ) {
      print("Bradycardia detected");
      heartRiskLog.add("Bradycardia detected");

      heartRisk = true;

    } else if (heartRate > heartRateThresholds['tachycardia']! && !heartRisk) {
      print("Tachycardia detected");
      heartRiskLog.add("Tachycardia detected");
      heartRisk = true;
    }

    // Check SpO2
    if (oxygen < spo2Thresholds['abnormal_low']! && !oxygenRisk) {
      print("Low SpO2 detected");
      oxygenRiskLog.add("Low SpO2 detected");

      oxygenRisk = true;
    }

    // Check temperature
    if (temperature > temperatureThresholds['fever']! && !temperatureRisk) {
      print("Fever detected");
      temperatureRiskLog.add("Fever detected");
      temperatureRisk = true;

    } else if (temperature < temperatureThresholds['low']! && !temperatureRisk) {
      print("Low body temperature detected");
      temperatureRiskLog.add("Low body temperature detected");
      temperatureRisk = true;
    }

    // Check additional thresholds
    // Example: High heart rate variability could indicate cardiac dysfunction
  }

  Future<void> setDeviceId() async {
    deviceId = await FirebaseService().getDeviceId();
    notifyListeners();
  }
}
