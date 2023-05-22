import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddMobAppBar extends StatefulWidget implements PreferredSizeWidget {
  final Function() onCancel;
  final Function(String, TimeOfDay?, TimeOfDay?, List<Offset> points) onDone;
  final List<Offset> points;

  AddMobAppBar({required this.onCancel, required this.onDone, required this.points, Key? key})
      : preferredSize = Size.fromHeight(kToolbarHeight),
        super(key: key);

  @override
  final Size preferredSize;

  @override
  _AddMobAppBarState createState() => _AddMobAppBarState();
}

class _AddMobAppBarState extends State<AddMobAppBar> {
  late TextEditingController _mobNameController;
  final _hoursController = TextEditingController();
  final _minutesController = TextEditingController();

  

  @override
  void initState() {
    super.initState();
    _mobNameController = TextEditingController();
  }

  @override
  void dispose() {
    _mobNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text('Adding Mob'),
      actions: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 250,
              height: 50,
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
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text('Spawn Window from '),
            ),
            Row(
            children: [
              Container(
                width: 50,
                child: TextFormField(
                  cursorColor: Colors.white,
                  controller: _hoursController,
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
                      return 'Enter a valid hour value';
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
                  controller: _minutesController,
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
                      return 'Enter a valid minute between 0 and 59';
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
                  controller: _hoursController,
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
                      return 'Enter a valid hour value';
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
                  controller: _minutesController,
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
                      return 'Enter a valid minute between 0 and 59';
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
        ElevatedButton(
          onPressed: () {
            // widget.onDone(_mobNameController.text, _lowerBound, _upperBound, widget.lastPoint);
          },
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
