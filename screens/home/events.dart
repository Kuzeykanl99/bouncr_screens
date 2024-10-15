import 'package:bouncr/blocs/app_blocs.dart';
import 'package:bouncr/components/EventContainer.dart';
import 'package:bouncr/models/theme.dart';
import 'package:bouncr/models/user.dart';
import 'package:bouncr/screens/home/aln_event.dart';
import 'package:bouncr/screens/home/create_event.dart';
import 'package:bouncr/screens/home/event.dart';
import 'package:bouncr/screens/home/pastEvents.dart';
import 'package:bouncr/services/database.dart';
// import 'package:bouncr/services/world_time.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:provider/provider.dart';

class Events extends StatefulWidget {
  const Events({Key? key}) : super(key: key);

  @override
  _EventsState createState() => _EventsState();
}

class _EventsState extends State<Events> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel?>(context);
    final db = DatabaseService(uid: user!.uid);
    final userData = Provider.of<UserData?>(context);
    //final worldTime = WorldTime(url: "America/Toronto");
    double width = MediaQuery.of(context).size.width;

    // Search text field
    Widget searchEID = Padding(
      padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: TextFormField(
        controller: _searchController,
        autocorrect: false,
        textCapitalization: TextCapitalization.words,
        cursorColor: primaryColor,
        decoration: textFieldDecorationSignUp.copyWith(
          labelText: "Search #EID",
          filled: true,
          fillColor: Colors.white,
          suffixIcon: IconButton(
            icon: Icon(Icons.search),
            color: primaryColor,
            onPressed: () async {

              if(!_searchController.text.isEmpty){
                var result = await db.getEvent(_searchController.text);
                bool found = result != null;
                var hostUsername;
                //var userInfo;

                // Check if event exists
                if (found) {
                  // If user is already in the event or is the host, show a pop up and stop
                  if (result["host"] == user.uid || result["guests"].contains(user.uid)) {
                    showDialog(
                      context: context,
                      builder: (BuildContext dialogContext) => AlertDialog(
                        title: Text(
                          "Already in event",
                          style: TextStyle(color: Colors.white,fontFamily: "Avenir-Medium",),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(dialogContext);
                            },
                            child: Text("OK", style: TextStyle(color: Colors.white),)
                          ),
                        ],
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      )
                    );
                    return;
                  }

                  // Get the host's username as well as the current user's info
                  hostUsername = await db.getUsername(result["host"]);
                }

                // Show the event and the option to add it
                showDialog(
                  context: context,
                  builder: (BuildContext dialogContext) => AlertDialog(
                    title: RichText(
                      text: TextSpan(
                        style: TextStyle(color: Colors.white,fontFamily: "Avenir-Medium",),
                        children: [
                          TextSpan(
                            text: found
                                ? "${result["eventName"]}"
                                : "Could not find event :(",
                            style: TextStyle(fontSize: 19),
                          ),
                          found? 
                          TextSpan(text: "\nby $hostUsername",style: TextStyle(fontSize: 15),)
                          : TextSpan(),
                        ]
                      ),
                    ),
                    content: found
                        ? ElevatedButton(
                            style: ElevatedButton.styleFrom(primary: Colors.white,),
                            child: Text(
                              "ADD",
                              style: TextStyle(color: primaryColor),
                            ),
                            onPressed: () async {
                              bool added = await db.addGuest(
                                  _searchController.text,
                                  userData!.firstname!,
                                  userData.lastname!);
                              if (added) {
                                _searchController.clear();
                                Navigator.pop(dialogContext);
                              }
                              setState(() {});
                            },
                          )
                        : SizedBox(),
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  )
                );
              }
            },
          ),
        ),
        onChanged: (text) {},
      ),
    );

    
    return userData == null || userData.firstname == "loading ..."? 
    Center(child: LoadingBouncingGrid.circle(backgroundColor: primaryColor,)): 
    Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("MY EVENTS", style: TextStyle(fontFamily: "Avenir-Heavy", fontSize: 18, color: Colors.black),),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait([db.getUserEvents(), db.getAttendingEvent()]),
        builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {

          if (snapshot.hasError) {
            return Text("Something went wrong");
          }
          
          // If data was successfully pulled
          if (snapshot.hasData && snapshot.connectionState == ConnectionState.done){

            if (snapshot.data![0] != null && snapshot.data![0].isEmpty) {
              return Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    // UI text
                    Padding(
                      padding: const EdgeInsets.only(top: 18.0),
                      child: Text("Don't forget the '#'", style: TextStyle(fontFamily: "Avenir-Medium"),),
                    ),

                    // EID searchbar
                    searchEID,

                    // Past events button
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PastEvents()),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: primaryOpacity10,
                            border:
                                Border.all(color: primaryOpacity10, width: 1),
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("Past Events",
                                    style: TextStyle(
                                        fontFamily: "Avenir-Heavy",
                                        fontSize: 16)),
                              ),
                              Expanded(child: const SizedBox()),
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(0, 0, 10.0, 0),
                                child: Icon(Icons.arrow_right_alt),
                              )
                            ],
                          ),
                        ),
                      ),
                    )

                  ],
                ),
              );
            }

            else {

              //print(snapshot.data![1][0]["eventId"]);
              List<Widget> widgets = [];

              // Padding the top
              widgets.add(SizedBox(width: width,));

              // Help text
              widgets.add(Padding(
                padding: const EdgeInsets.only(top: 18.0),
                child: Text("Don't forget the '#'", style: TextStyle(fontFamily: "Avenir-Medium"),),
              ));

              // Event search bar
              widgets.add(searchEID);

              // Past events button
              widgets.add(Padding(
                padding: const EdgeInsets.all(10.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PastEvents()),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: primaryOpacity10,
                      border:
                          Border.all(color: primaryOpacity10, width: 1),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("Past Events",
                            style: TextStyle(
                                fontFamily: "Avenir-Heavy",
                                fontSize: 16
                            )
                          ),
                        ),
                        Expanded(child: const SizedBox()),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 10.0, 0),
                          child: Icon(Icons.arrow_right_alt),
                        )
                      ],
                    ),
                  ),
                ),
              ));

              // Each event the user is a part of
              snapshot.data![0].forEach((element) {
                widgets.add(GestureDetector(
                  child: EventContainer(
                    eventName: element["eventName"],
                    eventId: element["eventId"],
                    imagePath: element["image"],
                  ),
                  onTap: () async {
                    // Check if call to worldtime api was successful
                    //if (snapshot.data![2] != null) {
                    // Compute if the event time is before tehe current eastern time
                    int hour = element["time"].substring(6, 10) == "P.M."? 
                    int.parse(element["time"].substring(0, 2)) + 12:int.parse(element["time"].substring(0, 2));
                    int minutes = int.parse(element["time"].substring(3, 5));
                    DateTime currentTime = DateTime.now();
                    DateTime eventTime = DateTime(
                      int.parse(element["date"].substring(0, 4)),
                      int.parse(element["date"].substring(4, 6)),
                      int.parse(element["date"].substring(6, 8)),
                      hour,
                      minutes
                    );

                    // If event is more than 12 hours in the past, show about last night
                    if (eventTime.difference(currentTime).inHours <= -12) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ALNEvent(
                            eventId: element["eventId"],
                            eventPicture: element["image"],
                            eventName: element["eventName"],
                            uid: user.uid!,
                          )
                        ),
                      );
                      // }
                      // // Otherwise, show the normal event details
                      // else {
                      //   // Push event details, if there's a change, rebuild
                      //   var change = await Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //         builder: (context) => Event(
                      //               eventName: element["eventName"],
                      //               eventId: element["eventId"],
                      //               description: element["description"],
                      //               formattedAddress:
                      //                   element["formattedAddress"],
                      //               date: element["date"],
                      //               time: element["time"],
                      //               host: element["host"],
                      //               type: element["type"],
                      //               guests:
                      //                   element["guestsDetails"] ?? [],
                      //               guestUids: element["guests"] ?? [],
                      //               capacity: element["maxCap"],
                      //               attendance: element["attendance"],
                      //               image: element["image"],
                      //               userFirstname: userData.firstname!,
                      //               userLastname: userData.lastname!,
                      //               atEvent: snapshot.data![1].isEmpty
                      //                   ? ""
                      //                   : snapshot.data![1][0]["eventId"],
                      //               attending: element["attending"],
                      //             )),
                      //   );
                      //   if (change != null && change) {
                      //     setState(() {});
                      //   }
                      // }
                    }
                    // If the worldtime api returns null, show the normal event details
                    else {
                      // Push event details, if there's a change, rebuild
                      var change = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => 
                          ChangeNotifierProvider(
                            create: (context) => AppBloc(),
                            child: Event(
                              eventName: element["eventName"],
                              eventId: element["eventId"],
                              description: element["description"],
                              formattedAddress: element["formattedAddress"],
                              date: element["date"],
                              time: element["time"],
                              host: element["host"],
                              type: element["type"],
                              guests: element["guestsDetails"] ?? [],
                              guestUids: element["guests"] ?? [],
                              capacity: element["maxCap"],
                              attendance: element["attendance"],
                              image: element["image"],
                              userFirstname: userData.firstname!,
                              userLastname: userData.lastname!,
                              userProfilePic: userData.imagePath,
                              username: userData.username!,
                              atEvent: snapshot.data![1].isEmpty
                                  ? ""
                                  : snapshot.data![1][0]["eventId"],
                              attending: element["attending"],
                              lat: element["lat"],
                              lng: element["lng"],
                            )
                          ),
                        ),
                      );
                      if (change != null && change) {
                        setState(() {});
                      }
                    }
                  },
                ));
              });

              widgets.add(SizedBox(
                height: 70,
              ));

              return SingleChildScrollView(
                child: Column(children: widgets),
              );
            }
          }
          // Loading widget
          return Center(
            child: Image.asset(
              "assets/loading_transparent.gif",
              height: 125.0,
              width: 125.0,
            ),
          );
        },
      ));
  }
}
