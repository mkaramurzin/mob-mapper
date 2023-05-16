import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class Database {
  final String uid;
  Database({required this.uid});

  // collection references
  final CollectionReference userCollection = FirebaseFirestore.instance.collection('users');

  Future<void> setUserData() async {
    
  }
}