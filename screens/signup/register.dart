import 'package:bouncr/components/ErrorContainer.dart';
import 'package:bouncr/components/ProgressBar.dart';
import 'package:bouncr/components/RoundedButton.dart';
import 'package:bouncr/components/SignUpText.dart';
import 'package:bouncr/models/theme.dart';
import 'package:bouncr/models/user.dart';
import 'package:bouncr/screens/signup/verify.dart';
import 'package:bouncr/services/auth.dart';
import 'package:flutter/material.dart';

class Register extends StatefulWidget {
  final UserData userData;
  const Register({Key? key, required this.userData}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState(this.userData);
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _auth = AuthService();
  String email = "";
  String password = "";
  String verifyPass = "";
  String error = "";

  // Loading state
  bool loading = false;

  double containerWidth = 0;
  double containerHeight = 0;

  UserData userData = UserData();
  _RegisterState(UserData userData) {
    this.userData = userData;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          text: "100%",
                          width: (width - 125),
                        )),
                  ),
                ],
              ),

              Form(
                key: _formKey,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: width,
                      ),

                      // Top text
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                        child: SignUpText(
                          text:
                              "One last thing ... \nEnter an email and password \nso you can log into your account",
                          font: 20,
                        ),
                      ),

                      // Email text field
                      Padding(
                        padding: EdgeInsets.fromLTRB(30, 20, 30, 12.5),
                        child: TextFormField(
                          cursorColor: primaryColor,
                          decoration: textFieldDecorationSignUp.copyWith(
                              labelText: "Email"),
                          autofocus: true,
                          validator: (text) => text!.isEmpty
                              ? "This field cannot be blank"
                              : null,
                          onChanged: (text) {
                            setState(() {
                              email = text;
                            });
                          },
                        ),
                      ),

                      // Custom error message
                      ErrorContainer(
                          containerWidth: containerWidth,
                          containerHeight: containerHeight,
                          error: error),

                      // Password text field
                      Padding(
                        padding: EdgeInsets.fromLTRB(30, 12.5, 30, 25),
                        child: TextFormField(
                          obscureText: true,
                          cursorColor: primaryColor,
                          decoration: textFieldDecorationSignUp.copyWith(
                              labelText: "Password"),
                          autofocus: true,
                          validator: (text) => text!.length < 8
                              ? "Password should be 8+ chars long"
                              : null,
                          onChanged: (text) {
                            setState(() {
                              password = text;
                            });
                          },
                        ),
                      ),

                      // Verify Password text field
                      Padding(
                        padding: EdgeInsets.fromLTRB(30, 0, 30, 40),
                        child: TextFormField(
                          obscureText: true,
                          cursorColor: primaryColor,
                          decoration: textFieldDecorationSignUp.copyWith(
                              labelText: "Verify Password"),
                          autofocus: true,
                          validator: (text) =>
                              text != password ? "Password don't match" : null,
                          onChanged: (text) {
                            setState(() {
                              verifyPass = text;
                            });
                          },
                        ),
                      ),

                      // "FINISH" button to continue to name page
                      RoundedButton(
                          text: loading ? "Verifying..." : "FINISH",
                          horizontalPadding: loading ? 91.5 : 110,
                          press: () async {
                            setState(() {
                              loading = true;
                            });
                            // Validating form
                            if (_formKey.currentState!.validate()) {
                              userData.email = email;
                              userData.password = password;
                              dynamic result = await _auth
                                  .registerWithEmailAndPassword(userData);
                              if (result == null) {
                                setState(() {
                                  containerHeight = 30;
                                  containerWidth = 230;
                                  error = "Email already in use or invalid";
                                });
                              } else {
                                //Navigator.popUntil(
                                //    context, ModalRoute.withName('/'));
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Verify()));
                              }
                            }
                            setState(() {
                              loading = false;
                            });
                          },
                          textstyle:
                              buttonFontStyle.copyWith(color: Colors.white),
                          buttoncolor: primaryColor),
                      SizedBox(
                        height: 40,
                      ),
                    ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
