import 'dart:async';
import 'dart:collection';
import 'package:bouncr/blocs/app_blocs.dart';
import 'package:bouncr/components/CircularButtonText.dart';
import 'package:bouncr/components/DateField.dart';
import 'package:bouncr/components/DateFields.dart';
import 'package:bouncr/components/ErrorContainer.dart';
import 'package:bouncr/components/RoundedButton.dart';
import 'package:bouncr/components/SectionContainer.dart';
import 'package:bouncr/components/TimeFields.dart';
import 'package:bouncr/models/place.dart';
import 'package:bouncr/models/theme.dart';
import 'package:bouncr/models/user.dart';
import 'package:bouncr/services/database.dart';
import 'package:bouncr/services/date.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class CreateEvent extends StatefulWidget {
  const CreateEvent({ Key? key }) : super(key: key);

  @override
  _CreateEventState createState() => _CreateEventState();
}

class _CreateEventState extends State<CreateEvent> {

  var _addressController = TextEditingController();
  late GoogleMapController mapController;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  // A.M./P.M. toggle status (false is P.M.)
  bool toggleStatus = false;

  // Public/Private toggle (false is Public)
  bool typeToggle = false;
  Color button1Color = primaryColor;
  Color button1IconColor = Colors.white;

  Color button2Color = Colors.white;
  Color button2IconColor = Colors.black;

  Color createButtonColor = primaryColor;
  // Selected place ID
  String selectedPlaceId = "";

  // Map markers
  Set<Marker> _markers = HashSet<Marker>();

  // Error container dimensions and messages
  List<double> widths = [0, 0, 0, 0, 0];
  List<double> heights = [0, 0, 0, 0, 0];
  List<String> errors = ["", "", "", "", ""];

  // Focusnodes
  final FocusNode _hourFocus = FocusNode();
  final FocusNode _minuteFocus = FocusNode();
  final FocusNode _dayFocus = FocusNode();
  final FocusNode _monthFocus = FocusNode();
  final FocusNode _yearFocus = FocusNode();
  final FocusNode _capFocus = FocusNode();

  // Textfield controllers
  final TextEditingController _dayController = TextEditingController();
  final TextEditingController _monthController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _hourController = TextEditingController();
  final TextEditingController _minuteController = TextEditingController();
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _capacityController = TextEditingController();

  // Date service for checking if time and date are valid
  DateService dateService = DateService();

