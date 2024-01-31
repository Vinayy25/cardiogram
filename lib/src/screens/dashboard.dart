import 'package:cardiogram/services/firebase_service.dart';
import 'package:cardiogram/src/widgets/heart_chart.dart';
import 'package:cardiogram/states/auth_state.dart';
import 'package:cardiogram/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cardiogram/states/data_provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';

import '../animations/fade_in.dart';
import '../widgets/app_card.dart';
import '../widgets/increasing_text.dart';
import '../widgets/progress_with_text.dart';
import 'package:intl/intl.dart';

class DashBoardScreen extends StatefulWidget {
  const DashBoardScreen({super.key});

  @override
  State<DashBoardScreen> createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends State<DashBoardScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool showAlert = false;
    double w = (MediaQuery.sizeOf(context).width / 2) - 35;
    DateTime now = DateTime.now();
    var formatter = DateFormat('MMMM'); // For full month names
    var formattedMonth = formatter.format(now);
    var dateString = "${now.day} $formattedMonth ${now.year}";

    return Scaffold(
      // bottomSheet: BottomSheet(onClosing: (){}, builder:
      // (context) => Container(
      //   height: 100,
      //   color: Colors.deepPurple,

      //   ),
      // ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 70),
            FadeInAnimation(
              delay: 1,
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dateString,
                        style: TextStyle(fontSize: 18),
                      ),
                      Text(
                        "My Day",
                        style: TextStyle(fontSize: 34),
                      ),
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    onLongPress: () {},
                    onTap: () {},
                    child: SizedBox(
                      child: Hero(
                        tag: const Key('image'),
                        child: Container(
                          decoration: const ShapeDecoration(
                            shape: StarBorder(
                              innerRadiusRatio: .9,
                              pointRounding: .2,
                              points: 10,
                            ),
                          ),
                          child: Consumer<AuthStateProvider>(
                              builder: (context, provider, child) {
                            return ElevatedButton.icon(
                                onPressed: () async => provider.logoutAll(),
                                icon: const Icon(FontAwesomeIcons.signOut),
                                label: const AppText(
                                  text: "Logout",
                                ));
                          }),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: w,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FadeInAnimation(
                        delay: 1.5,
                        child: Consumer<DataProvider>(
                            builder: (context, value, child) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => RealTimeChart(
                                          title: 'Oxygen Chart',
                                          data: value.oxygen,
                                          spots: value.oxygenSpots)));
                            },
                            child: AppCard(
                              height: 250,
                              child: Column(
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Text(
                                        "SPO",
                                        style: TextStyle(fontSize: 18),
                                      ),
                                      Text('2', style: TextStyle(fontSize: 15)),
                                      const Spacer(),
                                      SizedBox(
                                        height: 30,
                                        width: 30,

                                        child: Image.asset(
                                          'assets/images/molecule.png',
                                          color: Colors.deepPurple,
                                        ),

                                        // child: Image.asset(
                                        //   'assets/icons/footprints.png',
                                        //   color: Colors.deepPurple,
                                        // ),
                                      ),
                                    ],
                                  ),
                                  Expanded(
                                    child: Center(
                                      child: AppText(
                                        fontsize: 30,
                                        text: value.oxygen.toString(),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 30),
                      FadeInAnimation(
                        delay: 2,
                        child: AppCard(
                          height: 500,
                          color: Colors.deepPurple,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "Notification",
                                    style: TextStyle(
                                        fontSize: 15, color: Colors.white),
                                  ),
                                  Spacer(),
                                  Icon(Icons.favorite, color: Colors.white),
                                ],
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Consumer<DataProvider>(
                                        builder: (context, provider, child) {
                                      String myText = "";

                                      if (provider.heartRiskLog.isNotEmpty &&
                                          provider.heartRisk) {
                                        myText += "Heart Risk:\n";
                                        provider.heartRiskLog
                                            .forEach((element) {
                                          myText += element + "\n";
                                        });
                                      }

                                      if (provider.oxygenRiskLog.isNotEmpty &&
                                          provider.oxygenRisk) {
                                        myText += "\nOxygen Risk:\n";
                                        provider.oxygenRiskLog
                                            .forEach((element) {
                                          myText += element + "\n";
                                        });
                                      }

                                      if (provider
                                              .temperatureRiskLog.isNotEmpty &&
                                          provider.temperatureRisk) {
                                        myText += "\nTemperature Risk:\n";
                                        provider.temperatureRiskLog
                                            .forEach((element) {
                                          myText += element + "\n";
                                        });
                                      }
                                      if (myText != "") {
                                        myText += "\nPlease consult a doctor";
                                      }

                                      return Column(
                                        children: [
                                          AppText(
                                            text: myText,
                                            color: Colors.white,
                                          ),
                                          ElevatedButton(
                                              onPressed: () {
                                                myText = "";
                                                provider.heartRisk = false;
                                                provider.oxygenRisk = false;
                                                provider.temperatureRisk =
                                                    false;
                                                provider.heartRiskLog = [];
                                                provider.oxygenRiskLog = [];
                                                provider.temperatureRiskLog =
                                                    [];
                                              },
                                              child: AppText(
                                                text: 'ok',
                                              ))
                                        ],
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      FadeInAnimation(
                        delay: 2.5,
                        child: AppCard(
                          height: 250,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text("Water"),
                                  const Spacer(),
                                  SizedBox(
                                    height: 30,
                                    width: 30,
                                    child: Image.asset(
                                      'assets/icons/waterdrop.png',
                                      color: Colors.deepPurple,
                                    ),
                                  ),
                                ],
                              ),
                              Expanded(
                                child: Center(
                                  child: Image.asset(
                                    'assets/icons/glass-of-water.png',
                                    height: 50,
                                  ),
                                ),
                              ),
                              const IncreasingText(
                                2,
                                isSingle: true,
                                style: TextStyle(
                                  fontSize: 32,
                                ),
                              ),
                              const Text(
                                "bottles",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: w,
                  child: Column(
                    children: [
                      FadeInAnimation(
                        delay: 1.5,
                        child: Consumer<DataProvider>(
                            builder: (context, provider, child) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => RealTimeChart(
                                          title: 'Heart Rate Chart',
                                          data: provider.heartRate,
                                          spots: provider.heartSpots)));
                            },
                            child: AppCard(
                              height: 300,
                              color: Colors.deepPurple,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Text(
                                        "Heart",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                      Spacer(),
                                      Icon(Iconsax.heart, color: Colors.white),
                                    ],
                                  ),
                                  Expanded(
                                    child: Image.asset(
                                      'assets/images/graph.png',
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    provider.heartRate.toString(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 32,
                                    ),
                                  ),
                                  const Text(
                                    "beats",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 30),
                      FadeInAnimation(
                        delay: 2,
                        child: Consumer<DataProvider>(
                            builder: (context, value, child) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => RealTimeChart(
                                          title: 'Temperature Chart',
                                          data: value.temperature,
                                          spots: value.temperatureSpots)));
                            },
                            child: AppCard(
                              height: 225,
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      const Text(
                                        'Temp °C',
                                        style: TextStyle(fontSize: 15),
                                      ),
                                      const Spacer(),
                                      SizedBox(
                                        height: 30,
                                        width: 30,
                                        child: Image.asset(
                                          'assets/icons/thunderbolt.png',
                                          color: const Color.fromRGBO(
                                              103, 58, 183, 1),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Expanded(
                                    child: Center(
                                      child: Text(
                                        value.temperature.toString(),
                                        style: TextStyle(
                                          fontSize: 32,
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 30),
                      const FadeInAnimation(
                        delay: 2.5,
                        child: AppCard(
                          height: 155,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "",
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  Spacer(),
                                  Icon(
                                    Iconsax.speedometer5,
                                    color: Colors.deepPurple,
                                  ),
                                ],
                              ),
                              Spacer(),
                              Text(
                                "0",
                                style: TextStyle(fontSize: 32),
                              ),
                              Text(
                                "min",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
