import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emailjs/emailjs.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cardiogram/utils/error_dialog.dart';

class FirebaseService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<String> signInWithGoogle(String deviceId, String phoneNumber) async {
    try {
      if (deviceId == null ||
          deviceId == '' ||
          deviceId.length < 3 ||
          phoneNumber == null ||
          phoneNumber == '' ||
          phoneNumber.length < 10) {
        return 'enter correct device id and phone number';
      }
      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        final AuthCredential authCredential = GoogleAuthProvider.credential(
            idToken: googleSignInAuthentication.idToken,
            accessToken: googleSignInAuthentication.accessToken);

        final UserCredential userCredential =
            await _firebaseAuth.signInWithCredential(authCredential);
        final User? user = userCredential.user;
        print(user?.email ?? "no email");

        if (userCredential.additionalUserInfo?.isNewUser == true) {
          print('reached to this point ');
          await FirebaseFirestore.instance
              .collection('deviceIds')
              .doc(_firebaseAuth.currentUser?.email)
              .set({
            'deviceId': deviceId,
            'phoneNumber': phoneNumber,
            'accountSid': 'AC5c014bbd8592d10d634948a1c7eb61a4',
            'authToken': 'cb2e28846766bd779a895d39e9b94d64',
            'twilioNumber': '+13203838376'
          });

          FirebaseDatabase database = FirebaseDatabase.instance;
          await database.ref('/$deviceId').set({
            'heartrate': 0,
            'temperature': 0,
            'oxygen': 0,
          });
        }
      } else {
        print("error");

        await _googleSignIn.signOut();
        return 'ERROR';
      }
      await FirebaseFirestore.instance
          .collection('deviceIds')
          .doc(_firebaseAuth.currentUser?.email)
          .update({
        'deviceId': deviceId,
        'phoneNumber': phoneNumber,
      });

      return 'SUCCESS';
    } catch (e) {
      throw e;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<String> getDeviceId() {
    return FirebaseFirestore.instance
        .collection('deviceIds')
        .doc(_firebaseAuth.currentUser?.email)
        .get()
        .then((value) => value['deviceId']);
  }

  Future<String> getPhoneNumber() {
    return FirebaseFirestore.instance
        .collection('deviceIds')
        .doc(_firebaseAuth.currentUser?.email)
        .get()
        .then((value) => value['phoneNumber']);
  }

  Future<Map<String, String>> getTwilioDetails() {
    return FirebaseFirestore.instance
        .collection('deviceIds')
        .doc(_firebaseAuth.currentUser?.email)
        .get()
        .then((value) => {
              'accountSid': value['accountSid'],
              'authToken': value['authToken'],
              'twilioNumber': value['twilioNumber']
            });
  }

  Future<Map<String, String>> getEmailJSDetails() {
    return FirebaseFirestore.instance
        .collection('keys')
        .doc('myKeys')
        .get()
        .then((value) => {
              'YOUR_SERVICE_ID': value['YOUR_SERVICE_ID'],
              'YOUR_TEMPLATE_ID': value['YOUR_TEMPLATE_ID'],
              'YOUR_PUBLIC_KEY': value['YOUR_PUBLIC_KEY'],
              'YOUR_PRIVATE_KEY': value['YOUR_PRIVATE_KEY']
            });
  }

  Future<void> updateCredentials() {
    return FirebaseFirestore.instance
        .collection('deviceIds')
        .doc(_firebaseAuth.currentUser?.email)
        .update({
      'accountSid': 'AC5c014bbd8592d10d634948a1c7eb61a4',
      'authToken': 'cb2e28846766bd779a895d39e9b94d64',
      'twilioNumber': '+13203838376'
    });
  }
}
