import 'package:flutter/material.dart';
import 'package:logistics/pages/auth.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_svg/flutter_svg.dart';
//import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';

class WelcomePage extends StatelessWidget {

  Widget _buildLogo(BuildContext context){

    return Column(
      children: <Widget>[
        SvgPicture.asset('assets/logo.svg', width: 130, height: 130,),
        Container(
          margin: EdgeInsets.only(bottom: 45),
          child: Text(
            'T-Express',
            style: TextStyle(
                fontSize: 35,
                fontFamily: 'Lobster',
                color: Theme.of(context).primaryColor
            ),
          ),
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {

    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 550 ? 500 : deviceWidth * 0.8;
    final double padding = deviceWidth - targetWidth;

    return /*WillPopScope(
      onWillPop: (){},
      child:*/ Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _buildLogo(context),
              Container(
                padding: EdgeInsets.symmetric(horizontal: padding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: 20,),
                    ListTile(
                      leading: Icon(Entypo.getIconData('open-book'), color: Colors.black87,),
                      title: Text('Информация', style: TextStyle(color: Colors.black87),),
                      onTap: (){
                        Navigator.of(context).pushNamed('/info');
//                        Navigator.pushNamed<bool>(context, '/info');
                      },
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Entypo.getIconData('calculator'), color: Colors.black87,),
                      title: Text('Калькулятор', style: TextStyle(color: Colors.black87),),
                      onTap: (){
                        Navigator.of(context).pushNamed('/calc');
                      },
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Entypo.getIconData('login'), color: Colors.black87,),
                      title: Text('Вход', style: TextStyle(color: Colors.black87),),
                      onTap: (){
                        Navigator.of(context).pushNamed('/auth');
                      },
                    ),

                  ],
                ),
              )
            ],
          ),
        ),
//        ),

      ),
    );
  }
}

