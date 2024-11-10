import 'dart:async';
import 'package:cardiogram/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class RealTimeChart extends StatefulWidget {
  final String title;
  final int data;
  List<FlSpot> spots;

  RealTimeChart(
      {super.key,
      required this.title,
      required this.data,
      required this.spots});

  @override
  State<RealTimeChart> createState() => _RealTimeChartState();
}

class _RealTimeChartState extends State<RealTimeChart> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      // Trigger an update every second
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Dispose the timer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            )),
        backgroundColor: Colors.deepPurple,
        title: AppText(
          text: widget.title,
          color: Colors.white,
        ),
      ),
      body: Container(
        color: Colors.white60,
        height: MediaQuery.of(context).size.height * 0.5,
        child: LineChart(
          LineChartData(
            backgroundColor: Colors.white60,
            borderData: FlBorderData(show: false),
            maxX: 27,
            maxY: 150,
            minY: 5,
            extraLinesData: ExtraLinesData(horizontalLines: [
              HorizontalLine(
                y: 60,
                color: Colors.red,
                strokeWidth: 2,
                dashArray: [10, 5],
              ),
              HorizontalLine(
                y: 120,
                color: Colors.red,
                strokeWidth: 2,
                dashArray: [10, 5],
              ),
            ]),
            lineBarsData: [
              LineChartBarData(
                barWidth: 1,
                curveSmoothness: 0.1,
                isStrokeCapRound: true,
                showingIndicators: [widget.data],
                gradient: LinearGradient(
                  colors: [
                    Colors.deepPurple.shade300,
                    Colors.deepPurple.shade500,
                    Colors.black
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                color: Colors.white,
                spots: widget.spots,
                isCurved: true,
                belowBarData: BarAreaData(show: true),
                dotData: FlDotData(show: false),
              ),
            ],
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(axisNameWidget: Text(widget.title)),
              bottomTitles: AxisTitles(axisNameWidget: Text('time')),
            ),
            gridData: FlGridData(show: false),
          ),
        ),
      ),
    );
  }
}

class PreviewChart extends StatefulWidget {
  final int data;
  final List<FlSpot> spots;

  const PreviewChart({super.key, required this.data, required this.spots});

  @override
  State<PreviewChart> createState() => _PreviewChartState();
}

class _PreviewChartState extends State<PreviewChart> {
  @override
  Widget build(BuildContext context) {
    return Container(
      // No decoration to remove container border
      // height: MediaQuery.of(context).size.height * 0.5,
      child: LineChart(
        LineChartData(
          backgroundColor: Colors.transparent,
          // borderData: FlBorderData(show: true),
          // maxX: 27,
          // maxY: 150,
          // minY: 5,
          // extraLinesData: ExtraLinesData(horizontalLines: []),
          lineBarsData: [
            LineChartBarData(
              show: true,
              barWidth: 1,
              aboveBarData: BarAreaData(show: false, color: Colors.transparent),
              belowBarData: BarAreaData(show: false, color: Colors.transparent),
              isStepLineChart: false,
              curveSmoothness: 0.2,
              isStrokeCapRound: true,
              showingIndicators: [widget.data],
              gradient: const LinearGradient(
                colors: [
                  Colors.white,
                  Colors.white10,
                  Colors.black,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              color: Colors.transparent, // Also makes line transparent
              spots: widget.spots,
              isCurved: true,
              dotData: FlDotData(
                show: false,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 6,
                    color: Colors.black,
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                },
              ),
            ),
          ],
          titlesData: const FlTitlesData(show: false),
          gridData: const FlGridData(show: false),
        ),
      ),
    );
  }
}
