import 'dart:async';
import 'package:bouncr/components/ErrorContainer.dart';
import 'package:bouncr/components/RoundedButton.dart';
import 'package:bouncr/components/SignUpText.dart';
import 'package:bouncr/models/theme.dart';
import 'package:bouncr/models/user.dart';
import 'package:bouncr/services/database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditEventName extends StatefulWidget {
  final String eventId;
  const EditEventName({ Key? key, required this.eventId }) : super(key: key);

  @override
  _EditEventNameState createState() => _EditEventNameState();
}

class _EditEventNameState extends State<EditEventName> {

  String error = "";
  double containerWidth = 0;
  double containerHeight = 0;
  bool loading = false;

  final TextEditingController _eventNameController = TextEditingController();

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

  bool isValid(){
    if (_eventNameController.text.isEmpty){
      if(containerWidth == 0){
        spawnContainer("This field cannot be blank");
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

  @override
  void dispose() {
    _eventNameController.dispose();
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
                child: SignUpText(text: "Change event name"),
              ),

              // Event name text field
              Padding(
                padding: EdgeInsets.fromLTRB(30, 10, 30, 12.5),
                child: TextFormField(
                  maxLength: 30,
                  controller: _eventNameController,
                  autocorrect: false,
                  cursorColor: primaryColor,
                  decoration:
                      textFieldDecorationSignUp.copyWith(labelText: "New event name"),
                  autofocus: true,
                  onChanged: (text) {},
                ),
              ),

              // Custom error message
              ErrorContainer(
                  containerWidth: containerWidth,
                  containerHeight: containerHeight,
                  error: error),

              // "SUBMIT" button to go back to event details
              Padding(
                padding:
                    EdgeInsets.fromLTRB(30, 60, 30, 25),
                child: RoundedButton(
                  text: loading ? "Verifying..." : "UPDATE",
                  horizontalPadding: loading ? 86 : 110,
                  press: () async {
                    bool success = false;

                    // Check if event name field is not blank
                    if(isValid()){
                      setState(() {
                        loading = true;
                      });

                      // Change event name in database
                      success = await db.updateEventName(widget.eventId, _eventNameController.text);

                      // If change was successful, go back to details
                      if(success){
                        Navigator.pop(context, [true, _eventNameController.text]);
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