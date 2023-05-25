import 'package:flutter/material.dart';

class MobDot {
  String mobName;
  String innerColor;
  String outerColor;
  int lowerBound;
  int upperBound;
  List<Offset>? points;
  bool selected = false;  // add this line

  MobDot(
      {this.mobName = "",
      this.innerColor = "#000000",
      this.outerColor = "#000000",
      this.lowerBound = 0,
      this.upperBound = 0,
      required this.points}
  );
}
