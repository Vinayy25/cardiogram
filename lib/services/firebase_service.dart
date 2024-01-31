import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cardiogram/utils/error_dialog.dart';

class FirebaseService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<String> signInWithGoogle(String deviceId) async {
    try {
      if (deviceId == null || deviceId == '' || deviceId.length < 3) {
        return 'enter correct device id';
      }
      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();

      if (googleSignInAccount != null ) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        final AuthCredential authCredential = GoogleAuthProvider.credential(
            idToken: googleSignInAuthentication.idToken,
            accessToken: googleSignInAuthentication.accessToken);

        final UserCredential userCredential =
            await _firebaseAuth.signInWithCredential(authCredential);
        final User? user = userCredential.user;
        print(user?.email ?? "no email");
      } else {
        print("not a sode email");

        await _googleSignIn.signOut();
        return 'NOT A SODE EMAIL';
      }
      await FirebaseFirestore.instance.
          collection('deviceIds')
          .doc(_firebaseAuth.currentUser?.email)
          .set({'deviceId': deviceId});
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

  Future<String>getDeviceId(){
    return FirebaseFirestore.instance.
    collection('deviceIds')
        .doc(_firebaseAuth.currentUser?.email)
        .get().then((value) => value['deviceId']);
  }
}
