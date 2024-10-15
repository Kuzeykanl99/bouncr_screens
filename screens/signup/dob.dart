import 'dart:async';
import 'package:bouncr/components/DateFields.dart';
import 'package:bouncr/components/ProgressBar.dart';
import 'package:bouncr/components/RoundedButton.dart';
import 'package:bouncr/components/SignUpText.dart';
import 'package:bouncr/models/theme.dart';
import 'package:bouncr/models/user.dart';
import 'package:bouncr/screens/signup/register.dart';
import 'package:flutter/material.dart';
import 'package:bouncr/components/ErrorContainer.dart';

class Dob extends StatefulWidget {
  final UserData userData;
  const Dob({Key? key, required this.userData}) : super(key: key);

  @override
  _DobState createState() => _DobState(this.userData);
}

class _DobState extends State<Dob> {
  String month = "";
  String day = "";
  String year = "";
  String error = "";

  double containerWidth = 0;
  double containerHeight = 0;

  final FocusNode _dayFocus = FocusNode();
  final FocusNode _monthFocus = FocusNode();
  final FocusNode _yearFocus = FocusNode();

  UserData userData = UserData();
  _DobState(UserData userData) {
    this.userData = userData;
  }

  _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  bool isValidDate(String input) {
    final date = DateTime.parse(input);
    final originalFormatString = toOriginalFormatString(date);
    return input == originalFormatString;
  }

  String toOriginalFormatString(DateTime dateTime) {
    final y = dateTime.year.toString().padLeft(4, '0');
    final m = dateTime.month.toString().padLeft(2, '0');
    final d = dateTime.day.toString().padLeft(2, '0');
    return "$y$m$d";
  }

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
                          text: "75%",
                          width: 3 * (width - 125) / 4,
                        )),
                  ),
                ],
              ),

              // Top text
              Padding(
                padding: EdgeInsets.fromLTRB(0, 30, 0, 62.5),
                child:
                    SignUpText(text: "Almost done, \nwhat's your birth date?"),
              ),

              // Dob 3 text fields
              // Year, month, day fields
              DateFields(
                padding: const EdgeInsets.fromLTRB(30, 10, 30, 12.5),
                borderColor: primaryColor, 
                cursorColor: primaryColor, 
                fillColor: Colors.white, 
                yearFocus: _yearFocus,
                monthFocus: _monthFocus,
                dayFocus: _dayFocus,
                yearChange: (text) {
                  if (text.length == 4) {_fieldFocusChange(context, _yearFocus, _monthFocus);}
                  setState(() {year = text;});
                }, 
                monthChange: (text) {
                  if (text.length >= 2) {_fieldFocusChange(context, _monthFocus, _dayFocus);}
                  setState(() {month = text;});
                }, 
                dayChange: (text) {
                  if (text.length >= 2) {_dayFocus.unfocus();}
                  setState(() {day = text;});
                },
              ),

              // Custom error message
              ErrorContainer(
                  containerWidth: containerWidth,
                  containerHeight: containerHeight,
                  error: error
              ),

              // "NEXT" button to continue to username page
              Padding(
                padding:
                    EdgeInsets.fromLTRB(30, /*error != ""? 20:*/ 60, 30, 25),
                child: RoundedButton(
                    text: "NEXT",
                    press: () {
                      String date = year + month + day;
                      if (date.length != 8) {
                        if (error == "Please fill out all the fields") {
                          shakeContainer();
                        } else {
                          spawnContainer("Please fill out all the fields");
                        }
                        return;
                      }

                      if (isValidDate(date)) {
                        userData.dob = date;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Register(userData: userData,)),
                        );
                        removeContainer();
                      } else {
                        if (error == "Please enter a valid date") {
                          shakeContainer();
                        } else {
                          spawnContainer("Please enter a valid date");
                        }
                      }
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
