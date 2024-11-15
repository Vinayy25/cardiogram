import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cardiogram/services/firebase_service.dart';

class AuthStateProvider extends ChangeNotifier {
  bool isAuthenticated = false;
  bool signInPage = true;
  String deviceId='';
  AuthStateProvider() {
    
    checkAuthStatus();
    if(isAuthenticated==true) getDeviceId();
  }
    void getDeviceId() async {
    deviceId = await FirebaseService().getDeviceId();
    notifyListeners();
  }



  void toggleSignInPage() {
    signInPage = !signInPage;
    notifyListeners();
  }

  void setAuthenticated(bool value) {
    isAuthenticated = value;
    notifyListeners();
  }
  void signOut() async {
    await FirebaseAuth.instance.signOut();
 
 
    await FirebaseService().signOut();
    isAuthenticated = false;
    notifyListeners();
  }
final auth = FirebaseAuth.instance;

  Future<void> logoutAll() async {
    await FirebaseService().signOut(); 
    await auth.signOut();
    
  }

  void checkAuthStatus() {
      FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        isAuthenticated = false;
        print("my State: $isAuthenticated");
        notifyListeners();
      } else {
        isAuthenticated = true;
        getDeviceId();
        notifyListeners();
      }
    });

  
  }
}

