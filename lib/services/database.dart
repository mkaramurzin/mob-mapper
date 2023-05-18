import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class Database {
  final String uid;
  Database({required this.uid});

  // collection references
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');

  Future<void> setUserData() async {}

  Future<void> addMap(String selection) async {
    final DocumentReference docRef = await userCollection
        .doc(uid)
        .collection("Maps")
        .add({"selection": selection});

    final String docId = docRef.id;
    await userCollection.doc(uid).update({"currentMap": docId});
  }
}
