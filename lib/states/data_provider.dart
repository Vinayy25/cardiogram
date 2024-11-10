import 'dart:async';
import 'dart:convert';
import 'package:cardiogram/services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:twilio_flutter/twilio_flutter.dart';

class DataProvider extends ChangeNotifier {
  @override
  void dispose() {
    _heartRateSubscription?.cancel();
    _temperatureSubscription?.cancel();
    _oxygenSubscription?.cancel();
    super.dispose();
  }


  List<FlSpot> heartSpots = [];
  List<FlSpot> oxygenSpots = [];
  List<FlSpot> temperatureSpots = [];
  late DatabaseReference _heartRateRef;
  late DatabaseReference _temperatureRef;
  late DatabaseReference _oxygenRef;
  String deviceId = '';
  bool canSendSms = true;
  int emailSentCount = 0;
  String userEmail = '';
  bool heartRisk = false;
  bool oxygenRisk = false;
  bool temperatureRisk = false;
  List<String> heartRiskLog = [];
  List<String> oxygenRiskLog = [];
  List<String> temperatureRiskLog = [];

  StreamSubscription? _heartRateSubscription;
  StreamSubscription? _temperatureSubscription;
  StreamSubscription? _oxygenSubscription;

  int secondsCounter = 0;
  int currHeartRateSum = 0;
  int currOxygenRateSum = 0;
  int currTemperatureSum = 0;

  var heartRate = 0;
  double temperature = 0;
  int oxygen = 0;
  String phoneNumber = '';
  String accountSid = '';
  String authToken = '';
  String twilioNumber = '';
  // ignore: constant_identifier_names
  String YOUR_SERVICE_ID = 'service_hbxaofs';
  // ignore: constant_identifier_names
  String YOUR_TEMPLATE_ID = 'template_u20lfui';
  // ignore: constant_identifier_names
  String YOUR_PUBLIC_KEY = 'tWOpter490Q-5_ATW';
  // ignore: constant_identifier_names
  String YOUR_PRIVATE_KEY = 'dlaeqS7TU8-Gx27ZEG4Xp';

  DataProvider() {
    // Make the constructor asynchronous

    _initializeData();
  }

