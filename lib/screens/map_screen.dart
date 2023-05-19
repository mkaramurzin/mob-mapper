import 'package:flutter/material.dart';
import '../services/auth.dart';
import 'package:mobmapper/services/database.dart';
import 'package:mobmapper/models/map.dart';

class Map extends StatefulWidget {
  const Map({super.key});

  @override
  State<Map> createState() => _MapState();
}

class _MapState extends State<Map> {
  final AuthService _auth = AuthService();
  List mapOptions = ['silithus', 'ungoro'];
  Future<GameMap?>? map;
  List<GameMap>? userMaps;
  final List<Offset> _points = <Offset>[];

  @override
  void initState() {
    super.initState();
    // Fetch the map data
    map = Database(uid: _auth.user!.uid).map;
    updateMaps(); // Fetch maps
  }

  Future<void> updateMaps() async {
    userMaps = await Database(uid: _auth.user!.uid).allMaps;
  }

  void menuOption(int option) async {
    switch (option) {
      case 0:
        showDialog(
            context: context,
            builder: (context) {
              return Dialog(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.height * 0.8,
                  child: GridView.builder(
                    itemCount: mapOptions.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // adjust as needed
                    ),
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () async {
                          Navigator.of(context).pop();
                          await Database(uid: _auth.user!.uid).addMap(new GameMap(name: mapOptions[index], selection: mapOptions[index]));
                          setState(() {
                            map = Database(uid: _auth.user!.uid).map;
                          });
                          await updateMaps();  // Fetch maps again after adding new one
                        },
                        child: Image.asset(
                          'maps/${mapOptions[index]}.png',
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                ),
              );
            });
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
          MouseRegion(
            child: GestureDetector(
              onTap: () async {
                await updateMaps();
              },
              child: PopupMenuButton<GameMap>(
                tooltip: "",
                child: ElevatedButton(
                  onPressed: null, // Disable default action
                  child: Text('Maps', style: TextStyle(color: Colors.white)),
                ),
                onSelected: (GameMap result) {
                  setState(() {
                    map = Future.value(result);
                  });
                },
                itemBuilder: (BuildContext context) {
                  return (userMaps ?? []).map((GameMap map) {
                    return PopupMenuItem<GameMap>(
                      value: map,
                      child: Row(
                        children: <Widget>[
                          Image.asset(
                            'maps/${map.selection}.png',
                            width: 50,
                            height: 50,
                          ),
                          SizedBox(width: 20),
                          Text(map.name),
                        ],
                      ),
                    );
                  }).toList();
                },
              ),
            ),
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
      body: Container(
        constraints: BoxConstraints.expand(),
        child: Stack(
          children: <Widget>[
            FutureBuilder<GameMap?>(
              future: map,
              builder: (BuildContext context, AsyncSnapshot<GameMap?> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        '${snapshot.error} occurred',
                        style: TextStyle(fontSize: 18),
                      ),
                    );
                  } else if (snapshot.hasData) {
                    final map = snapshot.data!;
                    return Positioned.fill(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTapUp: (TapUpDetails details) {
                          setState(() {
                            _points.add(details.localPosition);
                          });
                          print('Point added: ${details.localPosition}');
                        },
                        child: Image.asset(
                          'maps/${map.selection}.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  } else {
                    // map is null
                    return Center(
                      child: ElevatedButton(
                        onPressed: () {
                          // Open the map popup
                          menuOption(0);
                        },
                        child: Text('Add Map'),
                      ),
                    );
                  }
                }
                return const CircularProgressIndicator();
              },
            ),
            ..._points.map(
              (Offset offset) => Positioned(
                left: offset.dx,
                top: offset.dy,
                child: IconButton(
                  icon: Icon(Icons.circle, color: Colors.red),
                  onPressed: () {
                    print('Clicked on point: $offset');
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
