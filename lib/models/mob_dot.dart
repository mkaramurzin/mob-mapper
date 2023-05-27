import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MobDot {
  String docId;
  String mobName;
  String innerColor;
  String outerColor;
  int lowerBound;
  int upperBound;
  Timestamp lowerBoundTimestamp; // Add this line
  Timestamp upperBoundTimestamp; // Add this line
  List<Offset>? points;
  bool selected = false; // add this line

  MobDot(
      {this.docId = "",
      this.mobName = "",
      this.innerColor = "#000000",
      this.outerColor = "#000000",
      this.lowerBound = 0,
      this.upperBound = 0,
      required this.lowerBoundTimestamp,
      required this.upperBoundTimestamp,
      required this.points
    });
}
