import 'dart:async';
import 'package:bouncr/blocs/app_blocs.dart';
import 'package:bouncr/components/CircleProgress.dart';
import 'package:bouncr/components/EditTap.dart';
import 'package:bouncr/components/RoundedButton.dart';
import 'package:bouncr/components/TwoLayerButton.dart';
import 'package:bouncr/models/theme.dart';
import 'package:bouncr/models/user.dart';
import 'package:bouncr/screens/home/edit_date.dart';
import 'package:bouncr/screens/home/edit_description.dart';
import 'package:bouncr/screens/home/edit_event_name.dart';
import 'package:bouncr/screens/home/edit_location.dart';
import 'package:bouncr/screens/home/edit_time.dart';
import 'package:bouncr/services/database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:math';
import 'dart:io';
import 'package:image_cropper/image_cropper.dart';

class Event extends StatefulWidget {
  final String eventName;
  final String eventId;
  final String description;
  final String formattedAddress;
  final String date;
  final String time;
  final String host;
  final String type;
  final List guests;
  final List guestUids;
  final int capacity;
  final int attendance;
  final String image;
  final String userFirstname;
  final String userLastname;
  final String atEvent;
  final String userProfilePic;
  final List attending;
  final String username;
  final double lat;
  final double lng;

  const Event({
    Key? key,
    required this.eventName,
    required this.eventId,
    required this.description,
    required this.formattedAddress,
    required this.date,
    required this.time,
    required this.host,
    required this.type,
    required this.capacity,
    required this.attendance,
    required this.image,
    required this.userFirstname,
    required this.userLastname,
    required this.atEvent,
    required this.guestUids,
    required this.attending,
    required this.userProfilePic,
    required this.username,
    required this.lat,
    required this.lng,
    this.guests = const [],
  }) : super(key: key);

  @override
  _EventState createState() => _EventState();
}

