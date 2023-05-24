import 'package:flutter/material.dart';
import 'package:mobmapper/models/mob_dot.dart';
import 'package:mobmapper/services/auth.dart';
import 'package:mobmapper/services/database.dart';
import 'package:mobmapper/models/map.dart';
import 'package:mobmapper/widgets/add_mob_bar.dart';
import 'package:mobmapper/services/color_extension.dart';

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
  List<MobDot> _points = [];
  List<Offset> _tempPoints = <Offset>[];
  bool _addingMob = false;

  @override
  void initState() {
    super.initState();
    // Fetch the map data
    map = Database(uid: _auth.user!.uid).map;
    updateMaps(); // Fetch maps
    updateDots(); // Fetch dots
  }

  Future<void> updateMaps() async {
    userMaps = await Database(uid: _auth.user!.uid).allMaps;
  }

  Future<void> updateDots() async {
    _points = await Database(uid: _auth.user!.uid).getAllDots();
    // _points = dots.expand((dot) => dot.points!).toList();
    setState(() {}); // Update the state to trigger a rebuild
  }

  void _handleTap(TapUpDetails details) {
    if (!_addingMob) return;

    setState(() {
      _tempPoints.add(details.localPosition);
    });
  }

  PreferredSizeWidget buildAppBar(BuildContext context) {
    if (_addingMob) {
      return AddMobAppBar(
        onCancel: () {
          setState(() {
            _addingMob = false;
            _tempPoints.clear();
          });
        },
        onDone: (mobName, innerColor, outerColor, lowerBound, upperBound, points) async {
          print(mobName);
          print(lowerBound);
          print(upperBound);
          var mobDot = MobDot(
              mobName: mobName,
              innerColor: innerColor,
              outerColor: outerColor,
              lowerBound: lowerBound,
              upperBound: upperBound,
              points: _tempPoints
          );
          await Database(uid: _auth.user!.uid).addDot(mobDot);
          setState(() {
              _addingMob = false;
              _points.add(mobDot); // add the new mob to the list of MobDots
              _tempPoints.clear();
          });
          updateDots(); // Fetch dots after adding a new mob
        },
        points: _tempPoints,
      );
    } else {
      return AppBar(
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
                    updateDots(); // Fetch dots for the new map
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
              setState(() {
                _addingMob = true;
              });
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
      );
    }
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
                          await Database(uid: _auth.user!.uid).addMap(
                              new GameMap(
                                  name: mapOptions[index],
                                  selection: mapOptions[index]));
                          setState(() {
                            map = Database(uid: _auth.user!.uid).map;
                          });
                          await updateMaps(); // Fetch maps again after adding new one
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

  Widget _buildPoint(MobDot? dot, Offset offset) {
    Color outerColor = dot != null ? dot.outerColor.toColor() : Colors.blue;
    Color innerColor = dot != null ? dot.innerColor.toColor() : Colors.green;

    return Positioned(
      left: offset.dx - 10,
      top: offset.dy - 10,
      child: CircleAvatar(
        backgroundColor: outerColor,
        radius: 8,
        child: CircleAvatar(
          backgroundColor: innerColor,
          radius: 5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: Container(
        constraints: BoxConstraints.expand(),
        child: Stack(
          children: <Widget>[
            FutureBuilder<GameMap?>(
              future: map,
              builder:
                  (BuildContext context, AsyncSnapshot<GameMap?> snapshot) {
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
                        onTapUp: _handleTap,
                        child: Image.asset(
                          'maps/${map.selection}.png',
                          fit: BoxFit.contain,
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
            ..._points.expand((dot) => dot.points!.map((offset) => _buildPoint(dot, offset))).toList(),
            ..._tempPoints.map((Offset offset) => _buildPoint(null, offset)).toList(),
          ],
        ),
      ),
    );
  }
}
