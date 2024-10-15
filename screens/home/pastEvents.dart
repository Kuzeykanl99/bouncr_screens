import 'package:bouncr/components/EventContainer.dart';
import 'package:bouncr/models/user.dart';
import 'package:bouncr/screens/home/aln_event.dart';
import 'package:bouncr/services/database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PastEvents extends StatefulWidget {
  const PastEvents({ Key? key }) : super(key: key);

  @override
  _PastEventsState createState() => _PastEventsState();
}

class _PastEventsState extends State<PastEvents> {
  @override
  Widget build(BuildContext context) {

    final user = Provider.of<UserModel?>(context);
    final db = DatabaseService(uid: user!.uid);
    double width = MediaQuery.of(context).size.width;


    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("Past Events", style: TextStyle(fontFamily: "Avenir-Heavy", fontSize: 18, color: Colors.black),),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: Future.wait([db.getUserPastEvents(), db.getAttendingEvent()]),
        builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {

          if (snapshot.hasError) {
            return Text("Something went wrong");
          }
          
          if (snapshot.hasData && snapshot.connectionState == ConnectionState.done){

            if (snapshot.data![0] != null && snapshot.data![0].isEmpty) {
              return Center(
                child: Text("No past events :("),
              );
            }

            else {

              List<Widget> widgets = [];

              // Padding the top
              widgets.add(SizedBox(width: width, height: 10,));

              // Each event the user was a part of
              snapshot.data![0].forEach((element) {
                widgets.add(
                  GestureDetector(
                    child: EventContainer(eventName: element["eventName"], eventId: element["eventId"], imagePath: element["image"],),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ALNEvent(
                            eventId: element["eventId"],
                            eventPicture: element["image"],
                            eventName: element["eventName"],
                            uid: user.uid!
                          )
                        ),
                      );
                    },
                  )
                );
              });

              widgets.add(SizedBox(height: 20,));

              return ListView(
                  children: widgets
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
      )
    );
  }
}