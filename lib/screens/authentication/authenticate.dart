import 'package:flutter/material.dart';
import 'package:mobmapper/screens/authentication/sign_in.dart';
import 'package:mobmapper/screens/authentication/register.dart';

class Authenticate extends StatefulWidget {
  const Authenticate({Key? key}) : super(key: key);

  @override
  State<Authenticate> createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {

  bool showSignIn = true;
  toggleView() {
    setState(() => showSignIn = !showSignIn);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      child: showSignIn ?
      SignIn(toggle: toggleView)
          :
      Register(toggle: toggleView)
    );
  }
}
