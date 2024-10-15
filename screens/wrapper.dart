import 'package:bouncr/blocs/app_blocs.dart';
import 'package:bouncr/models/theme.dart';
import 'package:bouncr/models/user.dart';
import 'package:bouncr/screens/authenticate/authenticate.dart';
import 'package:bouncr/screens/home/home.dart';
import 'package:bouncr/services/database.dart';
import "package:flutter/material.dart";
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel?>(context);
    
    // Return either home or authenticate widget
    if (user == null) {
      return Authenticate();
    } else if (user.uid == "loading") {
      return splash;
    } else {
      final db = DatabaseService(uid: user.uid);
      return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => AppBloc()),
          FutureProvider<UserData?>.value(
            value: db.getUserInformation(), 
            initialData: UserData(
              dob: "loading ...",
              firstname: "loading ...",
              lastname: "loading ...",
              email: "loading ...",
              imagePath: "",
              username: "loading ...",
            ),
          ),
        ],
        child: Home(),
      );
    }
  }
}
