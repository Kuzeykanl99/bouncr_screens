import 'package:bouncr/blocs/app_blocs.dart';
import 'package:bouncr/models/theme.dart';
import 'package:bouncr/screens/home/create_event.dart';
import 'package:bouncr/screens/home/events.dart';
import 'package:bouncr/screens/home/hot.dart';
import 'package:bouncr/screens/home/profile.dart';
import 'package:bouncr/screens/home/map.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import "package:flutter/material.dart";
import 'package:provider/provider.dart';

class Home extends StatefulWidget {

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home>{

  List<Widget> pages = [CreateEvent(), Events(), Map(), Hot(), Profile()];
  Widget body = Map();
  Color navBgColor = primaryColor;


  /*

  Future checkFirstSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool _seen = (prefs.getBool('seen') ?? false);

    if (_seen) {
      await prefs.setBool('seen', true);
      Navigator.push(context, MaterialPageRoute(builder: (context) => IntroPage()));
    }
  }

  */

  //@override
  //void afterFirstLayout(BuildContext context) => checkFirstSeen();



  @override
  Widget build(BuildContext context) {

    final appBloc = Provider.of<AppBloc>(context);

    return Scaffold(
      bottomNavigationBar: 
      
      CurvedNavigationBar(
        index: 2,
        items: [
          Icon(Icons.add, color: Colors.white,),
          Icon(Icons.event, color: Colors.white,),
          Icon(Icons.location_on_outlined, color: Colors.white,),
          Icon(Icons.whatshot, color: Colors.white,),
          Icon(Icons.person, color: Colors.white,),
        ],
        backgroundColor: navBgColor,
        color: primaryColor,
        animationDuration: Duration(milliseconds: 200),
        onTap: (index){
          setState(() {
            index==2? navBgColor = primaryColor : navBgColor = Theme.of(context).scaffoldBackgroundColor;
            if(index == 0){
              appBloc.selectedLocation = null;
            }
            body = pages[index];
          });
        },
      ),
      body: body,
    );
  }
}