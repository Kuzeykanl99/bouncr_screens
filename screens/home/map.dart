import 'dart:collection';
import 'package:bouncr/blocs/app_blocs.dart';
import 'package:bouncr/models/theme.dart';
import 'package:bouncr/models/user.dart';
import 'package:bouncr/screens/home/event.dart';
import 'package:bouncr/services/database.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_marker/cached_network_marker.dart';

class Map extends StatefulWidget {
  const Map({Key? key}) : super(key: key);

  @override
  _MapState createState() => _MapState();
}

class _MapState extends State<Map> {
  late GoogleMapController mapController;
  late BitmapDescriptor customMapMarker;

  void _onMapCreated(GoogleMapController controller) {
    controller.setMapStyle(mapSyle);
    mapController = controller;
  }

  void setCustomMarker() async {
    customMapMarker = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(size: Size(2, 2)), "assets/markers/bouncr_marker");
  }

  @override
  void initState() {
    super.initState();
    setCustomMarker();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel?>(context);
    final appBloc = Provider.of<AppBloc>(context);
    final db = DatabaseService(uid: user!.uid);
    final userData = Provider.of<UserData?>(context);

    return Scaffold(
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait([db.getMapEvents(), db.getAttendingEvent()]),
        builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.hasError) {
            return Text("Something went wrong");
          }

          if (snapshot.data != null && snapshot.data![0] != null && snapshot.data![0].isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[

                  /*
                  Container(
                    height: 480.0,
                    width: 280.0,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/map.jpeg'),
                        fit: BoxFit.fill,
                      ),
                    ),
                  )
                  */

                  Image.asset("assets/intro/noevents.png", scale: 2.5,),
                  const SizedBox(height: 30),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: TextStyle(fontSize: 18, fontFamily: "Avenir-Medium", color: Colors.black),
                      children: [
                        TextSpan(text: 'There are no events planned for today. \nCreate your own from the '),
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

          if (snapshot.data != null && snapshot.data![0] != null && snapshot.connectionState == ConnectionState.done) {
            Set<Circle> _circles = HashSet<Circle>();
            //Set<Marker> _markers = HashSet<Marker>();

            snapshot.data![0].forEach((event) {
              // Computing attendance/capacity ratio
              double privRatio = event["guests"].length == 0
                  ? 0
                  : event["attendance"] / event["guests"].length;
              double ratio = event["type"] == "private"
                  ? privRatio
                  : event["attendance"] / event["maxCap"];

              Color _circleColor;
              if (ratio < 1 / 3) {
                _circleColor = Colors.lightBlue.withOpacity(0.7);
              } else if (ratio > 1 / 3 && ratio < 2 / 3) {
                _circleColor = Colors.purple.withOpacity(0.7);
              } else {
                _circleColor = Colors.deepOrange.withOpacity(0.7);
              }

              _circles.add(
                Circle(
                  circleId: CircleId(event["placeId"]),
                  center: LatLng(event["lat"], event["lng"]),
                  radius: 55,
                  strokeColor: Colors.transparent,
                  strokeWidth: 2,
                  fillColor: _circleColor,
                ),
              );

              /*
              _markers.add(
                Marker(
                  icon: customMapMarker,
                  markerId: MarkerId(event["placeId"]),
                  position: LatLng(event["lat"], event["lng"]),
                  infoWindow: InfoWindow(
                    
                    onTap: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Event(
                            eventName: event["eventName"],
                            eventId: event["eventId"],
                            description: event["description"],
                            formattedAddress: event["formattedAddress"],
                            date: event["date"],
                            time: event["time"],
                            host: event["host"],
                            type: event["type"],
                            guests: event["guestsDetails"] ?? [],
                            guestUids: event["guests"] ?? [],
                            capacity: event["maxCap"],
                            attendance: event["attendance"],
                            image: event["image"],
                            userFirstname: userData!.firstname!,
                            userLastname: userData.lastname!,
                            atEvent: snapshot.data![1].isEmpty? "" : snapshot.data![1][0]["eventId"],
                            attending: event["attending"],
                          )
                        ),
                      );
                    },
                    
                    title: event["eventName"],
                    snippet: "Tap for details"
                  ),
                ),
              );
              */
            });

            return appBloc.currentLocation == null
                ? Center(child: Text("loading..."))
                : FutureBuilder(
                    future: Future.wait(
                      List.generate(
                        snapshot.data![0].length,
                        (index) => CachedNetworkMarker(
                          url: snapshot.data![0][index]["image"] == ""
                              ? "https://i.ibb.co/rdY2fQT/single-bouncr.png"
                              : snapshot.data![0][index]["image"],
                          dpr: MediaQuery.of(context).devicePixelRatio,
                        ).circleAvatar(CircleAvatarParams(
                            color: primaryColor, radius: 35, borderWidth: 3)),
                      ),
                    ),
                    builder: (context, AsyncSnapshot<List<dynamic>> snap) {
                      if (snap.hasData) {
                        final bytes = snap.data;
                        final markers = List.generate(bytes!.length, (index) {
                          var event = snapshot.data![0][index];
                          return Marker(
                            markerId: MarkerId(index.toString()),
                            position: LatLng(event["lat"], event["lng"]),
                            icon: BitmapDescriptor.fromBytes(bytes[index]),
                            infoWindow: InfoWindow(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>  ChangeNotifierProvider(
                                          create: (context) => AppBloc(),
                                          child: Event(
                                            eventName: event["eventName"],
                                            eventId: event["eventId"],
                                            description: event["description"],
                                            formattedAddress: event["formattedAddress"],
                                            date: event["date"],
                                            time: event["time"],
                                            host: event["host"],
                                            type: event["type"],
                                            guests: event["guestsDetails"] ?? [],
                                            guestUids: event["guests"] ?? [],
                                            capacity: event["maxCap"],
                                            attendance: event["attendance"],
                                            image: event["image"],
                                            userFirstname:userData!.firstname!,
                                            userLastname: userData.lastname!,
                                            userProfilePic: userData.imagePath,
                                            username: userData.username!,
                                            atEvent: snapshot.data![1].isEmpty
                                                ? ""
                                                : snapshot.data![1][0]["eventId"],
                                            attending: event["attending"],
                                            lat: event["lat"],
                                            lng: event["lng"],
                                          ),
                                        )
                                      ),
                                  );
                                },
                                title: event["eventName"],
                                snippet: "Tap for details"),
                          );
                        });

                        return GoogleMap(
                          myLocationButtonEnabled: false,
                          myLocationEnabled: true,
                          onMapCreated: _onMapCreated,
                          markers: {...markers},
                          circles: _circles,
                          initialCameraPosition: CameraPosition(
                            target: LatLng(appBloc.currentLocation!.latitude,
                                appBloc.currentLocation!.longitude),
                            zoom: 16.5,
                          ),
                        );
                      }
                      return Center(
                        child: Image.asset(
                          "assets/loading_transparent.gif",
                          height: 125.0,
                          width: 125.0,
                        ),
                      );
                    },
                  );
          }

          return Center(
            child: Image.asset(
              "assets/loading_transparent.gif",
              height: 125.0,
              width: 125.0,
            ),
            //LoadingBouncingGrid.circle(backgroundColor: primaryColor,)
          );
        },
      ),
    );

    /*
    return appBloc.currentLocation == null? Center(child: Text("loading...")):GoogleMap(
      myLocationButtonEnabled: false,
      myLocationEnabled: true,
      onMapCreated: _onMapCreated,
      //markers: _markers,
      circles: _circles,
      initialCameraPosition: CameraPosition(
        target: LatLng(appBloc.currentLocation!.latitude, appBloc.currentLocation!.longitude),
        zoom: 15.0,
      ),
    );
    */
  }
}
