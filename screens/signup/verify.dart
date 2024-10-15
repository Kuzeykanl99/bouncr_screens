import 'dart:async';

import 'package:bouncr/models/theme.dart';
import 'package:bouncr/screens/home/intro.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Verify extends StatefulWidget {
  const Verify({Key? key}) : super(key: key);

  @override
  _VerifyState createState() => _VerifyState();
}

class _VerifyState extends State<Verify> {
  final auth = FirebaseAuth.instance;
  User? user;
  Timer? timer;

  @override
  void initState() {
    user = auth.currentUser;
    user?.sendEmailVerification();

    timer = Timer.periodic(Duration(seconds: 2), (timer) {
      checkEmailVerified();
    });
    super.initState();
  }

  @override
  void dispose() {
    timer!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "An email has been sent to\n",
          style: TextStyle(fontSize: 18, fontFamily: "Avenir-Medium"),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
          child: Text(
            "${user?.email}",
            style: TextStyle(
                fontSize: 22, fontFamily: "Avenir-Medium", color: primaryColor),
          ),
        ),
        Text(
          "\nPlease click the link in your email",
          style: TextStyle(fontSize: 18, fontFamily: "Avenir-Medium"),
        ),
        Text(
          "and verify your account",
          style: TextStyle(fontSize: 18, fontFamily: "Avenir-Medium"),
        )
      ],
    )));
  }

  Future<void> checkEmailVerified() async {
    user = auth.currentUser;
    if (user != null) {
      await user?.reload();
      if (user!.emailVerified) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => IntroPage()));
        timer!.cancel();
      }
    }
  }
}
