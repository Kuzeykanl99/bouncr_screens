import 'package:bouncr/components/ProgressBar.dart';
import 'package:bouncr/components/RoundedButton.dart';
import 'package:bouncr/components/SignUpText.dart';
import 'package:bouncr/models/theme.dart';
import 'package:bouncr/models/user.dart';
import 'package:bouncr/screens/signup/username.dart';
import 'package:flutter/material.dart';
import 'package:bouncr/components/ErrorContainer.dart';

class FirstName extends StatefulWidget {
  
  final Function toggleView;
  const FirstName({ Key? key, required this.toggleView }) : super(key: key);

  @override
  _FirstNameState createState() => _FirstNameState();
}

class _FirstNameState extends State<FirstName> {

  String name = "";
  String lastname = "";
  String error = "";

  double containerWidth = 0;
  double containerHeight = 0;

  UserData userData = UserData();
  
  @override
  Widget build(BuildContext context) {

    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [

              // Back button
              SizedBox(width: width, height: 10,),
              Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: primaryColor
                      ),
                      onPressed: (){widget.toggleView();}, 
                      child: Icon(Icons.arrow_back)
                    ),
                  ),
                  // Progress bar
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20, 0, 30, 0),
                      child: ProgressBar(
                        text: "25%",
                        width: (width - 125)/4,
                      )
                    ),
                  ),
                ],
              ),

               // Top text
              Padding(
                padding: EdgeInsets.fromLTRB(0, 30, 0, 35),
                child: SignUpText(text: "Let's start \nwith your full name"),
              ),

              
              // First name text field
              Padding(
                padding: EdgeInsets.fromLTRB(30, 10, 30, 12.5),
                child: TextFormField(
                  textCapitalization: TextCapitalization.words,
                  autocorrect: false,
                  cursorColor: primaryColor,
                  decoration: textFieldDecorationSignUp.copyWith(labelText: "First name"),
                  autofocus: true,
                  onChanged: (text){
                    setState(() {
                      name = text;
                      error = "";
                      containerHeight = 0;
                      containerWidth = 0;
                    });
                  },
                ),
              ),

              // Last name text field
              Padding(
                padding: EdgeInsets.fromLTRB(30, 17, 30, 10),
                child: TextFormField(
                  textCapitalization: TextCapitalization.words,
                  autocorrect: false,
                  cursorColor: primaryColor,
                  decoration: textFieldDecorationSignUp.copyWith(labelText: "Last name"),
                  autofocus: true,
                  onChanged: (text){
                    setState(() {
                      lastname = text;
                      error = "";
                      containerHeight = 0;
                      containerWidth = 0;
                    });
                  },
                ),
              ),
        
              // Custom error message
              ErrorContainer(
                containerWidth: containerWidth, 
                containerHeight: containerHeight, 
                error: error
              ),
        
              // "NEXT" button to continue to username page 
              Padding(
                padding: EdgeInsets.fromLTRB(30, /*error != ""? 20:*/35, 30, 25),
                child: RoundedButton(
                  text: "NEXT", 
                  press: () {
                    // Validating input
                    if (name != "" && lastname != ""){
                      userData.firstname = name;
                      userData.lastname = lastname;
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Username(userData: userData,)),
                      );
                    }
                    else {
                      setState(() {
                        containerHeight = 30;
                        containerWidth = 230;
                        error = "Fields cannot be blank";
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