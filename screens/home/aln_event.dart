import 'package:bouncr/models/theme.dart';
import 'package:bouncr/screens/home/enlarged_image.dart';
import 'package:bouncr/services/database.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class ALNEvent extends StatefulWidget {

  final String eventId;
  final String eventPicture;
  final String eventName;
  final String uid;

  const ALNEvent({
     Key? key,
     required this.eventId,
     required this.eventPicture,
     required this.eventName,
     required this.uid
    }) : super(key: key);

  @override
  _ALNEventState createState() => _ALNEventState();
}

class _ALNEventState extends State<ALNEvent> {

  late final _eventPicture;
  bool gridView = true;
  late Future<List<QueryDocumentSnapshot<Object?>>> getALNDocs;

  @override
  void initState() {
    if (widget.eventPicture == "") {
      _eventPicture = AssetImage("assets/partyimage.jpeg");
    } else {
      _eventPicture = CachedNetworkImageProvider(widget.eventPicture);
    }
    super.initState();
    DatabaseService db = DatabaseService(uid: widget.uid);
    getALNDocs = db.getALNDocuments(widget.eventId);
  }

  String convertToUserFriendlyTime(String timestamp){
    String time = timestamp.substring(11);
    int hour = int.parse(time.substring(0, 2));
    String M = "A.M.";
    if(hour > 12){
      hour -= 12;
      M = "P.M.";
    }
    return hour.toString() + time.substring(2, 5) + " " + M;
  }

  Widget makeImageGrid(List ALNDocs){

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 15, 8, 8),
      child: StaggeredGridView.countBuilder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 12,
        itemCount: ALNDocs.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EnlargedImage(
                    image: FadeInImage.assetNetwork(
                      placeholder: 'assets/loading.gif',
                      image: ALNDocs[index]["imageURL"],
                      fit: BoxFit.cover,
                    ),
                    heroTag: index,
                  )
                ),
              );
            },
            child: Hero(
              tag: index,
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.all(Radius.circular(15))
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                  child: FadeInImage.assetNetwork(
                    placeholder: 'assets/loading.gif',
                    image: ALNDocs[index]["imageURL"],
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          );
        },
        staggeredTileBuilder: (index) {
          //return StaggeredTile.count(1, index.isEven ? 1.2 : 1.8);
          return StaggeredTile.count((index%7 == 0)?2:1, (index%7 == 0)?2:1);
        }
      ),
    );
  }

  List<Widget> makeImageListView(List ALNDocs){

    List<Widget> widgets = [];
    for(int i = 0; i < ALNDocs.length; i++){

      widgets.add(
        Row(
          children: [

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                radius: 20, 
                backgroundImage: ALNDocs[i]["profilePic"] == ""?
                CachedNetworkImageProvider("https://i.ibb.co/rdY2fQT/single-bouncr.png"):
                CachedNetworkImageProvider(ALNDocs[i]["profilePic"]),
              ),
            ),


            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ALNDocs[i]["username"],
                  style: TextStyle(
                    fontFamily: "Avenir-Medium"
                  ),
                ),
                Text(
                  "at " + convertToUserFriendlyTime(ALNDocs[i]["uploadTime"]),
                  style: TextStyle(
                    fontFamily: "Avenir-Medium"
                  ),
                )
              ],
            ),
          ],
        )
      );

      widgets.add(
        InteractiveViewer(
          child: FadeInImage.assetNetwork(
            placeholder: 'assets/loading.gif',
            image: ALNDocs[i]["imageURL"],
            fit: BoxFit.cover,
          ),
        ),
      );

      widgets.add(
        Center(
          child: SizedBox(height: 10,)
        ),
      );
    }
    return widgets;
  }
  

  @override
  Widget build(BuildContext context) {

    double width = MediaQuery.of(context).size.width;    

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.white,
        title: Text(
          "About Last Night",
          style: TextStyle(fontFamily: "Avenir-Heavy", fontSize: 18, color: Colors.black),
        ),
      ),
      body: FutureBuilder<List<QueryDocumentSnapshot<Object?>>>(
        future: getALNDocs,
        builder:(BuildContext context, AsyncSnapshot<List<QueryDocumentSnapshot<Object?>>> snapshot) {

          if (snapshot.hasError) {
            return Text("Something went wrong");
          }

          if (snapshot.hasData && snapshot.data!.length == 0) {
            return Text("Document does not exist");
          }

          if (snapshot.connectionState == ConnectionState.done) {

            return ListView(
              children: [
                SizedBox(width: width,),
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: CircleAvatar(
                    radius: width*0.2 + 3,
                    backgroundColor: primaryColor,
                    child: CircleAvatar(
                      radius: width*0.2, 
                      backgroundImage: _eventPicture,
                    ),
                  ),
                ),
          
                // Event name
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(widget.eventName, style: TextStyle(fontFamily: "Avenir-Heavy", fontSize: 22),),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 4.0),
                        child: SizedBox(
                          width: (width-24)/2,
                          child: ElevatedButton(
                            onPressed: (){
                              setState(() {
                                gridView = true;
                              });
                            }, 
                            child: Icon(Icons.grid_3x3),
                            style: ElevatedButton.styleFrom(
                              primary: primaryColor
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: SizedBox(
                          width: (width-24)/2,
                          child: ElevatedButton(
                            onPressed: (){
                              setState(() {
                                gridView = false;
                              });
                            }, 
                            child: Icon(Icons.view_list),
                            style: ElevatedButton.styleFrom(
                              primary: primaryColor
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
          
                snapshot.data!.length == 0? 
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top:70.0),
                    child: Text("No pics were uploaded :(", style: TextStyle(fontFamily: "Avenir-Heavy", fontSize: 15, color: Colors.black),),
                  ),
                ):

                gridView? Container(
                  width: width,
                  child: makeImageGrid(snapshot.data!)
                ):SizedBox(),
              
              ] + (!gridView? makeImageListView(snapshot.data!): [])
            );
          }

          return Text("");
        },
      )
    );
  }
}