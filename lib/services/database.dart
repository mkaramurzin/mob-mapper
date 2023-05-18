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
        .collection("maps")
        .add({"selection": selection});

    final String docId = docRef.id;
    await userCollection.doc(uid).set({"currentMap": docId});
  }

  Future<String?> get map async {
    DocumentSnapshot snapshot = await userCollection.doc(uid).get();
    if (!snapshot.exists || snapshot.get('currentMap') == null) {
      // The 'currentMap' field doesn't exist or is null
      return null;
    }
    String docId = await snapshot.get('currentMap');
    snapshot =
        await userCollection.doc(uid).collection('maps').doc(docId).get();
    return snapshot.get('selection');
  }

  
}
