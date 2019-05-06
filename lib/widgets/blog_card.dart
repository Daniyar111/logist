import 'package:flutter/material.dart';
import 'package:flutter_icons/entypo.dart';
import 'package:flutter_icons/font_awesome.dart';
import 'package:logistics/models/blog.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:logistics/scoped_models/main_model.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:timeago/timeago.dart' as timeago;

class BlogCard extends StatelessWidget {

  final BlogList blogList;
  final double width;
//  Function(bool) callBack;

  BlogCard(this.blogList, this.width,/* this.callBack*/);

  Widget _buildBlogImage(){

    return Container(
      width: double.infinity,
      child: (blogList.imageNormalUrl != null)
          ? FadeInImage(

              image: NetworkImage(blogList.imageNormalUrl),
              placeholder: AssetImage('assets/place_holder.png'),
          //            height: 300,
              fit: BoxFit.cover,
            )
                : Image.asset(
              'assets/place_holder.png',
          //            height: 300,
              fit: BoxFit.cover,
            ),
    );

  }

  @override
  Widget build(BuildContext context) {

    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model){
        return GestureDetector(
          excludeFromSemantics: true,
          onTap: (){
//            callBack(false);
            print('id ${blogList.id}');
            model.selectBlogId(blogList.id);
            Navigator.of(context, rootNavigator: true).pushNamed('/blog_details');
//            Navigator.pushNamed(context, '/blog_details');
          },
          child: Card(
            margin: EdgeInsets.symmetric(horizontal: width - 10, vertical: 7),
            child: Stack(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    _buildBlogImage(),
                    SizedBox(height: 10,),
                    Text(blogList.title, textAlign: TextAlign.center, style: TextStyle(fontSize: 21),),
                    Container(
                      margin: EdgeInsets.all(13),
                      child: Html(
                        useRichText: true,
                        defaultTextStyle: TextStyle(fontSize: 17, color: Colors.black),
                        data: blogList.context,
                        onLinkTap: (url){
                          print("Opening $url...");
                          _launchURL(url);
                        },
//                        useRichText: true,

                      ),
                    ),
                    SizedBox(height: 10,),
                    Container(
                      margin: EdgeInsets.all(7),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Text(_parseDate(blogList.date), style: TextStyle(fontSize: 15),),
                          blogList.numberOfComments == 0 ? Container() : SizedBox(width: 15,),
                          blogList.numberOfComments == 0 ? Container() : Text(blogList.numberOfComments.toString()),
                          blogList.numberOfComments == 0 ? Container() : SizedBox(width: 3,),
                          blogList.numberOfComments == 0 ? Container() : Icon(FontAwesome.getIconData('comments-o'))
                        ],
                      ),
                    )
                  ],
                ),
                (blogList.isPinned)
                  ? Container(
                      alignment: Alignment.topRight,

                      margin: EdgeInsets.all(10),
                      child: Container(
                        padding: EdgeInsets.all(7  ),
                        child: Icon(Entypo.getIconData('pin'), size: 20,),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle
                        ),
                      ),
                    ) : Container()
              ],
            ),
          ),
        );
      },
    );
  }



  String _parseDate(String date){

    timeago.setLocaleMessages('ru', timeago.RuMessages());
    DateTime parsedDate = DateTime.parse(date);

    return timeago.format(parsedDate, locale: 'ru');
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
