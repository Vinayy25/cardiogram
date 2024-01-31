// import 'package:cardiogram/utils/utils.dart';
// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:cardiogram/states/auth_state.dart';
// import 'package:provider/provider.dart';

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final emailController = TextEditingController();
//     final height = MediaQuery.of(context).size.height;
//     final width = MediaQuery.of(context).size.width;
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Container(
//           height: height,
//           width: width,
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [
//                 const Color.fromARGB(255, 104, 180, 243),
//                 const Color.fromARGB(255, 170, 141, 247),
//                 Colors.blueAccent,
//               ],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//           child: Consumer<AuthStateProvider>(
//             builder: (context, provider, child) {
//               return Center(
//                 child: ElevatedButton.icon(
//                     onPressed: () async => provider.logoutAll(),
//                     icon: Icon(FontAwesomeIcons.signOut),
//                     label: AppText(
//                       text: "Logout",
//                     )),
//               );
//             },
//           )),
//     );
//   }
// }