  _fieldFocusChange(BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  void spawnContainer(int index, String e) {
    setState(() {
      heights[index] = 30;
      widths[index] = 250;
      errors[index] = e;
    });
  }

  void removeContainer(int index) {
    setState(() {
      heights[index] = 0;
      widths[index] = 0;
    });
  }

  void shakeContainer(int index) {
    setState(() {
      widths[index] += 30;
    });
    Timer(Duration(milliseconds: 300), () {
      setState(() {
        widths[index] -= 30;
      });
    });
  }

  bool checkDate(){
    if (!dateService.isValidDate(_yearController.text, _monthController.text, _dayController.text)){
      if(widths[0] == 0){
        spawnContainer(0, "Please enter a valid date");
      }
      else{
        shakeContainer(0);
      }
      return false;
    }
    else{
      removeContainer(0);
      return true;
    }
  }

  bool checkTime(){
    if (!dateService.isValidTime(_hourController.text, _minuteController.text)){
      if(widths[1] == 0){
        spawnContainer(1, "Please enter a valid time");
      }
      else{
        shakeContainer(1);
      }
      return false;
    }
    else{
      removeContainer(1);
      return true;
    }
  }

  bool checkLoc(AppBloc bloc){
    if (bloc.selectedLocation == null){
      if(widths[2] == 0){
        spawnContainer(2, "Please choose a location");
      }
      else{
        shakeContainer(2);
      }
      return false;
    }
    else{
      removeContainer(2);
      return true;
    }
  }

  bool checkEventNameField(){
    if (_eventNameController.text.isEmpty){
      if(widths[3] == 0){
        spawnContainer(3, "Event name cannot be blank");
      }
      else{
        shakeContainer(3);
      }
      return false;
    }
    else{
      removeContainer(3);
      return true;
    }
  }

  bool checkCapacity(){
    if (_capacityController.text.isEmpty || _capacityController.text == "0"){
      if(widths[4] == 0){
        spawnContainer(4, "Capacity field cannot be blank or 0");
      }
      else{
        shakeContainer(4);
      }
      return false;
    }
    else{
      removeContainer(4);
      return true;
    }
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
  Widget build(BuildContext context) {

    double width = MediaQuery.of(context).size.width;
    final user = Provider.of<UserModel?>(context);
    final db = DatabaseService(uid: user!.uid);
    final appBloc = Provider.of<AppBloc>(context);

    return Scaffold(
      //backgroundColor: Colors.white54,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.white,
        title: Text("CREATE EVENT", style: TextStyle(fontFamily: "Avenir-Heavy", fontSize: 18, color: Colors.black),),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(width: width,),

            // "TIME & PLACE" container
            SectionContainer(
              title: "TIME & PLACE",
              padding: const EdgeInsets.fromLTRB(7.5, 20, 7.5, 10),
              color: primaryOpacity10,
              children: [

                // Year, month, day fields
                DateFields(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, widths[0] == 0? 0: 10),
                  borderColor: primaryColor, 
                  cursorColor: primaryColor, 
                  fillColor: Colors.white, 
                  yearFocus: _yearFocus,
                  monthFocus: _monthFocus,
                  dayFocus: _dayFocus,
                  dayController: _dayController,
                  monthController: _monthController,
                  yearController: _yearController,
                  yearChange: (text) {
                    if (text.length == 4) {_fieldFocusChange(context, _yearFocus, _monthFocus);}
                  }, 
                  monthChange: (text) {
                    if (text.length >= 2) {_fieldFocusChange(context, _monthFocus, _dayFocus);}
                  }, 
                  dayChange: (text) {
                    if (text.length >= 2) {
                      _dayFocus.unfocus();
                      checkDate();
                    }
                  },
                ),

                
                // Custom error message for date
                ErrorContainer(containerWidth: widths[0], containerHeight: heights[0], error: errors[0]),
                  

                // Hour and minute fields
                TimeFields(
                  padding: EdgeInsets.fromLTRB(0, 20, 0, widths[1] == 0? 20:10),
                  hourController: _hourController,
                  minuteController: _minuteController,
                  borderColor: primaryColor, 
                  cursorColor: primaryColor, 
                  fillColor: Colors.white, 
                  hourFocus: _hourFocus,
                  minuteFocus: _minuteFocus,
                  toggleStatus: toggleStatus,
                  hourChange: (text) {
                    if (text.length >= 2) {_fieldFocusChange(context, _hourFocus, _minuteFocus);}
                  }, 
                  minuteChange: (text) {
                    if (text.length >= 2) {
                      _minuteFocus.unfocus();
                      checkTime();
                    }
                  },
                  toggleStatusChange: (val){
                    setState(() {
                      toggleStatus = val;
                    });
                  },
                ),

                // Custom error message for time
                Padding(
                  padding: EdgeInsets.only(bottom: widths[1] == 0? 0:20),
                  child: ErrorContainer(containerWidth: widths[1], containerHeight: heights[1], error: errors[1]),
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
                    onChanged: (text) {appBloc.searchPlaces(text);},
                  ),
                ),

                // Custom error message for location
                Padding(
                  padding: EdgeInsets.only(bottom: widths[2] == 0? 0:20),
                  child: ErrorContainer(containerWidth: widths[2], containerHeight: heights[2], error: errors[2]),
                ),

                // Google map 
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
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
                ) 
              ],
            ),

            // "DETAILS" container
            SectionContainer(
              padding: const EdgeInsets.fromLTRB(7.5, 10, 7.5, 20),
              color: primaryOpacity10,
              title: "DETAILS",
              children: [

                // "Event name" text field
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: TextFormField(
                    maxLength: 30,
                    controller: _eventNameController,
                    autocorrect: false,
                    textCapitalization: TextCapitalization.words,
                    cursorColor: primaryColor,
                    decoration: textFieldDecorationSignUp.copyWith(
                        labelText: "Event name",
                        filled: true,
                        fillColor: Colors.white
                      ),
                    onChanged: (text) {},
                  ),
                ),

                // Custom error message for event name
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                  child: ErrorContainer(containerWidth: widths[3], containerHeight: heights[3], error: errors[3]),
                ),
            
                // Description text field
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: TextFormField(
                    controller: _descriptionController,
                    textInputAction: TextInputAction.done,
                    maxLength: 250,
                    maxLines: 10,
                    autocorrect: true,
                    textCapitalization: TextCapitalization.sentences,
                    cursorColor: primaryColor,
                    decoration: textFieldDecorationSignUp.copyWith(
                      labelText: "A brief description",
                      filled: true,
                      fillColor: Colors.white
                    ),
                    onChanged: (text) {},
                  ),
                ),

