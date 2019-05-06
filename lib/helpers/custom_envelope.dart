import 'package:flutter/material.dart';


class EnvelopePainter extends CustomPainter{

  Paint _paintBlue;
  Paint _paintRed;
  Paint _paintGrey;

  EnvelopePainter(){
    _paintBlue = Paint()
        ..color = Colors.blue
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round;

    _paintRed = Paint()
        ..color = Colors.red
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 7;

    _paintGrey = Paint()
      ..color = Colors.grey
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 7;
  }

  @override
  void paint(Canvas canvas, Size size) {

    double xx = 0;
    double xy = 0;

    double yx = 0;
    double yy = 0;
    List<Paint> _paintList = [_paintBlue, _paintRed, _paintGrey];
    int _paintCounter = 0;
    int _count = 0;

    while(xx <= yy*yy){
      canvas.drawLine(Offset(xx, 0), Offset(size.width, yy = size.height - xx / 2), _paintList[_paintCounter]);
      _paintCounter++;
      if(_paintCounter >= 3){
        _paintCounter = 0;
      }
      xx += 12;
      print(_count);
      _count++;
    }

    while(xy <= yx*yx){
      canvas.drawLine(Offset(0, xy / 2), Offset(yx = size.width - xy, size.height), _paintList[_paintCounter]);
      _paintCounter++;
      if(_paintCounter >= 3){
        _paintCounter = 0;
      }
      xy += 12;
      print(_count);
      _count++;
    }



//    canvas.drawLine(Offset(0, 0), Offset(size.width, size.height), _paintBlue);
//    canvas.drawLine(Offset(12, 0), Offset(size.width, size.height - 12 / 2), _paintRed);
//    canvas.drawLine(Offset(24, 0), Offset(size.width, size.height - 24 / 2), _paintGrey);

  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {



    return true;
  }

}