  Future<void> _initializeData() async {
    // Use await when calling setDeviceId
    await setDeviceId();
    await getPhoneNumber();
    await getTwilioDetails();
    await emailJSDetails();

    _heartRateRef = FirebaseDatabase.instance.ref('/$deviceId/heartrate');
    _temperatureRef = FirebaseDatabase.instance.ref('/$deviceId/temperature');
    _oxygenRef = FirebaseDatabase.instance.ref('/$deviceId/oxygen');
    userEmail = FirebaseAuth.instance.currentUser!.email.toString();

    _heartRateSubscription = _heartRateRef.onValue.listen((event) {
      heartRate = int.parse(event.snapshot.value.toString());

      updateheartSpots();
      predictHeartCondition();
      notifyListeners();
    });

    _temperatureSubscription = _temperatureRef.onValue.listen((event) {
      temperature = double.parse(event.snapshot.value.toString());
      updateTemperatureSpots();

      notifyListeners();
    });

    _oxygenSubscription = _oxygenRef.onValue.listen((event) {
      oxygen = event.snapshot.value as int;
      updateOxygenSpots();

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

    notifyListeners();
  }

  void predictHeartCondition() {
    if ((heartRate == 0 ||
            temperature == 0 ||
            oxygen == 0 ||
            heartRate > 200 ||
            temperature > 100 ||
            oxygen < 90) &&
        secondsCounter < 5) {
      return;
    }

    if (secondsCounter <= 60) {
      currHeartRateSum += heartRate;
      currOxygenRateSum += oxygen;
      currTemperatureSum += temperature.toInt();
      secondsCounter++;
    } else {
      currHeartRateSum =
          currOxygenRateSum = currTemperatureSum = secondsCounter = 0;
    }

    double avgheartrate = (currHeartRateSum / secondsCounter);
    double avgOxygen = (currOxygenRateSum / secondsCounter);
    double avgTemperature = (currTemperatureSum / secondsCounter);

    // Define thresholds for normal and abnormal values
    final heartRateThresholds = {'bradycardia': 40, 'tachycardia': 150};
    final spo2Thresholds = {'normal_low': 95, 'abnormal_low': 92};
    final temperatureThresholds = {'fever': 40, 'low': 20};

    if (avgheartrate < heartRateThresholds['bradycardia']! && !heartRisk) {
      heartRiskLog.add("Bradycardia detected");

      heartRisk = true;
      currHeartRateSum =
          currOxygenRateSum = currTemperatureSum = secondsCounter = 0;
    } else if (avgheartrate > heartRateThresholds['tachycardia']! &&
        !heartRisk) {
      heartRiskLog.add("Tachycardia detected");
      heartRisk = true;
      currHeartRateSum =
          currOxygenRateSum = currTemperatureSum = secondsCounter = 0;
    }

    // Check SpO2
    if (avgOxygen < spo2Thresholds['abnormal_low']! && !oxygenRisk) {
      oxygenRiskLog.add("Low SpO2 detected");

      oxygenRisk = true;
      currHeartRateSum =
          currOxygenRateSum = currTemperatureSum = secondsCounter = 0;
    }

    // Check temperature
    if (avgTemperature > temperatureThresholds['fever']! && !temperatureRisk) {
      temperatureRiskLog.add("High body temperature detected");
      temperatureRisk = true;
      currHeartRateSum =
          currOxygenRateSum = currTemperatureSum = secondsCounter = 0;
    } else if (avgTemperature < temperatureThresholds['low']! &&
        !temperatureRisk) {
      temperatureRiskLog.add("Low body temperature detected");
      temperatureRisk = true;
      currHeartRateSum =
          currOxygenRateSum = currTemperatureSum = secondsCounter = 0;
    }

    if (heartRisk) {
      email();
      heartRisk = false;

      if (canSendSms) {
        sendSMS();
        canSendSms = false;
      }
    }
    // Check additional thresholds
    // Example: High heart rate variability could indicate cardiac dysfunction
  }

  Future<void> setDeviceId() async {
    deviceId = await FirebaseService().getDeviceId();
    print(deviceId);
    notifyListeners();
  }

  Future<void> getPhoneNumber() async {
    phoneNumber = await FirebaseService().getPhoneNumber();
    notifyListeners();
  }

  Future<void> emailJSDetails() async {
    var data = await FirebaseService().getEmailJSDetails();

    YOUR_PRIVATE_KEY = data['YOUR_PRIVATE_KEY']!;
    YOUR_PUBLIC_KEY = data['YOUR_PUBLIC_KEY']!;
    YOUR_SERVICE_ID = data['YOUR_SERVICE_ID']!;
    YOUR_TEMPLATE_ID = data['YOUR_TEMPLATE_ID']!;
    notifyListeners();
  }

  Future<void> getTwilioDetails() async {
    var data = await FirebaseService().getTwilioDetails();
    accountSid = data['accountSid']!;
    authToken = data['authToken']!;
    twilioNumber = data['twilioNumber']!;
    notifyListeners();
  }

  void sendSMS() async {
    TwilioFlutter twilioFlutter;
    twilioFlutter = TwilioFlutter(
        accountSid: accountSid,
        authToken: authToken,
        twilioNumber: twilioNumber);
    Future<int> response = twilioFlutter.sendSMS(
        toNumber: '+91$phoneNumber',
        messageBody:
            'Emergancy! Heart rate is abnormal\nHeartRate:$heartRate\nOxygen:$oxygen\nTemperature:$temperature\n');
    await response.then((value) => print(value.toString()));
    if (await response == 201) {
      canSendSms = false;
      print('message sent');
    }
  }

  Future<int> email() async {
    String mainReadings =
        "Heart Rate: $heartRate\nOxygen: $oxygen\nTemperature: $temperature";
    int response = await sendEmail(
        fromName: 'cardiogram',
        toEmail: userEmail,
        message:
            "$mainReadings\n\n${heartRiskLog.join('\n')}\n${oxygenRiskLog.join('\n')}\n${temperatureRiskLog.join('\n ')}",
        replyTo: 'cardiogram60@gmail.com',
        heartRate: heartRate.toString());

    return response;
  }

  Future<int> sendEmail(
      {required String fromName,
      required String toEmail,
      required String message,
      required String replyTo,
      required String heartRate}) async {
    if (emailSentCount >= 5) {
      return 400;
    }
    try {
      final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
      final response = await http.post(
        url,
        headers: {
          'origin': 'http://localhost:3000',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'service_id': YOUR_SERVICE_ID,
          'template_id': YOUR_TEMPLATE_ID,
          'user_id': YOUR_PUBLIC_KEY,
          'template_params': {
            'from_name': fromName,
            'to_email': toEmail,
            'message': message,
            'reply_to': replyTo,
            'heart_rate': heartRate
          }
        }),
      );
      if (response.statusCode == 200) {
        emailSentCount++;
      }
      return response.statusCode;
    } catch (e) {
      print(e.toString());

      return 400;
    }
  }
}
