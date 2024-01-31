import 'package:cardiogram/src/screens/auth_screen.dart';
import 'package:cardiogram/src/screens/home_screen.dart';
import 'package:cardiogram/states/auth_state.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cardiogram/firebase_options.dart';
import 'package:cardiogram/states/data_provider.dart';
import 'package:provider/provider.dart';

import 'src/screens/dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthStateProvider()),
      ],
      child: MaterialApp(
        title: 'Cardiogram',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
          fontFamily: GoogleFonts.montserrat().fontFamily,
        ),
        home: const LandingPage(),
      ),
    );
  }
}

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthStateProvider>(builder: (context, provider, child) {
      return provider.isAuthenticated
          ? MultiProvider(providers: [
              ChangeNotifierProvider(create: (context) => DataProvider()),
            ], child: const DashBoardScreen())
          : const AuthScreen();
    });
  }
}
