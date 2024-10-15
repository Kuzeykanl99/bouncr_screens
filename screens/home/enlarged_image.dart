import 'package:flutter/material.dart';

class EnlargedImage extends StatefulWidget {

  final FadeInImage image;
  final int heroTag;
  const EnlargedImage({ Key? key, required this.image, required this.heroTag}) : super(key: key);

  @override
  _EnlargedImageState createState() => _EnlargedImageState();
}

class _EnlargedImageState extends State<EnlargedImage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Post Details", style: TextStyle(fontFamily: "Avenir-Heavy", fontSize: 18, color: Colors.black),),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [

          Hero(
            tag: widget.heroTag, 
            child: InteractiveViewer(
              child: widget.image
            ),
          ),

          /*
          widget.image == ""? 
          Image.asset("assets/partyimage.jpeg"):
          CachedNetworkImage(
            imageUrl: widget.image,
            placeholder: (context, url) => Container(
              width: double.infinity,
              height: 200,
              child: Center(
                child: CircularProgressIndicator(color: primaryColor,)
              )
            ),
            errorWidget: (context, url, error) => Icon(Icons.error),
          )
          */
        ],
      ),
    );
  }
}