import 'dart:io';
import 'package:bouncr/components/ProfileWidget.dart';
import 'package:bouncr/components/SettingsText.dart';
import 'package:bouncr/models/theme.dart';
import 'package:bouncr/models/user.dart';
import 'package:bouncr/services/auth.dart';
import 'package:bouncr/services/database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:provider/provider.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  XFile? pickedImage;

  @override
  Widget build(BuildContext context) {

    
    final AuthService _auth = AuthService();
    final user = Provider.of<UserModel?>(context);
    final db = DatabaseService(uid: user!.uid);
    final userData = Provider.of<UserData?>(context);

    return userData == null || userData.firstname == "loading ..."
        ? Center(
            child: LoadingBouncingGrid.circle(
            backgroundColor: primaryColor,
          ))
        : Scaffold(
            body: ListView(
              physics: BouncingScrollPhysics(),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
                  child: ProfileWidget(
                      imagePath: userData.imagePath,
                      onClicked: () async {
                        // Send selected picture into storage
                        var url = await loadPicker(
                            user.uid ?? "", ImageSource.gallery);

                        // Update db path
                        if (url != "") {
                          db.updateUserProfilePicture(url);
                          setState(() {
                            userData.imagePath = url;
                          });
                        }
                      }),
                ),
                const SizedBox(height: 24),
                buildName(userData),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () async {
                    final result = _auth.changePassword(userData.email!);
                    showDialog(
                        context: context,
                        builder: (BuildContext dialogContext) => AlertDialog(
                              title: Text(
                                result != null
                                    ? "An email has been sent to " +
                                        userData.email!
                                    : "Please Try Again",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: "Avenir-Medium"),
                              ),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.pop(dialogContext);
                                    },
                                    child: Text(
                                      "OK",
                                      style: TextStyle(color: Colors.white),
                                    ))
                              ],
                              backgroundColor: primaryColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25)),
                            ));
                  },
                  child: SettingsText(
                    text: "Change password",
                    color: Colors.black,
                    iconColor: Colors.black,
                    icon: Icons.password,
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    await _auth.signout();
                  },
                  child: SettingsText(
                    text: "Log Out",
                    color: Colors.red,
                    iconColor: Colors.red,
                    icon: Icons.logout,
                  ),
                )
              ],
            ),
          );
  }

  Widget buildName(UserData userData) => Column(
        children: [
          Text(
            userData.firstname! + " " + userData.lastname!,
            style: TextStyle(
              fontFamily: "Avenir-Medium",
              fontSize: 26,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "@" + userData.username!,
            style: TextStyle(
              fontFamily: "Avenir-Medium",
              fontSize: 20,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            userData.email!,
            style: TextStyle(
              fontFamily: "Avenir-Medium",
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Date of Birth: " +
                userData.dob!.substring(0, 4) +
                "/" +
                userData.dob!.substring(4, 6) +
                "/" +
                userData.dob!.substring(6, 8),
            style: TextStyle(
              fontFamily: "Avenir-Medium",
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
        ],
      );

  Future loadPicker(String uid, ImageSource source) async {
    final ImagePicker _picker = ImagePicker();
    // Pick an image
    final XFile? picked = await _picker.pickImage(source: source);
    if (picked == null) {
      return "";
    }
    final File pickedFile = File(picked.path);
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage.ref().child('profile_pictures').child(uid);
    String downloadUrl;
    TaskSnapshot uploadedFile = await ref.putFile(pickedFile);

    if (uploadedFile.state == TaskState.success) {
      downloadUrl = await ref.getDownloadURL();
    } else {
      downloadUrl = "";
    }

    return downloadUrl;
  }
}
