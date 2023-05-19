import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobmapper/models/map.dart';

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
    QuerySnapshot querySnapshot = await userCollection.doc(uid).collection('maps').get();
    return querySnapshot.docs.map((doc) {
      return GameMap(
          name: doc.get('name'), 
          selection: doc.get('selection')
      );
    }).toList();
  }

}
