import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ControlledColorPickerWidget extends StatefulWidget {
  final String initialInnerColor;
  final String initialOuterColor;
  final Function(String) onInnerColorChanged;
  final Function(String) onOuterColorChanged;

  ControlledColorPickerWidget({
    required this.initialInnerColor,
    required this.initialOuterColor,
    required this.onInnerColorChanged,
    required this.onOuterColorChanged,
  });

  @override
  _ControlledColorPickerWidgetState createState() =>
      _ControlledColorPickerWidgetState();
}

class _ControlledColorPickerWidgetState extends State<ControlledColorPickerWidget> {
  late String _selectedInnerColor;
  late String _selectedOuterColor;

  @override
  void initState() {
    super.initState();
    _selectedInnerColor = widget.initialInnerColor;
    _selectedOuterColor = widget.initialOuterColor;
  }

  void randomizeColors() {
    setState(() {
      _selectedInnerColor =
          '#' +
          Colors.primaries[Random().nextInt(Colors.primaries.length)].value
              .toRadixString(16)
              .substring(2)
              .toUpperCase();
      _selectedOuterColor =
          '#' +
          Colors.accents[Random().nextInt(Colors.accents.length)].value
              .toRadixString(16)
              .substring(2)
              .toUpperCase();
      widget.onInnerColorChanged(_selectedInnerColor);
      widget.onOuterColorChanged(_selectedOuterColor);
    });
  }

  void _showColorPickerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: Color(int.parse(_selectedInnerColor.replaceAll('#', '0xFF'))),
              onColorChanged: (Color color) {
                setState(() {
                  _selectedInnerColor = '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
                });
                widget.onInnerColorChanged(_selectedInnerColor);
              },
              showLabel: true,
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showBackgroundColorPickerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a background color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: Color(int.parse(_selectedOuterColor.replaceAll('#', '0xFF'))),
              onColorChanged: (Color color) {
                setState(() {
                  _selectedOuterColor = '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
                });
                widget.onOuterColorChanged(_selectedOuterColor);
              },
              showLabel: true,
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        InkWell(
          onTap: _showColorPickerDialog,
          child: Container(
            width: 15,
            height: 15,
            decoration: BoxDecoration(
              color: Color(int.parse(_selectedInnerColor.replaceAll('#', '0xFF'))),
            ),
          ),
        ),
        SizedBox(
          width: 10,
        ),
        InkWell(
          onTap: _showBackgroundColorPickerDialog,
          child: Container(
            width: 15,
            height: 15,
            decoration: BoxDecoration(
              color: Color(int.parse(_selectedOuterColor.replaceAll('#', '0xFF'))),
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.refresh),
          onPressed: randomizeColors,
        ),
      ],
    );
  }
}
