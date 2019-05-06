import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class BlogDetailsCarousel extends StatefulWidget {

  final List<String> images;

  BlogDetailsCarousel(this.images);

  @override
  _BlogDetailsCarouselState createState() => _BlogDetailsCarouselState();
}

class _BlogDetailsCarouselState extends State<BlogDetailsCarousel> {

  int _current = 0;


  List<T> map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        CarouselSlider(
          items: map<Widget>(
            widget.images,
            (position, image){

              return Container(
                margin: EdgeInsets.all(5),
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  child: Image.network(image, fit: BoxFit.cover, width: 1000,),
                ),
              );
            }
          ).toList(),
          aspectRatio: 4/3,
          viewportFraction: 1.0,
          autoPlay: true,
          pauseAutoPlayOnTouch: Duration(seconds: 5),
          autoPlayInterval: Duration(seconds: 3),
          enlargeCenterPage: false,
          onPageChanged: (index){
            setState(() {
              _current = index;
            });
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: map<Widget>(
            widget.images,
            (position, url){
              return Container(
                width: 8,
                height: 8,
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _current == position
                    ? Color.fromRGBO(0, 0, 0, 0.9)
                    : Color.fromRGBO(0, 0, 0, 0.4)
                ),
              );
            }
          )
        )
      ],
    );
  }
}
