import 'package:bouncr/components/CircleCluster.dart';
import 'package:bouncr/components/HotCircle.dart';
import 'package:bouncr/models/theme.dart';
import 'package:bouncr/screens/home/hot_event.dart';
import 'package:bouncr/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Hot extends StatefulWidget {
  const Hot({Key? key}) : super(key: key);

  @override
  _HotState createState() => _HotState();
}

class _HotState extends State<Hot> with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _circle1Controller;
  late AnimationController _wave1Controller;
  late AnimationController _wave2Controller;
  late AnimationController _smallCirclesController;
  //late AnimationController _largeCirclesController;
  //late AnimationController _largerCirclesController;

  // Animations
  late Animation _circle1Animation;
  late Animation _wave1Animation;
  late Animation _wave2Animation;
  late Animation _smallCirclesAnimation;
  //late Animation _largeCirclesAnimation;
  //late Animation _largerCirclesAnimation;

  late Future<List<QueryDocumentSnapshot<Object?>>>? _topEvents;

  @override
  void initState() {
    _circle1Controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _wave1Controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: 2000));
    _wave2Controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: 2000));
    _smallCirclesController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1000));
    //_largeCirclesController = AnimationController(vsync: this, duration: Duration(milliseconds: 1000));
    //_largerCirclesController = AnimationController(vsync: this, duration: Duration(milliseconds: 1000));

    // Initializing animations
    _circle1Animation =
        Tween<double>(begin: 0, end: 120).animate(_circle1Controller)
          ..addListener(() {
            setState(() {});
          });
    _smallCirclesAnimation =
        Tween<double>(begin: 0, end: 6).animate(_smallCirclesController)
          ..addListener(() {
            setState(() {});
          });
    //_largeCirclesAnimation = Tween<double>(begin: 0, end: 100).animate(_smallCirclesController)..addListener(() {setState(() {});});
    //_largerCirclesAnimation = Tween<double>(begin: 0, end: 120).animate(_smallCirclesController)..addListener(() {setState(() {});});
    _wave1Animation =
        Tween<double>(begin: 120, end: 145).animate(_wave1Controller)
          ..addListener(() {
            setState(() {});
          })
          ..addStatusListener((AnimationStatus status) {
            Future.delayed(Duration(milliseconds: 1000), () {
              if (mounted) {
                _wave2Controller.repeat();
              }
            });
          });
    _wave2Animation =
        Tween<double>(begin: 120, end: 145).animate(_wave2Controller)
          ..addListener(() {
            setState(() {});
          });

    _topEvents = DatabaseService().getTopEvents(5);

    _circle1Controller.forward();
    _smallCirclesController.forward();
    _wave1Controller.repeat();
    super.initState();
  }

  @override
  void dispose() {
    _circle1Controller.dispose();
    _wave1Controller.dispose();
    _wave2Controller.dispose();
    _smallCirclesController.dispose();
    //_largeCirclesController.dispose();
    //_largerCirclesController.dispose();
    super.dispose();
  }

  List<Widget> getHotEvents(
      List<QueryDocumentSnapshot<Object?>>? events, double width) {
    List<Widget> widgets = [];

    List<Widget> hotEvents = [
      // Center #1 hot event in area
      Align(
        alignment: Alignment(0, 0),
        child: HotCircle(
          borderColor: Colors.transparent,
          color: Colors.deepOrange[400] ?? Colors.deepOrange,
          radius: _circle1Animation.value,
          child: Icon(
            Icons.whatshot,
            color: Colors.white,
            size: 50,
          ),
        ),
      ),

      // 2nd hot event
      Align(
        alignment: Alignment(0.62, -0.42),
        child: HotCircle(
          gradient: RadialGradient(
            center: Alignment(-0.8, 1),
            colors: [Colors.deepOrange[400] ?? Colors.deepOrange, primaryColor],
            radius: 0.8,
          ),
          borderColor: Colors.transparent,
          color: primaryColor,
          radius: 85,
          child: Center(
              child: Text(
            "2",
            style: TextStyle(
                color: Colors.white, fontSize: 30, fontFamily: "Avenir-Heavy"),
          )),
        ),
      ),

      // 3rd hot event
      AnimatedAlign(
        duration: Duration(milliseconds: 2000),
        alignment: Alignment(0.57, 0.4),
        child: HotCircle(
          gradient: RadialGradient(
            center: Alignment(-0.8, -1),
            colors: [Colors.deepOrange[400] ?? Colors.deepOrange, primaryColor],
            radius: 0.8,
          ),
          borderColor: Colors.transparent,
          color: primaryColor,
          radius: 75,
          child: Center(
              child: Text(
            "3",
            style: TextStyle(
                color: Colors.white, fontSize: 28, fontFamily: "Avenir-Heavy"),
          )),
        ),
      ),

      // 4th hot event
      AnimatedAlign(
        duration: Duration(milliseconds: 2000),
        alignment: Alignment(-0.6, -0.4),
        child: HotCircle(
          gradient: RadialGradient(
            center: Alignment(1, 1),
            colors: [Colors.deepOrange[400] ?? Colors.deepOrange, primaryColor],
            radius: 0.8,
          ),
          borderColor: Colors.transparent,
          color: primaryColor,
          radius: 70,
          child: Center(
              child: Text(
            "4",
            style: TextStyle(
                color: Colors.white, fontSize: 27, fontFamily: "Avenir-Heavy"),
          )),
        ),
      ),

      // 5th hot event
      Align(
        alignment: Alignment(-0.6, 0.4),
        child: HotCircle(
          gradient: RadialGradient(
            center: Alignment(0.8, -1),
            colors: [Colors.deepOrange[400] ?? Colors.deepOrange, primaryColor],
            radius: 0.8,
          ),
          borderColor: Colors.transparent,
          color: primaryColor,
          radius: 65,
          child: Center(
              child: Text(
            "5",
            style: TextStyle(
                color: Colors.white, fontSize: 25, fontFamily: "Avenir-Heavy"),
          )),
        ),
      ),
    ];

    if (events != null) {
      for (int i = 0; i < events.length; i++) {
        widgets.add(GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HotEvent(
                    width: width,
                    eventName: events[i]["eventName"],
                    pictureUrl: events[i]["image"],
                    address: events[i]["formattedAddress"],
                    description: events[i]["description"],
                    attendance: events[i]["attendance"],
                    capacity: events[i]["maxCap"],
                  ),
                ),
              );
            },
            child: hotEvents[i]));
      }
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    CircleClusters circleClusters = CircleClusters();

    List<Widget> starCircles =
        circleClusters.getCircleCluster(_smallCirclesAnimation.value, [
      [-0.45, -0.1, Colors.deepOrange[400]],
      [0.45, 0.1, Colors.deepOrange[400]],
      [-0.45, 0.1, Colors.deepOrange[400]],
      [0.05, 0.4, Colors.deepOrange[400]],
      [0.05, -0.4, Colors.deepOrange[400]],
      [-0.05, -0.4, Colors.deepOrange[400]],
      [0.2, 0.3, Colors.deepOrange[400]],
      [-0.1, 0.35, Colors.deepOrange[400]],
      [-0.1, -0.7, primaryColor],
      [0.1, -0.6, primaryColor],
      [0.3, 0.6, primaryColor],
      [-0.2, 0.6, primaryColor],
      [0.0, 0.8, primaryColor],
      [0.7, 0.0, primaryColor],
      [-0.9, 0.0, primaryColor],
      [0.7, 0.0, primaryColor],
      [-0.8, -0.8, primaryColor],
      [-0.7, -0.6, primaryColor],
      [0.7, 0.6, primaryColor],
      [-0.7, 0.6, primaryColor],
      [0.7, -0.6, primaryColor],
    ]);

    List<Widget> mediumCircles = circleClusters.getCircleCluster(10, [
      [0.5, 0.0, Colors.deepOrange[400]]
    ]);

    List<Widget> largeCircles = circleClusters.getCircleCluster(
      //_largeCirclesAnimation.value,
      100,
      [
        [-1.3, 1.3, primaryColor],
      ],
    );

    List<Widget> largerCircles = circleClusters.getCircleCluster(
        //_largerCirclesAnimation.value,
        110,
        [
          [1.4, -1.3, primaryColor]
        ]);

    List<Widget> otherCirclesAndWaves = [
      Align(
        alignment: Alignment(-0.7, 0),
        child: HotCircle(
          gradient: RadialGradient(
            center: Alignment(1, 0),
            colors: [Colors.deepOrange[400] ?? Colors.deepOrange, primaryColor],
            radius: 0.5,
          ),
          borderColor: Colors.transparent,
          color: Colors.deepOrange[400] ?? Colors.deepOrange,
          radius: 25,
        ),
      ),

      Align(
        alignment: Alignment(0, -0.5),
        child: HotCircle(
          gradient: RadialGradient(
            center: Alignment(0, 1),
            colors: [Colors.deepOrange[400] ?? Colors.deepOrange, primaryColor],
            radius: 0.5,
          ),
          borderColor: Colors.transparent,
          color: Colors.deepOrange[400] ?? Colors.deepOrange,
          radius: 20,
        ),
      ),

      AnimatedAlign(
        duration: Duration(milliseconds: 2000),
        alignment: Alignment(0, 0),
        child: HotCircle(
          borderColor: Colors.deepOrange,
          color: Colors.transparent,
          radius: _wave1Animation.value,
        ),
      ),

      AnimatedAlign(
        duration: Duration(milliseconds: 2000),
        alignment: Alignment(0, 0),
        child: HotCircle(
          borderColor: Colors.deepOrange,
          color: Colors.transparent,
          radius: _wave2Animation.value,
        ),
      ),

      // Outer wave
      const AnimatedAlign(
        duration: Duration(milliseconds: 2000),
        alignment: Alignment(0, 0),
        child: HotCircle(
          borderColor: Colors.deepOrange,
          color: Colors.transparent,
          radius: 145,
        ),
      ),
    ];

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            "HOT",
            style: TextStyle(
                fontFamily: "Avenir-Heavy", fontSize: 18, color: Colors.black),
          ),
        ),
        body: FutureBuilder<List<QueryDocumentSnapshot>>(
            future: _topEvents,
            builder: (BuildContext context,
                AsyncSnapshot<List<QueryDocumentSnapshot>> snapshot) {
              if (snapshot.hasError) {
                return Text("Something went wrong");
              }

              if (snapshot.data != null && snapshot.data!.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[

                        Image.asset("assets/intro/nohotevents.png", scale: 3,),
                        const SizedBox(height: 30),
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: TextStyle(fontSize: 18, fontFamily: "Avenir-Medium", color: Colors.black),
                            children: [
                              TextSpan(text: "There are no hot public events right now. \nCreate your own from the "),
                              WidgetSpan(
                                child: Container(
                                  width: 27.0,
                                  height: 27.0,
                                  decoration: new BoxDecoration(
                                    color: primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.add, color: Colors.white, size: 20,),
                                ),
                              ),
                              TextSpan(text: " page!"),
                            ],
                          ),
                        ),
                        const SizedBox(height: 60),
                      ],
                    ),
                  );
              }

              if (snapshot.data != null && snapshot.connectionState == ConnectionState.done) {
                return Stack(
                    children: starCircles +
                        mediumCircles +
                        largeCircles +
                        largerCircles +
                        otherCirclesAndWaves +
                        getHotEvents(snapshot.data, width));
              }
              return Stack(
                  children: starCircles +
                      mediumCircles +
                      largeCircles +
                      largerCircles);
            }));
  }
}
