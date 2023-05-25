import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobmapper/models/map.dart';
import 'package:mobmapper/models/mob_dot.dart';
import 'package:flutter/material.dart';

class Database {
  final String uid;
  Database({required this.uid});

  // collection references
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');

  Future<void> setUserData() async {}

  Future<void> addMap(GameMap map) async {
    final DocumentReference docRef = await userCollection
        .doc(uid)
        .collection("maps")
        .add({"selection": map.name, "name": map.selection});

    final String docId = docRef.id;
    await userCollection.doc(uid).set({"currentMap": docId});
  }

  Future<GameMap?> get map async {
    DocumentSnapshot snapshot = await userCollection.doc(uid).get();
    if (!snapshot.exists || snapshot.get('currentMap') == null) {
      // The 'currentMap' field doesn't exist or is null
      return null;
    }
    String docId = await snapshot.get('currentMap');
    snapshot =
        await userCollection.doc(uid).collection('maps').doc(docId).get();
    return new GameMap(
        name: snapshot.get('name'), selection: snapshot.get('selection'));
  }

  

  Future<List<GameMap>> get allMaps async {
    QuerySnapshot querySnapshot =
        await userCollection.doc(uid).collection('maps').get();
    return querySnapshot.docs.map((doc) {
      return GameMap(name: doc.get('name'), selection: doc.get('selection'));
    }).toList();
  }

  Future<void> addDot(MobDot dot) async {
    DocumentSnapshot snapshot = await userCollection.doc(uid).get();
    if (!snapshot.exists || snapshot.get('currentMap') == null) {
      // The 'currentMap' field doesn't exist or is null
      return null;
    }
    String docId = await snapshot.get('currentMap');
    List<Map<String, double>> convertedPoints = dot.points!.map((offset) {
      return {'x': offset.dx, 'y': offset.dy};
    }).toList();
    await userCollection
        .doc(uid)
        .collection('maps')
        .doc(docId)
        .collection('dots')
        .add({
      'mobName': dot.mobName,
      'innerColor': dot.innerColor,
      'outerColor': dot.outerColor,
      'lowerBound': dot.lowerBound,
      'upperBound': dot.upperBound,
      'points': convertedPoints,
    });
  }

  Future<List<MobDot>> getAllDots() async {
    DocumentSnapshot snapshot = await userCollection.doc(uid).get();
    if (!snapshot.exists || snapshot.get('currentMap') == null) {
      // The 'currentMap' field doesn't exist or is null
      return [];
    }
    String docId = snapshot.get('currentMap');
    QuerySnapshot querySnapshot = await userCollection
        .doc(uid)
        .collection('maps')
        .doc(docId)
        .collection('dots')
        .get();

    if (querySnapshot.docs.isEmpty) {
      return [];
    }

    return querySnapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      List<Offset> points = [];
      if (data['points'] != null) {
        points = List<Map<String, dynamic>>.from(data['points'])
            .map((pointMap) => Offset((pointMap['x'] as num).toDouble(),
                (pointMap['y'] as num).toDouble()))
            .toList();
      }  

      return MobDot(
          mobName: data['mobName'],
          innerColor: data['innerColor'],
          outerColor: data['outerColor'],
          lowerBound: data['lowerBound'],
          upperBound: data['upperBound'],
          points: points);
    }).toList();
  }
}