class _EventState extends State<Event> with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController progressController;
  late AnimationController hereButtonBottomController;
  late AnimationController hereButtonTopController;

  // Animations
  late Animation animation;
  late Animation hereButtonAnimationBottom;
  late Animation hereButtonAnimationTop;

  // Whether or not a change has been made
  bool change = false;

  // Whether or not the image is loading
  bool loadingImg = false;

  bool uploadingToAln = false;

  // Event attributes
  late String _eventName;
  late String _eventTime;
  late String _eventImage;
  late String _eventDescription;
  late String _eventAddress;
  late String _eventDate;

  // Whether or not the user is at this event
  late bool _atEvent;

  // The colors of the here/leave button
  late Color hereButtonColorBottom;
  late Color hereButtonColorTop;

  // Whether or not the user has tapped the here/leave button
  bool _tapped = false;

  @override
  void initState() {
    super.initState();
    //print("Attending event: ${widget.atEvent}");

    // Initializing event name and time based on given data
    _eventName = widget.eventName;
    _eventTime = widget.time;
    _eventImage = widget.image;
    _eventDescription = widget.description;
    _atEvent = widget.eventId == widget.atEvent;
    _eventAddress = widget.formattedAddress;
    _eventDate = widget.date;

    // Initializing animation controllers
    progressController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 2000));
    hereButtonBottomController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    hereButtonTopController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));

    // Computing attendance/capacity ration
    double privRatio = widget.guests.length == 0
        ? 0
        : widget.attendance / widget.guests.length;
    double ratio = widget.type == "private"
        ? privRatio
        : widget.attendance / widget.capacity;

    if (!_atEvent) {
      hereButtonColorBottom = primaryColor;
      hereButtonColorTop = primaryLight;
    } else {
      hereButtonColorBottom = Colors.red[400] ?? Colors.red;
      hereButtonColorTop = Colors.red.withOpacity(0.5);
      hereButtonBottomController.forward();
      hereButtonTopController.forward();
    }

    // Initializing animations
    animation =
        Tween<double>(begin: 0, end: ratio * 100).animate(progressController)
          ..addListener(() {
            setState(() {});
          });
    hereButtonAnimationBottom = Tween<double>(begin: 0, end: -pi / 2)
        .animate(hereButtonBottomController)
          ..addListener(() {
            setState(() {});
          });
    hereButtonAnimationTop = Tween<double>(begin: -pi / 4, end: pi / 4)
        .animate(hereButtonTopController)
          ..addListener(() {
            setState(() {});
          });

    progressController.forward();
  }

  @override
  void dispose() {
    progressController.dispose();
    hereButtonBottomController.dispose();
    hereButtonTopController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel?>(context);
    DatabaseService db = DatabaseService(uid: user!.uid);
    bool isHost = user.uid == widget.host;
    final appBloc = Provider.of<AppBloc>(context);
    double distanceFromEventInMeters = double.infinity;

    if(appBloc.currentLocation != null){
      distanceFromEventInMeters = Geolocator.distanceBetween(
        appBloc.currentLocation!.latitude, 
        appBloc.currentLocation!.longitude,
        widget.lat, 
        widget.lng
      );
    }


    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(change),
        ),
        backgroundColor: Colors.white,
        title: Text(
          "Event Details",
          style: TextStyle(
              fontFamily: "Avenir-Heavy", fontSize: 18, color: Colors.black),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [

              // Image and edit button
              Stack(
                children: [
                  // Event image
                  !loadingImg? 
                  _eventImage == ""? 
                  Image.asset("assets/partyimage.jpeg")
                  : CachedNetworkImage(
                    imageUrl: _eventImage,
                    placeholder: (context, url) => Container(
                      width: double.infinity,
                      height: 200,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: primaryColor,
                      )
                    )
                  ),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                )
                : Container(
                    width: double.infinity,
                    height: 200,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: primaryColor,
                      )
                    )
                  ),

                  // Edit Image Button
                  isHost? Positioned(
                          bottom: 10,
                          right: 0,
                          child: ElevatedButton(
                            onPressed: () async {
                              setState(() {
                                loadingImg = true;
                              });
                              var url = await loadPicker(user.uid!, widget.eventId, ImageSource.gallery, "eventpic");

                              // Update db path
                              if (url != "") {
                                db.updateEventPicture(widget.eventId, url);
                                change = true;
                                _eventImage = url;
                              }
                              setState(() {
                                loadingImg = false;
                              });
                            },
                            child: Icon(
                              Icons.edit,
                              color: Colors.white,
                            ),
                            style: ElevatedButton.styleFrom(
                              shape: CircleBorder(),
                              padding: EdgeInsets.all(10),
                              primary: primaryColor, // <-- Button color
                              onPrimary: Colors.white, // <-- Splash color
                            ),
                          ),
                        )
                      : SizedBox()
                ],
              ),

              isHost? 
              Padding(
                padding: const EdgeInsets.only(top:12.0),
                child: Text(
                  "Your guests can use this EID to join: ${widget.eventId}",
                  style: TextStyle(
                    fontFamily: "Avenir-Medium",
                    fontSize: 15
                  ),
                ),
              )
              :SizedBox(),

              // Row containing event name, event start time and attendance/capacity ratio
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Event name
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 12.0, top: 10),
                            child: Text(
                              _eventName,
                              style: TextStyle(
                                  fontFamily: "Avenir-Heavy", fontSize: 22),
                            ),
                          ),

                          // If the user is the host, show an edit option
                          isHost
                              ? EditTap(
                                  iconSize: 20,
                                  onTap: () async {
                                    // returnData[0] -> bool wether there has been a change or not
                                    // returnData[1] -> the new event name
                                    List? nameReturnData = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => EditEventName(
                                                eventId: widget.eventId,
                                              )),
                                    );

                                    if (nameReturnData != null) {
                                      // Update "change" boolean
                                      change = change || nameReturnData[0];

                                      // If a change has been made, change the event name displayed
                                      if (nameReturnData[0]) {
                                        setState(() {
                                          _eventName = nameReturnData[1];
                                        });
                                      }
                                    }
                                  })
                              : SizedBox(),
                        ],
                      ),

                      // Event start time
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 12.0, top: 10),
                            child: RichText(
                              text: TextSpan(
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: "Avenir-Medium",
                                    fontSize: 15,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: "Starts at ",
                                    ),
                                    TextSpan(
                                        text: _eventTime,
                                        style: TextStyle(
                                            fontFamily: "Avenir-Heavy"))
                                  ]),
                            ),
                          ),
                          isHost
                              ? EditTap(
                                  iconSize: 20,
                                  onTap: () async {
                                    // Push the page to change the event time
                                    // Store changes in timeReturnData
                                    // timeReturnData[0] is a bool, if true then a change was made
                                    // timeReturnData[1] is a string, if not "", then it is the new event time
                                    List? timeReturnData = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => EditTime(
                                                eventId: widget.eventId,
                                              )),
                                    );

                                    if (timeReturnData != null) {
                                      // Update "change" boolean
                                      change = change || timeReturnData[0];

                                      // If a change has been made, change the event time displayed
                                      if (timeReturnData[0]) {
                                        setState(() {
                                          _eventTime = timeReturnData[1];
                                        });
                                      }
                                    }
                                  })
                              : SizedBox(),
                        ],
                      ),

                      // Event date
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 12.0, top: 10),
                            child: RichText(
                              text: TextSpan(
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: "Avenir-Medium",
                                    fontSize: 15,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: "On ",
                                    ),
                                    TextSpan(
                                        text: _eventDate.substring(0, 4) + "/" +
                                        _eventDate.substring(4, 6) + "/" +
                                        _eventDate.substring(6, 8),
                                        style: TextStyle(
                                            fontFamily: "Avenir-Heavy"))
                                  ]),
                            ),
                          ),
                          isHost
                              ? EditTap(
                                  iconSize: 20,
                                  onTap: () async {
                                    // Push the page to change the event time
                                    // Store changes in timeReturnData
                                    // timeReturnData[0] is a bool, if true then a change was made
                                    // timeReturnData[1] is a string, if not "", then it is the new event time
                                    List? dateReturnData = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => EditEventDate(
                                                eventId: widget.eventId,
                                              )),
                                    );

                                    if (dateReturnData != null) {
                                      // Update "change" boolean
                                      change = change || dateReturnData[0];

                                      // If a change has been made, change the event time displayed
                                      if (dateReturnData[0]) {
                                        setState(() {
                                          _eventDate = dateReturnData[1];
                                        });
                                      }
                                    }
                                  })
                              : SizedBox(),
                        ],
                      ),
                    ],
                  ),

                  // Event attendance/capacity ratio circle
                  Padding(
                    padding: const EdgeInsets.only(right: 15.0, top: 20),
                    child: CustomPaint(
                      foregroundPainter:
                          CircleProgress(animation.value, primaryColor),
                      child: Container(
                        width: 100,
                        height: 100,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                center: Alignment(0, 0),
                                colors: [
                                  //Color.fromRGBO(3, 235, 255, 1),
                                  Colors.red,
                                  Color.fromRGBO(152, 70, 242, 1)
                                ],
                                radius: animation.value / 100,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // "Address" title
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      "Address",
                      style: TextStyle(fontFamily: "Avenir-Heavy", fontSize: 17.5),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  isHost? EditTap(
                    iconSize: 20,
                    onTap: () async {
                      List? locationReturnData = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) =>
                          ChangeNotifierProvider(
                            create: (context) => AppBloc(),
                            child: EditEventLocation(
                              eventId: widget.eventId,
                            ),
                          ),
                        ),
                      );

                      if (locationReturnData != null) {
                        // Update "change" boolean
                        change = change || locationReturnData[0];

                        // If a change has been made, change the event name displayed
                        if (locationReturnData[0]) {
                          setState(() {
                            _eventAddress = locationReturnData[1];
                          });
                        }
                      }
                      
                    },
                  ):SizedBox()
                ],
              ),

              Padding(
                padding: const EdgeInsets.only(
                    left: 25, right: 25, top: 10, bottom: 10),
                child: Text(
                  _eventAddress,
                  style: TextStyle(fontFamily: "Avenir-Medium", fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),

              // "Description" title
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  "Description",
                  style: TextStyle(fontFamily: "Avenir-Heavy", fontSize: 17.5),
                  textAlign: TextAlign.center,
                ),
              ),

              // Description text container
              Padding(
                padding: const EdgeInsets.only(
                    left: 12.0, right: 12.0, top: 10, bottom: 10),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 1),
                      borderRadius: BorderRadius.all(Radius.circular(15))),
                  child: Column(
                    crossAxisAlignment: _eventDescription.length == 0
                        ? CrossAxisAlignment.center
                        : CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                            _eventDescription.length == 0
                                ? "No description"
                                : _eventDescription,
                            style: TextStyle(
                              fontFamily: "Avenir-Medium",
                              fontSize: 16,
                            )),
                      ),
                      isHost? Row(
                        children: [
                          Expanded(child: SizedBox()),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8, right: 8),
                            child: EditTap(
                              iconSize: 20,
                              onTap: () async {
                                List? descriptionReturnData = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                    EditDescription(
                                      eventId: widget.eventId,
                                      currentDescription: _eventDescription,   
                                    )
                                  ),
                                );

                                if (descriptionReturnData != null) {
                                  // Update "change" boolean
                                  change = change ||
                                      descriptionReturnData[0];

                                  // If a change has been made, change the event name displayed
                                  if (descriptionReturnData[0]) {
                                    setState(() {
                                      _eventDescription =
                                          descriptionReturnData[1];
                                    });
                                  }
                                }
                              },
                            ),
                          ),
                          ],
                        )
                      : SizedBox()
                    ],
                  ),
                ),
              ),

              // If event type is private, show the "Guest List" title
              widget.type == "private"
                  ? Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        "Guest List",
                        style: TextStyle(
                            fontFamily: "Avenir-Heavy", fontSize: 17.5),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : SizedBox(),

              // If the event is private and there are guests, show a container with the guest names
              // If the event is private and there are no guests, show a container with "no guests"
              // If the event is public, show nothing
              widget.type == "private" && widget.guests.length != 0
                  ? Padding(
                      padding: const EdgeInsets.only(
                          left: 12.0, right: 12.0, top: 10),
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 1),
                            borderRadius:
                                BorderRadius.all(Radius.circular(15))),

                        // This builds the guest list container with all the guest names and option to remove a guest
                        child: ListView.builder(
                            itemCount: widget.guests.length,
                            itemBuilder: (context, index) {

                              return ListTile(
                                title: Text("${widget.guests[index]["firstname"]} ${widget.guests[index]["lastname"]}"),
                                trailing: isHost? 
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext dialogContext) =>
                                        AlertDialog(
                                          title: Text("Remove ${widget.guests[index]["firstname"]}?",
                                            style: TextStyle(color: Colors.white,fontFamily:"Avenir-Medium"),
                                           ),
                                          actions: [
                                            ElevatedButton(
                                              onPressed: () async {

                                                var success = await db.removeGuest(
                                                  widget.eventId,
                                                  widget.guests[index]["firstname"],
                                                  widget.guests[index][ "lastname"],
                                                  widget.guests[index]["uid"]
                                                );
                                                if (success) {
                                                  if (widget.attending.contains(widget.guests[index]["uid"])){
                                                    success = await db.removeUserFromAttending(widget.eventId, widget.guests[index]["uid"])
                                                    && await db.decrementAttendance(widget.eventId);
                                                  }

                                                  setState(() {
                                                    widget.guests.removeAt(index);
                                                    change = true;
                                                  });
                                                }
                                                Navigator.pop(dialogContext);
                                              },
                                              child: Text( "Remove",style: TextStyle(color: Colors.white,fontFamily: "Avenir-Heavy"),),
                                              style: ElevatedButton.styleFrom(primary:Colors.red),
                                            ),
                                                
                                            ElevatedButton(
                                              onPressed: () {Navigator.pop(dialogContext);},
                                              child: Text("Keep",style: TextStyle(color:Colors.white),),
                                              style: ElevatedButton.styleFrom(primary:primaryColor),
                                            ),
                                          ],
                                          backgroundColor:primaryColor,
                                          shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(10)),
                                        ));
                                      },
                                      child: Icon(Icons.remove,color: Colors.red,)
                                    )
                                    : widget.attending.contains(widget.guests[index]["uid"])? 
                                    Icon(Icons.circle,color: Colors.green,): null,
                              );
                            }
                          ),
                      ),
                    )
                  : widget.type == "private"
                      ? Padding(
                          padding: const EdgeInsets.only(
                              left: 12.0, right: 12.0, top: 10),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black, width: 1),
                              borderRadius: BorderRadius.all(Radius.circular(15))
                            ),
                            height: 50,
                            width: double.infinity,
                            child: Center(
                              child: Text("No guests"),
                            ),
                          ),
                        )
                      : SizedBox(),
              
              // About last night button
              AnimatedSwitcher(
                duration: Duration(milliseconds: 400),
                child: _atEvent? 
                !uploadingToAln? Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10, top: 15),
                  child: GestureDetector(
                    onTap: () async {

                      setState(() {
                        uploadingToAln = true;
                      });
                      var url = await loadPicker(user.uid!, widget.eventId, ImageSource.gallery, "aln");

                      // Update db path
                      if (url != "") {
                        //db.updateEventPicture(widget.eventId, url);
                        
                        bool success = await db.addAboutLastNightPic(
                          widget.eventId, 
                          url, 
                          widget.userFirstname, 
                          widget.userLastname,
                          widget.userProfilePic,
                          widget.username,
                          DateTime.now().toString()
                        );
                        change = true;
                        //_eventImage = url;
                        if(success){
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Upload successful"))
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Upload failed"))
                          );
                        }
                      }
                      setState(() {
                        uploadingToAln = false;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        border: Border.all(color: Colors.black, width: 1),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo, size: 30,),
                            SizedBox(width: 10,),
                            Text("Upload photo to 'About last night'", style: TextStyle(fontFamily: "Avenir-Heavy"))
                          ],
                        ),
                      ),
                    ),
                  ),
                ):Image.asset("assets/loading_transparent.gif",height: 125.0,width: 125.0,)
                :SizedBox()
              ),

              // "I'm here/Leave" button (only visible for non-hosts)
              // Hosts should have a button to display QR code
              isHost || distanceFromEventInMeters > 50? SizedBox(): 
              TwoLayerButton(
                onTap: _tapped? null
                : () async {

                  setState(() {
                    _tapped = true;
                  });
                  if (_atEvent) {
                    bool success = await db.decrementAttendance(widget.eventId) &&
                        await db.removeUserFromAttending(widget.eventId, user.uid!);
                    if (success) {
                      hereButtonColorBottom = primaryColor;
                      hereButtonColorTop = primaryLight;
                      hereButtonBottomController.reverse();
                      hereButtonTopController.reverse();
                      widget.attending.remove(user.uid);
                      _atEvent = !_atEvent;
                    }
                  }
                  // If the user is not at this event
                  else {
                    bool success1 = true;
                    if (widget.atEvent != "" && widget.atEvent != widget.eventId) {
                      success1 = await db.decrementAttendance(widget.atEvent) &&
                      await db.removeUserFromAttending(widget.atEvent, user.uid!);
                    }
                    bool success2 = false;
                    if (success1) {
                      success2 = await db.addUsertoAttending(widget.eventId) &&
                      await db.incrementAttendance(widget.eventId);
                    }
                    if (success2) {
                      hereButtonColorBottom = Colors.red[400] ?? Colors.red;
                      hereButtonColorTop = Colors.red.withOpacity(0.5);
                      hereButtonBottomController.forward();
                      hereButtonTopController.forward();
                      widget.attending.add(user.uid);
                      _atEvent = !_atEvent;
                    }
                  }
                  setState(() {
                    Timer(Duration(seconds: 1), () => setState(() => _tapped = false));
                    change = true;
                  });
                },
                atEvent: _atEvent,
                bottomAnimationValue: hereButtonAnimationBottom.value,
                topAnimationValue: hereButtonAnimationTop.value,
                topColor: hereButtonColorTop,
                bottomColor: hereButtonColorBottom
              ),

              // "DELETE" or "REMOVE" event
              widget.guestUids.contains(user.uid) || isHost
                  ? Padding(
                      padding: const EdgeInsets.only(top: 30, bottom: 40),
                      child: RoundedButton(
                          horizontalPadding: 70,
                          text: isHost ? "DELETE EVENT" : "REMOVE EVENT",
                          press: () {
                            // Give user "Are you sure?" pop up
                            showDialog(
                                context: context,
                                builder: (BuildContext dialogContext) =>
                                    AlertDialog(
                                      title: Text(
                                        "Are you sure?",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: "Avenir-Medium"),
                                      ),
                                      actions: [
                                        ElevatedButton(
                                          onPressed: () async {
                                            // If the user if the host, delete the event from database
                                            // Otherwise, remove the user from the guest list
                                            var success = isHost
                                                ? await db.deleteEvent(widget.eventId)
                                                : await db.removeGuest(
                                                    widget.eventId,
                                                    widget.userFirstname,
                                                    widget.userLastname,
                                                    user.uid!
                                                  );

                                            // If the user is at this event, remove him from it
                                            if (success && _atEvent) {
                                              await db.decrementAttendance(widget.eventId) &&
                                                  await db.removeUserFromAttending(widget.eventId, user.uid!);
                                            }

                                            // Pop to the previous page
                                            Navigator.pop(dialogContext);
                                            if (success) {
                                              Navigator.pop(context, true);
                                            }
                                          },
                                          child: Text(
                                            isHost ? "Delete" : "Remove",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontFamily: "Avenir-Heavy"),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                              primary: Colors.red),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(dialogContext);
                                          },
                                          child: Text(
                                            "Keep",
                                            style: TextStyle(color: Colors.white),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                              primary: primaryColor),
                                        ),
                                      ],
                                      backgroundColor: primaryColor,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15)),
                                    ));
                          },
                          textstyle: buttonFontStyle,
                          buttoncolor: Colors.red),
                    )
                  : Padding(
                      padding: const EdgeInsets.only(top: 30, bottom: 40),
                      child: RoundedButton(
                          horizontalPadding: 50,
                          text: "Add to my events",
                          press: () async {
                            bool added = await db.addGuest(widget.eventId,
                                widget.userFirstname, widget.userLastname);
                            if (added) {
                              setState(() {
                                widget.guestUids.add(user.uid);
                              });
                            }
                          },
                          textstyle: buttonFontStyle,
                          buttoncolor: primaryColor),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Future loadPicker(String uid, String eid, ImageSource source, String dbPath) async {
    final ImagePicker _picker = ImagePicker();

    // Pick an image
    final XFile? picked = await _picker.pickImage(source: source).catchError((e) {
      print("stupid error start:");
      print(e);
      print("stupid error end");
    });

    if (picked == null) {
      return "";
    }

    File? croppedFile;
    if (dbPath == "aln"){
      croppedFile = await ImageCropper.cropImage(
        sourcePath: picked.path,
        aspectRatio: CropAspectRatio(ratioX: 1.91, ratioY: 1.2),
        maxWidth: 1350,
        maxHeight: 1080,
      );
    }

    if(dbPath == "aln" && croppedFile == null){
      print("cropped file is null");
      return "";
    }

    // Upload image to database storage
    final File pickedFile = File(dbPath == "aln"? croppedFile!.path: picked.path);
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = dbPath != "aln"? 
    storage.ref().child('event_pictures').child(eid)
    : storage.ref().child('about_last_night').child(eid).child(uid + "-" + UniqueKey().toString());
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
