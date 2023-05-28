import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CountdownTimerWidget extends StatefulWidget {
  Timestamp lowerBoundTimestamp;
  Timestamp upperBoundTimestamp;
  bool show;
  String mobName;
  final Function() reset;

  CountdownTimerWidget(
      {required this.lowerBoundTimestamp,
      required this.upperBoundTimestamp,
      required this.show,
      required this.mobName,
      required this.reset});

  @override
  _CountdownTimerWidgetState createState() => _CountdownTimerWidgetState();
}

class _CountdownTimerWidgetState extends State<CountdownTimerWidget> {
  late Duration lowerBoundRemaining;
  late Duration upperBoundRemaining;
  Timer? lowerBoundTimer;
  Timer? upperBoundTimer;

  @override
  void initState() {
    super.initState();
    // calculate initial remaining duration
    lowerBoundRemaining =
        widget.lowerBoundTimestamp.toDate().difference(DateTime.now());
    upperBoundRemaining =
        widget.upperBoundTimestamp.toDate().difference(DateTime.now());
    startTimers();
  }

  @override
  void didUpdateWidget(covariant CountdownTimerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.lowerBoundTimestamp != widget.lowerBoundTimestamp ||
        oldWidget.upperBoundTimestamp != widget.upperBoundTimestamp) {
      // Timestamps changed
      lowerBoundTimer?.cancel();
      upperBoundTimer?.cancel();
      startTimers();
    }
  }

  void startTimers() {
    // calculate remaining duration
    lowerBoundRemaining =
        widget.lowerBoundTimestamp.toDate().difference(DateTime.now());
    upperBoundRemaining =
        widget.upperBoundTimestamp.toDate().difference(DateTime.now());

    // lowerBound timer
    lowerBoundTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (lowerBoundRemaining.inSeconds == 0) {
        timer.cancel();
      } else {
        setState(() {
          lowerBoundRemaining -= Duration(seconds: 1);
        });
      }
    });

    // upperBound timer
    upperBoundTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (upperBoundRemaining.inSeconds == 0) {
        timer.cancel();
      } else {
        setState(() {
          upperBoundRemaining -= Duration(seconds: 1);
        });
      }
    });
  }

  @override
  void dispose() {
    lowerBoundTimer?.cancel();
    upperBoundTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.show) {
      return Container(); // Return an empty container if show is false
    }

    return Row(
      children: [
        Container(
          margin: EdgeInsets.fromLTRB(0, 0, 20, 0),
          child: Text(
            widget.mobName,
          ),
        ),
        Text(formatDuration(lowerBoundRemaining)),
        Container(
          margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: Center(child: Text('-')),
        ),
        Text(formatDuration(upperBoundRemaining)),
        SizedBox(
          width: 25,
        ),
        IconButton(onPressed: widget.reset, icon: Icon(Icons.refresh), tooltip: 'Restart Timers',)
      ],
    );
  }

  String formatDuration(Duration d) {
    String f(int n) {
      return n.toString().padLeft(2, '0');
    }

    return "${f(d.inHours)}:${f(d.inMinutes.remainder(60))}:${f(d.inSeconds.remainder(60))}";
  }
}
