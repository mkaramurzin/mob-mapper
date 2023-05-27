import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mobmapper/models/mob_dot.dart';
import 'package:mobmapper/services/auth.dart';
import 'package:mobmapper/services/database.dart';
import 'package:mobmapper/models/map.dart';
import 'package:mobmapper/widgets/add_mob_bar.dart';
import 'package:mobmapper/services/color_extension.dart';
import 'package:mobmapper/widgets/timer.dart';

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
  MobDot? _selectedDot;
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
    if (mounted) {
      setState(() {}); // Update the state to trigger a rebuild
    }
  }

  void _handleTap(TapUpDetails details) {
    if (!_addingMob) return;

    if (mounted) {
      setState(() {
        _tempPoints.add(details.localPosition);
      });
    }
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
        onDone: (mobName, innerColor, outerColor, lowerBound, upperBound,
            points) async {
          print(mobName);
          print(lowerBound);
          print(upperBound);

          final Timestamp now = Timestamp.now();
          final Timestamp lowerBoundTimestamp =
              Timestamp(now.seconds + lowerBound * 60, now.nanoseconds);
          final Timestamp upperBoundTimestamp =
              Timestamp(now.seconds + upperBound * 60, now.nanoseconds);
          var mobDot = MobDot(
              mobName: mobName,
              innerColor: innerColor,
              outerColor: outerColor,
              lowerBound: lowerBound,
              upperBound: upperBound,
              lowerBoundTimestamp: lowerBoundTimestamp,
              upperBoundTimestamp: upperBoundTimestamp,
              points: _tempPoints);
          mobDot.docId = await Database(uid: _auth.user!.uid).addDot(mobDot);
          print(mobDot.docId);
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
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Your App Title'),
            Text(
              _selectedDot?.mobName ?? '',
              style: TextStyle(
                fontSize: 18.0,
                color: Colors.white,
              ),
            ),
            CountdownTimerWidget(
                lowerBoundTimestamp:
                    _selectedDot?.lowerBoundTimestamp ?? Timestamp.now(),
                upperBoundTimestamp:
                    _selectedDot?.upperBoundTimestamp ?? Timestamp.now()),
            IconButton(
              onPressed: () {
                if(_selectedDot != null) {
                  setState(() async {
                    await Database(uid: _auth.user!.uid)
                    .updateTimestamps(_selectedDot!);
                  });
                }
              },
              icon: Icon(Icons.refresh),
            ),
            // This empty container serves to keep the mob name centered.
            Container(
              width: MediaQuery.of(context).size.width * 0.2,
            ),
          ],
        ),
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
                onSelected: (GameMap result) async {
                  setState(() {
                    map = Future.value(result);
                    updateDots(); // Fetch dots for the new map
                  });
                  await Database(uid: _auth.user!.uid)
                      .setUserData({"currentMap": result.docId});
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
                          await Database(uid: _auth.user!.uid)
                              .addMap(mapOptions[index]);
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

  Widget _buildPoint(MobDot? dot, Offset offset, bool selected) {
    Color outerColor = dot != null ? dot.outerColor.toColor() : Colors.black;
    Color innerColor = dot != null ? dot.innerColor.toColor() : Colors.black;

    return Positioned(
      left: offset.dx - 10,
      top: offset.dy - 10,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedDot = dot;
          });
        },
        child: Material(
          borderRadius: BorderRadius.circular(8),
          elevation:
              selected ? 10.0 : 0.0, // Higher elevation for selected dots
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: outerColor,
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: Colors.yellow.withOpacity(1.0),
                        spreadRadius: 3,
                        blurRadius: 7,
                        offset: Offset(0, 0), // changes position of shadow
                      ),
                    ]
                  : [], // Show glow effect only for selected dots
            ),
            child: Opacity(
              opacity:
                  selected ? 1.0 : 0.8, // Lower opacity for non-selected dots
              child: CircleAvatar(
                backgroundColor: outerColor,
                radius: 8,
                child: CircleAvatar(
                  backgroundColor: innerColor,
                  radius: 5,
                ),
              ),
            ),
          ),
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
                return const Center(child: CircularProgressIndicator());
              },
            ),
            ..._points
                .expand((dot) => dot.points!.map(
                    (offset) => _buildPoint(dot, offset, dot == _selectedDot)))
                .toList(),
            ..._tempPoints
                .map((Offset offset) => _buildPoint(null, offset, false))
                .toList(),
          ],
        ),
      ),
    );
  }
}
