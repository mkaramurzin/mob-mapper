import 'package:flutter/material.dart';
import '../services/auth.dart';

class Map extends StatefulWidget {
  const Map({super.key});

  @override
  State<Map> createState() => _MapState();
}

class _MapState extends State<Map> {
  final AuthService _auth = AuthService();

  void menuOption(int option) async {
    switch (option) {
      case 0:
        print('b1');
        break;

      case 1:
        print('b2');
        break;

      case 2:
        await _auth.signOut();
        Navigator.pushReplacementNamed(context, '/');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mob Mapper'),
        actions: [
          ElevatedButton(
            onPressed: () {
              print('Maps clicked');
            },
            child: Text('Maps'),
          ),
          ElevatedButton(
            onPressed: () {
              print('Add Mob clicked');
            },
            child: Text('Add Mob'),
          ),
          PopupMenuButton<int>(
            icon: Icon(Icons.settings),
            onSelected: (item) {
              menuOption(item);
              setState(() {});
            },
            position: PopupMenuPosition.under,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 0,
                child: Text("Add Map"),
              ),
              PopupMenuItem(
                value: 1,
                child: Text("Manage Maps"),
              ),
              PopupMenuDivider(),
              PopupMenuItem(
                value: 2,
                child: Text("Sign Out"),
              ),
            ],
          )
        ],
      ),
    );
  }
}
