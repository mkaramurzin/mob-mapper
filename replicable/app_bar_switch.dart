// import 'package:flutter/material.dart';
// import 'package:mobmapper/services/auth.dart';
// import 'package:mobmapper/services/database.dart';
// import 'package:mobmapper/models/map.dart';

// class Map extends StatefulWidget {
//   const Map({super.key});

//   @override
//   State<Map> createState() => _MapState();
// }

// class _MapState extends State<Map> {
//   final AuthService _auth = AuthService();
//   List mapOptions = ['silithus', 'ungoro'];
//   Future<GameMap?>? map;
//   List<GameMap>? userMaps;
//   final List<Offset> _points = <Offset>[];
//   bool _addingMob = false;
//   String _mobName = '';
//   TimeOfDay? _lowerBound;
//   TimeOfDay? _upperBound;

//   @override
//   void initState() {
//     super.initState();
//     // Fetch the map data
//     map = Database(uid: _auth.user!.uid).map;
//     updateMaps(); // Fetch maps
//   }

//   Future<void> updateMaps() async {
//     userMaps = await Database(uid: _auth.user!.uid).allMaps;
//   }

//   void _handleTap(TapUpDetails details) {
//     if (!_addingMob) return;

//     setState(() {
//       _points.add(details.localPosition);
//       _addingMob = false; // Reset the flag after adding a point
//     });

//     print('Point added: ${details.localPosition}');
//   }

//   Future<void> selectTime(BuildContext context, bool isLowerBound) async {
//     final TimeOfDay? pickedTime = await showTimePicker(
//       context: context,
//       initialTime: TimeOfDay.now(),
//     );
//     if (pickedTime != null) {
//       setState(() {
//         if (isLowerBound) {
//           _lowerBound = pickedTime;
//         } else {
//           _upperBound = pickedTime;
//         }
//       });
//     }
//   }

//   void menuOption(int option) async {
//     switch (option) {
//       case 0:
//         showDialog(
//             context: context,
//             builder: (context) {
//               return Dialog(
//                 child: Container(
//                   width: MediaQuery.of(context).size.width * 0.8,
//                   height: MediaQuery.of(context).size.height * 0.8,
//                   child: GridView.builder(
//                     itemCount: mapOptions.length,
//                     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: 2, // adjust as needed
//                     ),
//                     itemBuilder: (context, index) {
//                       return GestureDetector(
//                         onTap: () async {
//                           Navigator.of(context).pop();
//                           await Database(uid: _auth.user!.uid).addMap(
//                               new GameMap(
//                                   name: mapOptions[index],
//                                   selection: mapOptions[index]));
//                           setState(() {
//                             map = Database(uid: _auth.user!.uid).map;
//                           });
//                           await updateMaps(); // Fetch maps again after adding new one
//                         },
//                         child: Image.asset(
//                           'maps/${mapOptions[index]}.png',
//                           fit: BoxFit.cover,
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               );
//             });
//         break;
//       case 1:
//         print('b2');
//         break;
//       case 2:
//         await _auth.signOut();
//         Navigator.pushReplacementNamed(context, '/');
//         break;
//     }
//   }

