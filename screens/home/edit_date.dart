import 'dart:async';
import 'package:bouncr/components/DateFields.dart';
import 'package:bouncr/components/ErrorContainer.dart';
import 'package:bouncr/components/RoundedButton.dart';
import 'package:bouncr/components/SignUpText.dart';
import 'package:bouncr/models/theme.dart';
import 'package:bouncr/models/user.dart';
import 'package:bouncr/services/database.dart';
import 'package:bouncr/services/date.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditEventDate extends StatefulWidget {
  final String eventId;
  const EditEventDate({ Key? key, required this.eventId }) : super(key: key);

  @override
  _EditEventDateState createState() => _EditEventDateState();
}

class _EditEventDateState extends State<EditEventDate> {

  String error = "";
  double containerWidth = 0;
  double containerHeight = 0;
  bool loading = false;

  // Date service for checking if time and date are valid
  DateService dateService = DateService();

  // Focus nodes
  final FocusNode _dayFocus = FocusNode();
  final FocusNode _monthFocus = FocusNode();
  final FocusNode _yearFocus = FocusNode();

  // Textfield controllers
  final TextEditingController _dayController = TextEditingController();
  final TextEditingController _monthController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();

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

  bool checkDate(){
    if (!dateService.isValidDate(_yearController.text, _monthController.text, _dayController.text)){
      if(containerWidth == 0){
        spawnContainer("Please enter a valid date");
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
  void dispose() {
    _dayController.dispose();
    _monthController.dispose();
    _yearController.dispose();
    super.dispose();
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

              // "Change event name" text
              Padding(
                padding: EdgeInsets.fromLTRB(0, 30, 0, 62.5),
                child: SignUpText(text: "Change event date"),
              ),

              // Year, month, day fields
              DateFields(
                padding: EdgeInsets.fromLTRB(0, 0, 0, containerWidth == 0? 10: 20),
                borderColor: primaryColor, 
                cursorColor: primaryColor, 
                fillColor: Colors.white, 
                yearFocus: _yearFocus,
                monthFocus: _monthFocus,
                dayFocus: _dayFocus,
                dayController: _dayController,
                monthController: _monthController,
                yearController: _yearController,
                yearChange: (text) {
                  if (text.length == 4) {_fieldFocusChange(context, _yearFocus, _monthFocus);}
                }, 
                monthChange: (text) {
                  if (text.length >= 2) {_fieldFocusChange(context, _monthFocus, _dayFocus);}
                }, 
                dayChange: (text) {
                  if (text.length >= 2) {
                    _dayFocus.unfocus();
                    checkDate();
                  }
                },
              ),

              // Custom error message
              ErrorContainer(
                containerWidth: containerWidth,
                containerHeight: containerHeight,
                error: error
              ),

              // "UPDATE" button to go back to event details
              Padding(
                padding: EdgeInsets.fromLTRB(30, containerHeight != 0?40:60, 30, 25),
                child: RoundedButton(
                  text: loading ? "Verifying..." : "UPDATE",
                  horizontalPadding: loading ? 86 : 110,
                  press: () async {
                    bool success = false;

                    // Check if event name field is not blank
                    if(checkDate()){
                      setState(() {
                        loading = true;
                      });

                      // Change event name in database
                      success = await db.updateEventDate(
                        widget.eventId, 
                        _yearController.text +
                        _monthController.text +
                        _dayController.text,
                      );

                      // If change was successful, go back to details
                      if(success){
                        Navigator.pop(context, [
                          true, 
                          _yearController.text +
                          _monthController.text +
                          _dayController.text,
                        ]);
                      }
                      // Otherwise display error message
                      else {
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