                // Public event option
                CircularButtonText(
                  padding: EdgeInsets.only(bottom: 10),
                  text: "Public; visible to everyone", 
                  icon: Icons.lock_open_outlined, 
                  color: button1Color, 
                  iconColor: button1IconColor,
                  onPressed: (){
                    setState(() {
                      typeToggle = !typeToggle;
                      button1Color = primaryColor;
                      button2Color = Colors.white;
                      button1IconColor = Colors.white;
                      button2IconColor = Colors.black;
                    });
                  },
                ),


                // Private event option
                CircularButtonText(
                  padding: EdgeInsets.only(bottom: 10),
                  text: "Private; only visible to invited guests", 
                  icon: Icons.lock_outline, 
                  color: button2Color, 
                  iconColor: button2IconColor,
                  onPressed: (){
                    setState(() {
                      typeToggle = !typeToggle;
                      button2Color = primaryColor;
                      button1Color = Colors.white;
                      button2IconColor = Colors.white;
                      button1IconColor = Colors.black;
                    });
                  },
                ),

                // Maximum capacity field (only available if event is public)
                typeToggle? SizedBox():
                Container(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 15.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom:15.0),
                          child: Text("Maximum Capacity", style: TextStyle(fontFamily: "Avenir-Medium"),),
                        ),
                        DateField(
                          fillColor: Colors.white, 
                          borderColor: primaryColor, 
                          cursorColor: primaryColor, 
                          datetext: "CAP", 
                          change: (text){},
                          autofocus: false,
                          textController: _capacityController,
                          focus: _capFocus,
                        )
                      ],
                    ),
                  ),
                ),

                // Custom error message for capacity
                typeToggle? SizedBox():
                Padding(
                  padding: const EdgeInsets.only(bottom: 15.0),
                  child: ErrorContainer(containerWidth: widths[4], containerHeight: heights[4], error: errors[4]),
                ),
              ],
            ),

            // "CREATE" button
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 40),
              child: RoundedButton(
                text: "CREATE",
                press: () async {

                  

                  // Necessary for animation
                  bool vEvent = checkEventNameField();
                  bool vTime = checkTime();
                  bool vDate = checkDate();
                  bool vLoc = checkLoc(appBloc);
                  bool vCap = typeToggle? true: checkCapacity();

                  // Check if all fields are valid
                  if(vEvent && vTime && vDate && vLoc && vCap){
                    String date = _yearController.text + _monthController.text + _dayController.text;
                    String time = _hourController.text + ":" + _minuteController.text;
                    toggleStatus? time += " A.M." : time += " P.M.";

                    // Communicate with database
                    bool success = await db.addEvent(
                      UniqueKey().toString().substring(1, 7), 
                      time, 
                      date, 
                      _eventNameController.text, 
                      _descriptionController.text,
                      appBloc.selectedLocation!.name,
                      appBloc.selectedLocation!.geometry.location.lat,
                      appBloc.selectedLocation!.geometry.location.lng,
                      appBloc.selectedLocation!.vicinity,
                      selectedPlaceId,
                      typeToggle? "private":"public",
                      typeToggle? -1:int.parse(_capacityController.text),
                    );

                    if(success){
                      _dayController.clear();
                      _monthController.clear();
                      _yearController.clear();
                      _hourController.clear();
                      _minuteController.clear();
                      _eventNameController.clear();
                      _descriptionController.clear();
                      _addressController.clear();
                      _capacityController.clear();
                      appBloc.selectedLocation = null;
                      selectedPlaceId = "";
                      setState(() {
                        createButtonColor = primaryColor;
                        removeContainer(4);
                      });
                    }
                    
                    showDialog(
                      context: context,
                       builder: (BuildContext dialogContext) => AlertDialog(
                        title: Text(
                          success? "Successfully created event!":"Could not create event :(",
                          style: TextStyle(color: Colors.white, fontFamily: "Avenir-Medium"),
                        ),
                        content: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              success?"Check it out on the map ":"Please try again",
                              style: TextStyle(color: Colors.white, fontFamily: "Avenir-Medium"),
                            ),
                            success?Icon(Icons.location_on_outlined, color: Colors.white,):SizedBox()
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: (){Navigator.pop(dialogContext);}, 
                            child: Text("OK", style: TextStyle(color: Colors.white),)
                          )
                        ],
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25)
                        ),
                      )
                    );
                  } else {
                    setState(() {
                      createButtonColor = Colors.red;
                    });
                  }
                  _capFocus.unfocus();
                }, 
                textstyle: buttonFontStyle.copyWith(color: Colors.white), 
                buttoncolor: createButtonColor
              ),
            ),
          ],
        ),
      ),
    );
  }
}