import 'package:bouncr/components/ErrorContainer.dart';
import 'package:bouncr/components/RoundedButton.dart';
import 'package:bouncr/models/theme.dart';
import 'package:bouncr/services/auth.dart';
import 'package:flutter/material.dart';

class SignIn extends StatefulWidget {
  final Function toggleView;
  const SignIn({Key? key, required this.toggleView}) : super(key: key);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  // Authentication service instance
  final AuthService _auth = AuthService();

  // Loading state
  bool loading = false;

  // Text field state
  String email = "";
  String password = "";
  String error = "";

  // Custom error box state
  double containerWidth = 0;
  double containerHeight = 0;

  // Validation form field
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: primaryColor,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Making sure the column has the width of the screen
                SizedBox(
                  height: 40,
                  width: width,
                ),

                // "bouncr" logo
                Image.asset(
                  "assets/logos/main_logo.png",
                  scale: 3.5,
                ),

                // "bouncr" text
                Text(
                  "bouncr",
                  style: logoFontStyle,
                ),

                // Email text field
                Padding(
                  padding: EdgeInsets.fromLTRB(30, 30, 30, 10),
                  child: TextFormField(
                    autocorrect: false,
                    style: TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    decoration:
                        textFieldDecorationSignIn.copyWith(labelText: "Email"),
                    onChanged: (text) {
                      setState(() {
                        email = text;
                      });
                    },
                    validator: (text) =>
                        text!.isEmpty ? "This field cannot be blank" : null,
                  ),
                ),

                // Password text field
                Padding(
                  padding: EdgeInsets.fromLTRB(30, 10, 30, 20),
                  child: TextFormField(
                    obscureText: true,
                    style: TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    decoration: textFieldDecorationSignIn.copyWith(
                        labelText: "Password"),
                    onChanged: (text) {
                      setState(() {
                        password = text;
                      });
                    },
                    validator: (text) => text!.length < 8
                        ? "Enter a password 8+ chars long"
                        : null,
                  ),
                ),

                // Error container
                ErrorContainer(
                    containerWidth: containerWidth,
                    containerHeight: containerHeight,
                    error: error),

                // Login button that communicates with Firebase backend
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 20, 0, 40),
                  child: RoundedButton(
                      text: loading ? "Verifying..." : "LOGIN",
                      horizontalPadding: loading ? 91.5 : 110,
                      press: () async {
                        setState(() {
                          loading = true;
                        });
                        if (_formKey.currentState!.validate()) {
                          dynamic result = await _auth
                              .signInWithEmailAndPassword(email, password);
                          if (result == null) {
                            setState(() {
                              containerHeight = 30;
                              containerWidth = 200;
                              error = "Invalid Credentials";
                              loading = false;
                            });
                          }
                        } else {
                          setState(() {
                            loading = false;
                          });
                        }
                      },
                      textstyle: buttonFontStyle.copyWith(color: primaryColor),
                      buttoncolor: Colors.white),
                ),

                // "Don't have an account? Sign up!" text
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 40, 0, 0),
                  child: Text(
                    "Don't have an account? Sign up!",
                    style: defaultTextStyle,
                  ),
                ),

                // Button that toggles to the "sign up" screen
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 10, 0, 40),
                  child: RoundedButton(
                      text: "SIGN UP",
                      press: () {
                        widget.toggleView();
                      },
                      textstyle: buttonFontStyle.copyWith(color: primaryColor),
                      buttoncolor: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
