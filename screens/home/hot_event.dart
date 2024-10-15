import 'package:bouncr/components/CircleProgress.dart';
import 'package:bouncr/components/HotCircle.dart';
//import 'package:bouncr/models/user.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
//import 'package:provider/provider.dart';

class HotEvent extends StatefulWidget {

  final double width;
  final String eventName;
  final String pictureUrl;
  final String address;
  final String description;
  final int attendance;
  final int capacity;

  const HotEvent({ 
    Key? key,
    required this.width,
    required this.eventName,
    required this.pictureUrl,
    required this.address,
    required this.description,
    required this.capacity,
    required this.attendance
  }) : super(key: key);

  @override
  _HotEventState createState() => _HotEventState();
}

class _HotEventState extends State<HotEvent> with TickerProviderStateMixin {

  // Animation controllers
  late AnimationController _wave1Controller;
  late AnimationController _wave2Controller;
  late AnimationController _progressController;
  

  // Animations
  late Animation _wave1Animation;
  late Animation _wave2Animation;
  late Animation _progressAnimation;

  late final picture;

  @override
  void initState() {

    // Initializing controllers
    _wave1Controller = AnimationController(vsync: this, duration: Duration(milliseconds: 3000));
    _wave2Controller = AnimationController(vsync: this, duration: Duration(milliseconds: 3000));
    _progressController = AnimationController(vsync: this, duration: Duration(milliseconds: 2000));

    double ratio = widget.attendance/widget.capacity;

    // Initializing animations
    _wave1Animation = Tween<double>(begin: widget.width*0.4, end: widget.width*0.45 + 25).animate(_wave1Controller)..addListener(() {setState(() {});})
    ..addStatusListener((AnimationStatus status) {
      Future.delayed(Duration(milliseconds: 1500),(){
        if(mounted){
          _wave2Controller.repeat();
        }
      });
    });
    _wave2Animation = Tween<double>(begin: widget.width*0.4, end: widget.width*0.45 + 25).animate(_wave2Controller)..addListener(() {setState(() {});});
    _progressAnimation = Tween<double>(begin: 0, end: ratio*100).animate(_progressController)..addListener(() {
      setState(() {});
    });

    if(widget.pictureUrl == ""){
      picture = AssetImage("assets/partyimage.jpeg");
    } else{
      picture = CachedNetworkImageProvider(widget.pictureUrl);
    }

    _wave1Controller.repeat();
    _progressController.forward();
    super.initState();
  }

  @override
  void dispose() {
    _wave1Controller.dispose();
    _wave2Controller.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //final user = Provider.of<UserModel?>(context);


    return Scaffold(
      body: Stack(
        children: [

          // Waves
          Align(
            alignment: Alignment(1.2,-1.2),
            child: HotCircle(
              borderColor: Colors.deepOrange[400] ?? Colors.deepOrange,
              color: Colors.transparent,
              radius: _wave1Animation.value, 
              width: 3,
            ),
          ),
          

          Align(
            alignment: Alignment(1.2,-1.2),
            child: HotCircle(
              borderColor: Colors.deepOrange[400] ?? Colors.deepOrange,
              color: Colors.transparent,
              radius: _wave2Animation.value, 
              width: 3,
            ),
          ),


          Align(
            alignment: Alignment(-1.2,1.2),
            child: HotCircle(
              borderColor: Colors.deepOrange[400] ?? Colors.deepOrange,
              color: Colors.transparent,
              radius: _wave1Animation.value, 
              width: 3,
            ),
          ),

          Align(
            alignment: Alignment(-1.2,1.2),
            child: HotCircle(
              borderColor: Colors.deepOrange[400] ?? Colors.deepOrange,
              color: Colors.transparent,
              radius: _wave2Animation.value, 
              width: 3,
            ),
          ),
          
          // Circles
          Align(
            alignment: Alignment(-1.2,1.2),
            child: HotCircle(
              borderColor: Colors.deepOrange[400] ?? Colors.deepOrange,
              color: Colors.transparent,
              radius: widget.width*0.45 + 25, 
              width: 3,
            ),
          ),

          Align(
            alignment: Alignment(1.2,-1.2),
            child: HotCircle(
              borderColor: Colors.deepOrange[400] ?? Colors.deepOrange,
              color: Colors.transparent,
              radius: widget.width*0.45 + 25, 
              width: 3,
            ),
          ),

          Align(
            alignment: Alignment(1.2, -1.2),
            child: HotCircle(
              radius: widget.width*0.45, 
              color: Colors.deepOrange[400] ?? Colors.deepOrange, 
              borderColor: Colors.white
            ),
          ),

          Align(
            alignment: Alignment(-1.2, 1.2),
            child: HotCircle(
              radius: widget.width*0.45, 
              color: Colors.deepOrange[400] ?? Colors.deepOrange, 
              borderColor: Colors.white
            ),
          ),
          
          /*
          Align(
            alignment: Alignment(0.0, 0.8),
            child: HotCircle(
              radius: widget.width*0.45, 
              color: Colors.deepOrange[400] ?? Colors.deepOrange, 
              borderColor: Colors.white,
            ),
          ),
          */
          

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                CircleAvatar(
                  radius: widget.width*0.2 + 3,
                  backgroundColor: Colors.deepOrange[400],
                  child: CircleAvatar(
                    radius: widget.width*0.2, 
                    backgroundImage: picture,
                  ),
                ),

                // Event name
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(widget.eventName, style: TextStyle(fontFamily: "Avenir-Heavy", fontSize: 22),),
                ),

                // "Happening now"
                Padding(
                  padding: const EdgeInsets.only(left: 35, right:35, top: 10),
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: "Avenir-Medium",
                        fontSize: 17,
                      ),
                      children:[
                        TextSpan(text: "Happening",),
                        TextSpan(text: " now", style: TextStyle(fontFamily: "Avenir-Black", color: Colors.deepOrange[400]))
                      ]
                    ),
                  ),
                ),

                // Event address
                Padding(
                  padding: const EdgeInsets.only(left: 35, right:35, top: 10, bottom: 10),
                  child: Text(widget.address, style: TextStyle(fontFamily: "Avenir-Medium", fontSize: 16), textAlign: TextAlign.center,),
                ),

                // Description text container
                Padding(
                  padding: const EdgeInsets.only(left:12.0, right:12.0, top: 10, bottom: 10),
                  child: Container(
                    height: widget.description.length <= 10? null : 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 1),
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      color: Theme.of(context).scaffoldBackgroundColor
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: widget.description.length == 0?
                      Center(child: Text("No description", style: TextStyle(fontFamily: "Avenir-Medium", fontSize:16,)),)
                      : SingleChildScrollView(child: Text(widget.description, style: TextStyle(fontFamily: "Avenir-Medium", fontSize:16,))),
                    )
                  )
                ),

                CustomPaint(
                  foregroundPainter: CircleProgress(_progressAnimation.value, Colors.deepOrange[400] ?? Colors.deepOrange),
                  child: Container(
                    width: widget.width*0.4,
                    height: widget.width*0.4,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            center: Alignment(0,0),
                            colors: [
                              Colors.red,
                              Color.fromRGBO(152, 70, 242, 1)
                            ],
                            radius: _progressAnimation.value/100
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SafeArea(
            child: Align(
              alignment: Alignment(-1, -1),
              child: Padding(
                padding: EdgeInsets.only(left: 10),
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(primary: Colors.deepOrange[400]),
                    onPressed: () {Navigator.pop(context, [false, ""]);},
                    child: Icon(Icons.arrow_back)),
              ),
            ),
          ),
        ],
      )
    );
  }
}