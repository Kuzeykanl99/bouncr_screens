import 'dart:async';
import 'package:bouncr/components/ErrorContainer.dart';
import 'package:bouncr/components/RoundedButton.dart';
import 'package:bouncr/components/SignUpText.dart';
import 'package:bouncr/components/TimeFields.dart';
import 'package:bouncr/models/theme.dart';
import 'package:bouncr/models/user.dart';
import 'package:bouncr/services/database.dart';
import 'package:bouncr/services/date.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditTime extends StatefulWidget {

  final String eventId;
  const EditTime({ Key? key, required this.eventId}) : super(key: key);

  @override
  _EditTimeState createState() => _EditTimeState();
}

class _EditTimeState extends State<EditTime> {

  String error = "";
  double containerWidth = 0;
  double containerHeight = 0;
  bool loading = false;

  // Date service for checking if time and date are valid
  DateService dateService = DateService();

  // Focusnodes
  final FocusNode _hourFocus = FocusNode();
  final FocusNode _minuteFocus = FocusNode();

  // Textfield controllers
  final TextEditingController _hourController = TextEditingController();
  final TextEditingController _minuteController = TextEditingController();

  // A.M./P.M. toggle status (false is P.M.)
  bool toggleStatus = false;

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

  bool checkTime(){
    if (!dateService.isValidTime(_hourController.text, _minuteController.text)){
      if(containerWidth == 0){
        spawnContainer("Please enter a valid time");
      }
      else{
        shakeContainer();
      }
      return false;
    }
    else{
      removeContainer();
      return true;
    }
  }

   _fieldFocusChange(BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    final user = Provider.of<UserModel?>(context);
    DatabaseService db = DatabaseService(uid: user!.uid);

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
                        onPressed: () {Navigator.pop(context, [false, ""]);},
                        child: Icon(Icons.arrow_back)),
                  ),
                  Expanded(child: SizedBox()),
                ],
              ),

              // "Change event time" text
              Padding(
                padding: EdgeInsets.fromLTRB(0, 30, 0, 60),
                child: SignUpText(text: "Change event time"),
              ),

              // Hour and minute fields
              TimeFields(
                padding: EdgeInsets.only(bottom: containerWidth == 0? 20:10),
                hourController: _hourController,
                minuteController: _minuteController,
                borderColor: primaryColor, 
                cursorColor: primaryColor, 
                fillColor: Colors.white, 
                hourFocus: _hourFocus,
                minuteFocus: _minuteFocus,
                toggleStatus: toggleStatus,
                hourChange: (text) {
                  if (text.length >= 2) {_fieldFocusChange(context, _hourFocus, _minuteFocus);}
                }, 
                minuteChange: (text) {
                  if (text.length >= 2) {
                    _minuteFocus.unfocus();
                    checkTime();
                  }
                },
                toggleStatusChange: (val){
                  setState(() {
                    toggleStatus = val;
                  });
                },
              ),

              // Custom error message
              ErrorContainer(
                containerWidth: containerWidth,
                containerHeight: containerHeight,
                error: error
              ),

              // "SUBMIT" button to go back to event details
              Padding(
                padding:
                    EdgeInsets.fromLTRB(30, 35, 30, 25),
                child: RoundedButton(
                  text: loading ? "Verifying..." : "UPDATE",
                  horizontalPadding: loading ? 86 : 110,
                  press: () async {
                    bool success = false;

                    // Check if event name field is not blank
                    if(checkTime()){
                      setState(() {
                        loading = true;
                      });

                      String time = _hourController.text + ":" + _minuteController.text;
                      toggleStatus? time += " A.M." : time += " P.M.";

                      // Change event name in database
                      success = await db.updateEventTime(widget.eventId, time);

                      // If change was successful, go back to details
                      if(success){
                        Navigator.pop(context, [true, time]);
                      }
                      // Otherwise display error message
                      else{
                        spawnContainer("Database error");
                      }
                      setState(() {
                        loading = false;
                      });
                    }
                  },
                  textstyle: buttonFontStyle.copyWith(color: Colors.white),
                  buttoncolor: primaryColor
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}