import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mobmapper/services/auth.dart';
import 'package:mobmapper/wrapper.dart';
import 'package:mobmapper/screens/map_screen.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: "AIzaSyD5VWVKF8fVISY3YhCr0_AQZyJllKp32Po",
          appId: "1:88089412606:web:12e0613223d9be61cdb6af",
          messagingSenderId: "G-XN2YFVR907",
          projectId: "mob-mapper"));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return StreamProvider.value(
      value: AuthService().authStateChanges,
      initialData: null,
      child: FutureBuilder(
        future: _initialization,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return MaterialApp(
              initialRoute: '/',
              routes: {
                '/': (context) => Wrapper(),
                '/map': (context) => Map(),
              },
            );
          } else if (snapshot.hasError) {
            return Text("Error in main.dart: ${snapshot.error}");
          }
          return CircularProgressIndicator();
        },
      ),
    );
  }
}
