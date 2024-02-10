import 'package:animate_do/animate_do.dart';
import 'package:cardiogram/colors.dart';
import 'package:cardiogram/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:cardiogram/services/firebase_service.dart';
import 'package:cardiogram/states/auth_state.dart';

import 'package:cardiogram/utils/error_dialog.dart';
import 'package:provider/provider.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        height: height,
        width: width,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 104, 180, 243),
              Color.fromRGBO(170, 141, 247, 1),
              Colors.blueAccent,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          child:
              Consumer<AuthStateProvider>(builder: (context, provider, child) {
            return Container(
                padding: EdgeInsets.symmetric(
                    horizontal: width * 0.1, vertical: height * 0.2),
                child: SignInContainer(provider: provider));
          }),
        ),
      ),
    );
  }
}

class SignInContainer extends StatefulWidget {

  final AuthStateProvider provider;
   SignInContainer({super.key, required this.provider});

  @override
  State<SignInContainer> createState() => _SignInContainerState();
}

class _SignInContainerState extends State<SignInContainer> {
  final deviceIdControlller = TextEditingController();

  final phoneNumberController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return FadeInDown(
      child: AnimatedContainer(
        height: 500,
        width: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: const LinearGradient(
            colors: [
              Colors.white,
              Color.fromARGB(255, 231, 229, 238),
              Color.fromARGB(255, 213, 197, 239),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        duration: Duration(milliseconds: 3000),
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          SizedBox(
            height: 50,
          ),
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            child: SvgPicture.asset(
              'assets/icons/user.svg',
              height: 50,
              width: 50,
              color: secondaryColor,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          AppText(
            text: "Sign In",
            color: textColor,
            fontsize: 18,
          ),
          SizedBox(
            height: 20,
          ),
          CurvedTextFields(
              hintText: 'Enter device ID',
              icon: Icon(
                Icons.email,
                color: primaryColor,
              ),
              obscureText: false,
              keyboardType: TextInputType.name,
              controller: deviceIdControlller,
              width: width * 0.7,
              height: 50),
          SizedBox(
            height: 20,
          ),
          CurvedTextFields(
              hintText: "enter phone number",
              icon: Icon(
                Icons.phone,
                color: secondaryColor,
              ),
              obscureText: false,
              keyboardType: TextInputType.number,
              controller: phoneNumberController,
              width: width * 0.7,
              height: 50),
          SizedBox(
            height: 10,
          ),
          ElevatedButton.icon(
            icon: Icon(
              FontAwesomeIcons.google,
              size: 20,
            ),
            onPressed: () async {
              final String res = await FirebaseService().signInWithGoogle(
                  deviceIdControlller.text, phoneNumberController.text);
              if (res == 'SUCCESS') {
              } else {
                ErrorDialog.showErrorDialog(context, res);
              }
              // provider.setAuthenticated(true
            },
            label: AppText(
              text: 'Sign in with Google',
              fontsize: 10,
            ),
          ),
        ]),
      ),
    );
  }
}

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