//   AppBar buildAppBar(BuildContext context) {
//     if (_addingMob) {
//       return AppBar(
//         title: Text('Adding Mob'),
//         actions: [
//           Expanded(
//             child: Padding(
//               padding: EdgeInsets.all(8.0),
//               child: TextFormField(
//                 onChanged: (value) {
//                   _mobName = value;
//                 },
//                 decoration: InputDecoration(labelText: 'Mob Name'),
//               ),
//             ),
//           ),
//           IconButton(
//             icon: Icon(Icons.timer),
//             onPressed: () => selectTime(context, true),
//             tooltip: 'Select Lower Bound Time',
//           ),
//           IconButton(
//             icon: Icon(Icons.timer),
//             onPressed: () => selectTime(context, false),
//             tooltip: 'Select Upper Bound Time',
//           ),
//           ElevatedButton(
//             onPressed: () {
//               print('Done clicked');
//               // TODO: Implement logic to capture data
//               setState(() {
//                 _addingMob = false;
//               });
//             },
//             child: Text('Done'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               print('Cancel clicked');
//               // TODO: Implement logic to erase new dot
//               setState(() {
//                 _addingMob = false;
//                 if (_points.isNotEmpty) _points.removeLast();  // remove the last added point
//               });
//             },
//             child: Text('Cancel'),
//           ),
//         ],
//       );
//     } else {
//       return AppBar(
//         title: Text('Mob Mapper'),
//         actions: [
//           MouseRegion(
//             child: GestureDetector(
//               onTap: () async {
//                 await updateMaps();
//               },
//               child: PopupMenuButton<GameMap>(
//                 tooltip: "",
//                 child: ElevatedButton(
//                   onPressed: null, // Disable default action
//                   child: Text('Maps', style: TextStyle(color: Colors.white)),
//                 ),
//                 onSelected: (GameMap result) {
//                   setState(() {
//                     map = Future.value(result);
//                   });
//                 },
//                 itemBuilder: (BuildContext context) {
//                   return (userMaps ?? []).map((GameMap map) {
//                     return PopupMenuItem<GameMap>(
//                       value: map,
//                       child: Row(
//                         children: <Widget>[
//                           Image.asset(
//                             'maps/${map.selection}.png',
//                             width: 50,
//                             height: 50,
//                           ),
//                           SizedBox(width: 20),
//                           Text(map.name),
//                         ],
//                       ),
//                     );
//                   }).toList();
//                 },
//               ),
//             ),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               setState(() {
//                 _addingMob = true;
//               });
//             },
//             child: Text('Add Mob'),
//           ),
//           PopupMenuButton<int>(
//             icon: Icon(Icons.settings),
//             onSelected: (item) {
//               menuOption(item);
//               setState(() {});
//             },
//             position: PopupMenuPosition.under,
//             itemBuilder: (context) => [
//               PopupMenuItem(
//                 value: 0,
//                 child: Text("Add Map"),
//               ),
//               PopupMenuItem(
//                 value: 1,
//                 child: Text("Manage Maps"),
//               ),
//               PopupMenuDivider(),
//               PopupMenuItem(
//                 value: 2,
//                 child: Text("Sign Out"),
//               ),
//             ],
//           )
//         ],
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: buildAppBar(context),
//       body: Container(
//         constraints: BoxConstraints.expand(),
//         child: Stack(
//           children: <Widget>[
//             FutureBuilder<GameMap?>(
//               future: map,
//               builder:
//                   (BuildContext context, AsyncSnapshot<GameMap?> snapshot) {
//                 if (snapshot.connectionState == ConnectionState.done) {
//                   if (snapshot.hasError) {
//                     return Center(
//                       child: Text(
//                         '${snapshot.error} occurred',
//                         style: TextStyle(fontSize: 18),
//                       ),
//                     );
//                   } else if (snapshot.hasData) {
//                     final map = snapshot.data!;
//                     return Positioned.fill(
//                       child: GestureDetector(
//                         behavior: HitTestBehavior.opaque,
//                         onTapUp: _handleTap,
//                         child: Image.asset(
//                           'maps/${map.selection}.png',
//                           fit: BoxFit.contain,
//                         ),
//                       ),
//                     );
//                   } else {
//                     // map is null
//                     return Center(
//                       child: ElevatedButton(
//                         onPressed: () {
//                           // Open the map popup
//                           menuOption(0);
//                         },
//                         child: Text('Add Map'),
//                       ),
//                     );
//                   }
//                 }
//                 return const CircularProgressIndicator();
//               },
//             ),
//             ..._points.map(
//               (Offset offset) => Positioned(
//                   left: offset.dx - 10,
//                   top: offset.dy - 10,
//                   child: CircleAvatar(
//                     backgroundColor: Colors.blue,
//                     radius: 8,
//                     child: CircleAvatar(
//                       backgroundColor: Colors.green,
//                       radius: 5,
//                     ),
//                   )),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
