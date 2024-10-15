import 'dart:async';
import 'dart:collection';
import 'package:bouncr/blocs/app_blocs.dart';
import 'package:bouncr/components/ErrorContainer.dart';
import 'package:bouncr/components/RoundedButton.dart';
import 'package:bouncr/components/SignUpText.dart';
import 'package:bouncr/models/place.dart';
import 'package:bouncr/models/theme.dart';
import 'package:bouncr/models/user.dart';
import 'package:bouncr/services/database.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class EditEventLocation extends StatefulWidget {
  final String eventId;
  const EditEventLocation({ Key? key, required this.eventId}) : super(key: key);

  @override
  _EditEventLocationState createState() => _EditEventLocationState();
}

class _EditEventLocationState extends State<EditEventLocation> {

  String error = "";
  double containerWidth = 0;
  double containerHeight = 0;
  bool loading = false;
  // Selected place ID
  String selectedPlaceId = "";
  late GoogleMapController mapController;
  Set<Marker> _markers = HashSet<Marker>();
  final TextEditingController _addressController = TextEditingController();

  void spawnContainer(String e) {
    setState(() {
      containerHeight = 30;
      containerWidth = 250;
      error = e;
    });
  }

  void removeContainer() {
    setState(() {
      containerHeight = 0;
      containerWidth = 0;
    });
  }

  void shakeContainer() {
    setState(() {
      containerWidth += 30;
    });
    Timer(Duration(milliseconds: 300), () {
      setState(() {
        containerWidth -= 30;
      });
    });
  }


  bool checkLoc(AppBloc bloc){
    if (bloc.selectedLocation == null){
      if(containerWidth == 0){
        spawnContainer("Please choose a location");
      }
      else{
        shakeContainer();
      }
      return false;
    }
    else{
      removeContainer();
      return true;
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> _goToPlace(Place place) async{
    //final GoogleMapController controller = await _mapController.future;
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(place.geometry.location.lat, place.geometry.location.lng), zoom: 15)
      )
    );
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {

    double width = MediaQuery.of(context).size.width;
    final user = Provider.of<UserModel?>(context);
    DatabaseService db = DatabaseService(uid: user!.uid);
    final appBloc = Provider.of<AppBloc>(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
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
                        onPressed: () {Navigator.pop(context, [false, ""]);},
                        child: Icon(Icons.arrow_back)),
                  ),
                  Expanded(child: SizedBox()),
                ],
              ),

              // "Change event name" text
              Padding(
                padding: EdgeInsets.fromLTRB(0, 30, 0, 62.5),
                child: SignUpText(text: "Change location"),
              ),

              // "Event location" text field
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: TextFormField(
                    controller: _addressController,
                    autocorrect: false,
                    textCapitalization: TextCapitalization.words,
                    cursorColor: primaryColor,
                    decoration: textFieldDecorationSignUp.copyWith(
                        labelText: "Event location",
                        filled: true,
                        fillColor: Colors.white,
                        suffixIcon: Icon(Icons.search, color: primaryColor ,)
                      ),
                    onChanged: (text) {
                      setState(() {
                        appBloc.searchPlaces(text);
                      });
                    },
                  ),
                ),

                // Custom error message for location
                Padding(
                  padding: EdgeInsets.only(bottom: containerWidth == 0? 0:20),
                  child: ErrorContainer(containerWidth: containerWidth, containerHeight: containerHeight, error: error),
                ),

                // Google map 
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20,),
                  child: Container(
                    height: 220,
                    width: width,
                    decoration: BoxDecoration(
                      border: Border.all(color: primaryColor, width: 2.5),
                    ),
                    child: Stack(
                      children: [
                        appBloc.currentLocation == null? Center(child: Text("loading...")) : GoogleMap(
                          markers: _markers,
                          myLocationButtonEnabled: false,
                          myLocationEnabled: true,
                          onMapCreated: _onMapCreated,
                          initialCameraPosition: CameraPosition(
                            target: LatLng(appBloc.currentLocation!.latitude, appBloc.currentLocation!.longitude),
                            zoom: 15.0,
                          ),
                        ),
                        appBloc.searchResults != null && appBloc.searchResults!.length != 0? 
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            backgroundBlendMode: BlendMode.darken,
                          ),
                          child: ListView.builder(
                            itemCount: appBloc.searchResults == null? 0: appBloc.searchResults!.length,
                            itemBuilder: (context, index){

                              return ListTile(
                                title: Text(appBloc.searchResults![index].description, style: TextStyle(color: Colors.white, fontFamily: "Avenir-Medium"),),
                                trailing: Icon(Icons.pin_drop_outlined, color: Colors.white,),
                                onTap: () async {
                                  _addressController.text = appBloc.searchResults![index].description;
                                  selectedPlaceId = appBloc.searchResults![index].placeId;
                                  await appBloc.setSelectedLocation(selectedPlaceId);
                                  if(appBloc.selectedLocation != null){
                                    _goToPlace(appBloc.selectedLocation!);
                                    _markers.add(
                                      Marker(
                                        markerId: MarkerId(selectedPlaceId),
                                        position: LatLng(appBloc.selectedLocation!.geometry.location.lat,
                                        appBloc.selectedLocation!.geometry.location.lng),
                                      )
                                    );
                                  }
                                  checkLoc(appBloc);
                                },
                              );
                            },
                          ),
                        ): SizedBox(),
                      ],
                    ),
                  ),
                ),

              // "SUBMIT" button to go back to event details
              Padding(
                padding:
                    EdgeInsets.fromLTRB(30, 60, 30, 25),
                child: RoundedButton(
                  text: loading ? "Verifying..." : "UPDATE",
                  horizontalPadding: loading ? 86 : 110,
                  press: () async {
                    bool success = false;

                    // Check if event name field is not blank
                    if(checkLoc(appBloc)){
                      setState(() {
                        loading = true;
                      });

                      // Change event name in database
                      success = await db.updateEventLocation(
                        widget.eventId,
                        appBloc.selectedLocation!.name,
                        appBloc.selectedLocation!.geometry.location.lat,
                        appBloc.selectedLocation!.geometry.location.lng,
                        appBloc.selectedLocation!.vicinity,
                        selectedPlaceId,
                      );

                      // If change was successful, go back to details
                      if(success){
                        Navigator.pop(context, [true, appBloc.selectedLocation!.name]);
                      }
                      // Otherwise display error message
                      else{
                        spawnContainer("Database error");
                      }
                      setState(() {
                        loading = false;
                      });
                    }
                  },
                  textstyle: buttonFontStyle.copyWith(color: Colors.white),
                  buttoncolor: primaryColor
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}