import 'package:bouncr/models/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:introduction_screen/introduction_screen.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({ Key? key }) : super(key: key);

  @override
  _IntroPageState createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  @override
  Widget build(BuildContext context) {

    const bodyStyle = TextStyle(fontSize: 19.0);
    const pageDecoration = const PageDecoration(
      titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
      bodyTextStyle: bodyStyle,
      descriptionPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: Colors.white,
      imagePadding: EdgeInsets.zero,
    );

    return IntroductionScreen(
      pages: [

        PageViewModel(
          title: "Welcome to bouncr!",
          body: "See all of the events happening around you on the map, explore your city and meet new people!",
          decoration: pageDecoration,
          image: Center(
            child: Padding(
              padding: const EdgeInsets.only(top:80.0),
              child: Image.asset("assets/intro/pin.png"),
            ),
          )
        ),


        PageViewModel(
          title: "Create Events",
          body: 
          "Public events can be seen by everyone on the map. \n\n Private events are just for you and people you share the #EID with.",
          decoration: pageDecoration,
          image: Center(
            child: Padding(
              padding: const EdgeInsets.only(top:80.0),
              child: Image.asset("assets/intro/add.png"),
            ),
          )
        ),
        PageViewModel(
          title: "Hot Events",
          body: "Discover the top 5 hottest events in your city!",
          decoration: pageDecoration,
          image: Center(
            child: Padding(
              padding: const EdgeInsets.only(top:80.0),
              child: Image.asset("assets/intro/hot.png"),
            ),
          )
        ),
        PageViewModel(
          title: "My Events",
          body: "Save public events and join private events, given you have the right #EID!",
          decoration: pageDecoration,
          image: Center(
            child: Padding(
              padding: const EdgeInsets.only(top:80.0),
              child: Image.asset("assets/intro/events.png"),
            ),
          )
        ),
        PageViewModel(
          title: "About Last Night",
          body: "While at an event, take and upload pictures! \n\n12 hours later, you can see all of the pictures uploaded to a specific event!",
          decoration: pageDecoration,
          image: Center(
            child: Padding(
              padding: const EdgeInsets.only(top:80.0),
              child: Image.asset("assets/intro/photo.png"),
            ),
          )
        ),
      ],
      next: const Icon(Icons.arrow_forward),
      done: const Text('Done', style: TextStyle(fontWeight: FontWeight.w600)),
      onDone: (){Navigator.popUntil(context, ModalRoute.withName('/'));},
      color: primaryColor,
      dotsDecorator: const DotsDecorator(
        size: Size(5.0, 5.0),
        color: Color(0xFFBDBDBD),
        activeColor: Color.fromRGBO(134, 143, 247, 1),
        activeSize: Size(22.0, 10.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
      dotsContainerDecorator: const ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
      ),

    );
  }
}