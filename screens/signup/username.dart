import 'dart:async';

import 'package:bouncr/components/ProgressBar.dart';
import 'package:bouncr/components/RoundedButton.dart';
import 'package:bouncr/components/SignUpText.dart';
import 'package:bouncr/models/theme.dart';
import 'package:bouncr/models/user.dart';
import 'package:bouncr/screens/signup/dob.dart';
import 'package:bouncr/services/database.dart';
import 'package:flutter/material.dart';
import 'package:bouncr/components/ErrorContainer.dart';

class Username extends StatefulWidget {
  final UserData userData;
  const Username({Key? key, required this.userData}) : super(key: key);

  @override
  _UsernameState createState() => _UsernameState(this.userData);
}

class _UsernameState extends State<Username> {
  String username = "";
  String error = "";

  double containerWidth = 0;
  double containerHeight = 0;

  // Loading state
  bool loading = false;

  UserData userData = UserData();
  _UsernameState(UserData userData) {
    this.userData = userData;
  }

  // Initializing database
  DatabaseService db = DatabaseService();

  void spawnContainer(String e) {
    setState(() {
      containerHeight = 30;
      containerWidth = 250;
      error = e;
    });
  }

  void removeContainer() {
    setState(() {
      containerHeight = 0;
      containerWidth = 0;
    });
  }

  void shakeContainer() {
    setState(() {
      containerWidth += 30;
    });
    Timer(Duration(milliseconds: 300), () {
      setState(() {
        containerWidth -= 30;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Back button
              SizedBox(
                width: width,
                height: 10,
              ),
              Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(primary: primaryColor),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Icon(Icons.arrow_back)),
                  ),
                  // Progress bar
                  Expanded(
                    child: Padding(
                        padding: EdgeInsets.fromLTRB(20, 0, 30, 0),
                        child: ProgressBar(
                          text: "25%",
                          width: (width - 125) / 2,
                        )),
                  ),
                ],
              ),

              // Top text
              Padding(
                padding: EdgeInsets.fromLTRB(0, 30, 0, 62.5),
                child: SignUpText(text: "Let's get you \na unique username"),
              ),

              // Username text field
              Padding(
                padding: EdgeInsets.fromLTRB(30, 10, 30, 12.5),
                child: TextFormField(
                  autocorrect: false,
                  cursorColor: primaryColor,
                  decoration:
                      textFieldDecorationSignUp.copyWith(labelText: "Username"),
                  autofocus: true,
                  onChanged: (text) {
                    setState(() {
                      username = text;
                    });
                  },
                ),
              ),

              // Custom error message
              ErrorContainer(
                  containerWidth: containerWidth,
                  containerHeight: containerHeight,
                  error: error),

              // "NEXT" button to continue to username page
              Padding(
                padding:
                    EdgeInsets.fromLTRB(30, /*error != ""? 20:*/ 60, 30, 25),
                child: RoundedButton(
                    text: loading ? "Verifying..." : "NEXT",
                    horizontalPadding: loading ? 86 : 110,
                    press: () async {
                      setState(() {
                        loading = true;
                      });
                      // Check that username is not empty
                      if (username != "") {
                        if (!username.contains(" ")) {
                          // Check database for uniqueness
                          bool usernameValid = await db.usernameCheck(username);
                          if (usernameValid) {
                            // Remove error message
                            removeContainer();
                            // Update user data
                            userData.username = username;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Dob(
                                        userData: userData,
                                      )),
                            );
                          } else {
                            // If error is currently displayed
                            if (error == "Username already in use") {
                              // Animate "shake"
                              shakeContainer();
                            }
                            // If not, spawn the error container
                            else {
                              spawnContainer("Username already in use");
                            }
                          }
                        } else {
                          spawnContainer("Username cannot contain spaces");
                        }
                      } else {
                        spawnContainer("This field cannot be blank");
                      }
                      setState(() {
                        loading = false;
                      });
                    },
                    textstyle: buttonFontStyle.copyWith(color: Colors.white),
                    buttoncolor: primaryColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
