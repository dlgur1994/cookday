import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cookday/pages/recommend/detailed_info.dart';

class PopularSliding extends StatefulWidget {
  final userUid;
  PopularSliding({Key key, this.userUid}) : super(key: key);
  @override
  _PopularSlidingState createState() => _PopularSlidingState();
}

class _PopularSlidingState extends State<PopularSliding> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Firestore.instance
            .collection('recipe')
            .orderBy('recommend', descending: true)
            .getDocuments(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());
          else {
            final List<DocumentSnapshot> allList = snapshot.data.documents;
            List<DocumentSnapshot> popularList = new List<DocumentSnapshot>();
            int num = 0;
            for (final d in allList) {
              if (num < 5) {
                popularList.add(d); //첫 5개만 save
                num++;
              } else
                break;
            }
            return slider(popularList);
          }
        });
  }

  Widget slider(List<DocumentSnapshot> lis) {
    return CarouselSlider(
      height: MediaQuery.of(context).size.height * 0.35,
      aspectRatio: 16 / 9,
      viewportFraction: 0.9,
      autoPlay: true,
      items: [
        indivItems(lis[0]['uid'], lis[0]['imageURL'], lis[0]['recipeName'],
            lis[0]['recommend'], lis[0]['cookTime']),
        indivItems(lis[1]['uid'], lis[1]['imageURL'], lis[1]['recipeName'],
            lis[1]['recommend'], lis[1]['cookTime']),
        indivItems(lis[2]['uid'], lis[2]['imageURL'], lis[2]['recipeName'],
            lis[2]['recommend'], lis[2]['cookTime']),
        indivItems(lis[3]['uid'], lis[3]['imageURL'], lis[3]['recipeName'],
            lis[3]['recommend'], lis[3]['cookTime']),
      ],
    );
  }

  Widget indivItems(var uid, var url, var title, var recommend, var cookTime) {
    return InkWell(
      onTap: () {
        // Navigator.push(context, MaterialPageRoute(builder: (context)=>DetailedInfo(uid:uid)) );
        Navigator.of(context).push(new PageRouteBuilder(
            pageBuilder: (BuildContext context, Animation<double> animation,
                    Animation<double> secondaryAnimation) =>
                new DetailedInfo(
                    uid: uid, userUid: widget.userUid), //음식 uid와 user uid
            transitionsBuilder: (
              BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
              Widget child,
            ) {
              return new SlideTransition(
                position: new Tween<Offset>(
                  begin: const Offset(0.0, 1.0),
                  end: Offset.zero,
                ).animate(animation),
                child: new SlideTransition(
                  position: new Tween<Offset>(
                    begin: Offset.zero,
                    end: const Offset(0.0, 1.0),
                  ).animate(secondaryAnimation),
                  child: child,
                ),
              );
            },
            transitionDuration: const Duration(milliseconds: 100)));
      },
      child: Container(
          child: ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Stack(
                children: <Widget>[
                  Image.network(
                    url,
                    fit: BoxFit.fill,
                    width: MediaQuery.of(context).size.width * 0.85,
                    height: MediaQuery.of(context).size.height * 0.4,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.85,
                    height: MediaQuery.of(context).size.height * 0.4,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: FractionalOffset.center,
                          end: FractionalOffset.bottomCenter,
                          stops: [0.0, 0.85],
                          colors: [
                            Colors.white.withOpacity(0.0),
                            Colors.black.withOpacity(0.6)
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.75,
                    padding: EdgeInsets.fromLTRB(20.0,
                        MediaQuery.of(context).size.height * 0.25, 20.0, 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.only(top: 15.0),
                            child: Text(title,
                                style: TextStyle(
                                    fontSize: 20.0,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                        Expanded(
                          child: Container(
                              child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Icon(
                                Icons.timelapse,
                                color: Colors.white,
                                size: 20.0,
                              ),
                              SizedBox(
                                width: 5.0,
                              ),
                              Text("$cookTime 분",
                                  style: TextStyle(
                                      fontSize: 15.0, color: Colors.white)),
                              SizedBox(
                                width: 50.0,
                              ),
                              Icon(
                                Icons.thumb_up,
                                color: Colors.white,
                                size: 20.0,
                              ),
                              SizedBox(
                                width: 5.0,
                              ),
                              Text("${recommend.toString()}",
                                  style: TextStyle(
                                      fontSize: 15.0, color: Colors.white)),
                            ],
                          )),
                        )
                      ],
                    ),
                  )
                ],
              ))),
    );
  }
}
