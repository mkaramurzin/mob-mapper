import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobmapper/widgets/color_picker.dart';

class AddMobAppBar extends StatefulWidget implements PreferredSizeWidget {
  final Function() onCancel;
  final Function(String?, String?, String?, int?, int?, List<Offset> points) onDone;
  final List<Offset> points;

  AddMobAppBar({
    required this.onCancel,
    required this.onDone,
    required this.points,
    Key? key,
  })  : preferredSize = Size.fromHeight(kToolbarHeight),
        super(key: key);

  @override
  final Size preferredSize;

  @override
  _AddMobAppBarState createState() => _AddMobAppBarState();
}

class _AddMobAppBarState extends State<AddMobAppBar> {
  late TextEditingController _mobNameController;
  final _formKey = GlobalKey<FormState>();
  final _hoursController1 = TextEditingController();
  final _minutesController1 = TextEditingController();
  final _hoursController2 = TextEditingController();
  final _minutesController2 = TextEditingController();
  String innerColor = '#000000';
  String outerColor = '#000000';

  @override
  void initState() {
    super.initState();
    _mobNameController = TextEditingController();
  }

  @override
  void dispose() {
    _mobNameController.dispose();
    _hoursController1.dispose();
    _minutesController1.dispose();
    _hoursController2.dispose();
    _minutesController2.dispose();
    super.dispose();
  }

  int combineTime(int hours, int minutes) {
    while (hours > 0) {
      minutes += 60;
      hours--;
    }
    return minutes;
  }

  void onInnerColorChanged(String color) {
    setState(() {
      innerColor = color;
    });
  }

  void onOuterColorChanged(String color) {
    setState(() {
      outerColor = color;
    });
  }

  void _validateAndSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      final hour1 = int.tryParse(_hoursController1.text);
      final minute1 = int.tryParse(_minutesController1.text);
      final hour2 = int.tryParse(_hoursController2.text);
      final minute2 = int.tryParse(_minutesController2.text);

      if (hour1 != null && minute1 != null && hour2 != null && minute2 != null) {
        int lowerBound = combineTime(hour1, minute1);
        int upperBound = combineTime(hour2, minute2);
        widget.onDone(_mobNameController.text, innerColor, outerColor, lowerBound, upperBound, widget.points);
      } else {
        print('Invalid input in time fields');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text('Adding Mob'),
      actions: [
        Form(
          key: _formKey,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 250,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: TextFormField(
                    cursorColor: Colors.white,
                    controller: _mobNameController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Mob Name',
                      labelStyle: TextStyle(color: Colors.white),
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      errorStyle: TextStyle(height: 10),
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10,0,10,0),
                child: Text('Spawn Window from '),
              ),
              Row(
                children: [
                  Container(
                    width: 50,
                    child: TextFormField(
                      cursorColor: Colors.white,
                      controller: _hoursController1,
                      style: TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        labelText: 'H',
                        labelStyle: TextStyle(color: Colors.white),
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                      validator: (value) {
                        final hour = int.tryParse(value ?? '');
                        if (hour == null || hour < 0) {
                          return 'Hours';
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Text(':'),
                  ),
                  Container(
                    width: 50,
                    child: TextFormField(
                      cursorColor: Colors.white,
                      controller: _minutesController1,
                      style: TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        labelText: 'M',
                        labelStyle: TextStyle(color: Colors.white),
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                      validator: (value) {
                        final minute = int.tryParse(value ?? '');
                        if (minute == null || minute < 0 || minute > 59) {
                          return '0 - 59';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(6.0),
                child: Text('to'),
              ),
              Row(
                children: [
                  Container(
                    width: 50,
                    child: TextFormField(
                      cursorColor: Colors.white,
                      controller: _hoursController2,
                      style: TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        labelText: 'H',
                        labelStyle: TextStyle(color: Colors.white),
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                      validator: (value) {
                        final hour = int.tryParse(value ?? '');
                        if (hour == null || hour < 0) {
                          return 'Hours';
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Text(':'),
                  ),
                  Container(
                    width: 50,
                    child: TextFormField(
                      cursorColor: Colors.white,
                      controller: _minutesController2,
                      style: TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        labelText: 'M',
                        labelStyle: TextStyle(color: Colors.white),
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                      validator: (value) {
                        final minute = int.tryParse(value ?? '');
                        if (minute == null || minute < 0 || minute > 59) {
                          return '0 - 59';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(width: 10)
            ],
          ),
        ),
        ControlledColorPickerWidget(
          initialInnerColor: innerColor,
          initialOuterColor: outerColor,
          onInnerColorChanged: onInnerColorChanged,
          onOuterColorChanged: onOuterColorChanged,
        ),
        ElevatedButton(
          onPressed: _validateAndSubmit,
          child: Text('Done'),
        ),
        ElevatedButton(
          onPressed: widget.onCancel,
          child: Text('Cancel'),
        ),
      ],
    );
  }
}
