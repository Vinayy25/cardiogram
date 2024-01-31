import 'package:flutter/material.dart';

// this is to show up alerts when the heartrate goes above 100 or below 60
class Alert extends StatelessWidget {
  const Alert({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Alert'),
      content: const Text('Heart rate is above 100 or below 60'),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Ok'),
        )
      ],
    );
  }
}
