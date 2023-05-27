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

  Future<void> setUserData(Map<String, dynamic> userData) async {
    await userCollection.doc(uid).set(userData, SetOptions(merge: true));
  }

  Future<void> addMap(String selection) async {
    final DocumentReference docRef = await userCollection
        .doc(uid)
        .collection("maps")
        .add({"selection": selection, "name": selection});

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
        name: snapshot.get('name'),
        selection: snapshot.get('selection'),
        docId: docId);
  }

  Future<List<GameMap>> get allMaps async {
    QuerySnapshot querySnapshot =
        await userCollection.doc(uid).collection('maps').get();
    return querySnapshot.docs.map((doc) {
      return GameMap(
          name: doc.get('name'),
          selection: doc.get('selection'),
          docId: doc.id);
    }).toList();
  }

  Future<String> addDot(MobDot dot) async {
    DocumentSnapshot snapshot = await userCollection.doc(uid).get();
    if (!snapshot.exists || snapshot.get('currentMap') == null) {
      // The 'currentMap' field doesn't exist or is null
      return "";
    }
    String docId = await snapshot.get('currentMap');
    List<Map<String, double>> convertedPoints = dot.points!.map((offset) {
      return {'x': offset.dx, 'y': offset.dy};
    }).toList();

    DocumentReference docRef = await userCollection
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
      'lowerBoundTimestamp': dot.lowerBoundTimestamp,
      'upperBoundTimestamp': dot.upperBoundTimestamp,
      'points': convertedPoints,
    });
    return docRef.id;
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
          docId: doc.id,
          mobName: data['mobName'],
          innerColor: data['innerColor'],
          outerColor: data['outerColor'],
          lowerBound: data['lowerBound'],
          upperBound: data['upperBound'],
          lowerBoundTimestamp: data['lowerBoundTimestamp'],
          upperBoundTimestamp: data['upperBoundTimestamp'],
          points: points);
    }).toList();
  }

  // Refresh a MobDot's timestamps
  Future<void> updateTimestamps(MobDot dot) async {
    DocumentSnapshot snapshot = await userCollection.doc(uid).get();
    if (!snapshot.exists || snapshot.get('currentMap') == null) {
      // The 'currentMap' field doesn't exist or is null
      return;
    }
    final Timestamp now = Timestamp.now();
    final Timestamp lowerBoundTimestamp =
        Timestamp(now.seconds + dot.lowerBound * 60, now.nanoseconds);
    final Timestamp upperBoundTimestamp =
        Timestamp(now.seconds + dot.upperBound * 60, now.nanoseconds);
    String docId = snapshot.get('currentMap');

    await userCollection
        .doc(uid)
        .collection('maps')
        .doc(docId)
        .collection('dots')
        .doc(dot.docId)
        .update({
      'lowerBoundTimestamp': lowerBoundTimestamp,
      'upperBoundTimestamp': upperBoundTimestamp
    });
  }

  // Stream of GameMap objects.
  Stream<GameMap?> get mapStream {
    return userCollection
        .doc(uid)
        .snapshots()
        .asyncMap((userDocSnapshot) async {
      if (userDocSnapshot.exists && userDocSnapshot.get('currentMap') != null) {
        String currentMapId = userDocSnapshot.get('currentMap');
        DocumentSnapshot mapSnapshot = await userCollection
            .doc(uid)
            .collection('maps')
            .doc(currentMapId)
            .get();
        if (mapSnapshot.exists) {
          return GameMap(
            name: mapSnapshot.get('name'),
            selection: mapSnapshot.get('selection'),
            docId: mapSnapshot.id,
          );
        }
      }
      return null; // return null if user or map doesn't exist
    });
  }

  // Stream of MobDot objects.
  Stream<List<MobDot>> get dotStream async* {
    DocumentSnapshot snapshot = await userCollection.doc(uid).get();
    if (!snapshot.exists || snapshot.get('currentMap') == null) {
      yield []; // Empty list
      return;
    }
    String docId = snapshot.get('currentMap');
    QuerySnapshot querySnapshot = await userCollection
        .doc(uid)
        .collection('maps')
        .doc(docId)
        .collection('dots')
        .get();

    if (querySnapshot.docs.isEmpty) {
      yield []; // Empty list
      return;
    }

    yield querySnapshot.docs.map((doc) {
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
          lowerBoundTimestamp: data['lowerBoundTimestamp'],
          upperBoundTimestamp: data['upperBoundTimestamp'],
          points: points);
    }).toList();
  }
}
