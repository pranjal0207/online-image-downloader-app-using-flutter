import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:share/share.dart';
import 'FireStoreHelper.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final fs = OFirestoreService();
  int cur = 0;
  QuerySnapshot imgl;
  List imgf = [];
  List textf = [];

  @override
  void initState() {
    super.initState();
      fs.getData().then((result){
        setState(() {
          imgl = result; 
          print (imgl.docs[0].data()['link']);

          for (int i =0; i < imgl.docs.length; i++){
            //imgf.add(Image.network(imgl.docs[i].data()['link'], fit: BoxFit.fill));
            imgf.add(imgl.docs[i].data()['link']);
            textf.add(imgl.docs[i].data()['text']);
          }

          controller1.text = textf[0];
        });
      }); 
  }

  TextEditingController controller1 = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    
      body: SafeArea(
        child : Container(
        //height: 500,
        width: MediaQuery.of(context).size.width + 100,
        margin: EdgeInsets.only(top : 40),

        child: Column(
          children: <Widget>[
            CarouselSlider(
              items: imgf.map((imgURL){
                return Builder(
                  builder: (BuildContext context){
                    return Container(
                      //margin: EdgeInsets.only(top : 50),
                      width: MediaQuery.of(context).size.width,
                      //margin: EdgeInsets.symmetric(horizontal : 2.0),
                      decoration: BoxDecoration(
                        color: Colors.white
                      ),
                      child: CachedNetworkImage(
                        imageUrl: imgURL,
                        placeholder: (context, url) => CircularProgressIndicator(),
                      ),
                    );
                  },
                );
              }).toList(),
              enlargeCenterPage: true, 
              initialPage: 0,
              onPageChanged: (index){
                setState(() {
                  cur = index;
                  controller1.text = textf[cur];
                });
              }, 
            ),

            Container(
              margin: EdgeInsets.only(top : MediaQuery.of(context).size.width - 300),
              
              child : Center( 
                child : ExpandableText(
                controller1.text, 
                expandText: 'Show more',
                collapseText: 'Show less',
                style: TextStyle(
                  fontSize: 20
                ),
              ),)
            ),

            Container(
              margin: EdgeInsets.only(top: 200),
              child: Row(
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width  / 2 ,
                  child : FlatButton(
                  onPressed: ()async{
                    final status = await Permission.storage.request();

                    if (status.isGranted){
                      final dir = await getExternalStorageDirectory();

                      final id =  await FlutterDownloader.enqueue(
                        url: imgf[cur], 
                        savedDir: dir.path,
                        //fileName: "download",
                        openFileFromNotification: true,
                        showNotification: true,
                      );

                      print (id);
                    }
                  }, 
                  child: Icon(Icons.download_rounded)
                )
              ),

              Container(
               width:  MediaQuery.of(context).size.width  / 2,
                child : FlatButton(
                  onPressed: (){
                    Share.share("Check this cool image at : \n$imgf[cur]");
                  }, 
                  child: Icon(Icons.share)
                )
              )    
            ],
            ) ,
          ),       
          ],
        ) 
      ))
    );
  }
}