import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_icons/entypo.dart';
import 'package:flutter_icons/font_awesome.dart';
import 'package:flutter_icons/material_icons.dart';
import 'package:logistics/pages/welcome.dart';
import 'package:logistics/scoped_models/main_model.dart';
import 'package:scoped_model/scoped_model.dart';

class DifferentPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Разное'),
        centerTitle: true,
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            leading: Icon(Entypo.getIconData('home')),
            title: Text('Склад'),
            onTap: (){
//              Navigator.pushNamed(context, '/stock');
              Navigator.of(context, rootNavigator: true).pushNamed('/stock');
            },
          ),
          ListTile(
            leading: Icon(Entypo.getIconData('map')),
            title: Text('Мои адреса'),
            onTap: (){
              Navigator.of(context, rootNavigator: true).pushNamed('/my_address');

            },
          ),
          ListTile(
            leading: Icon(Entypo.getIconData('v-card')),
            title: Text('Мой профиль'),
            onTap: (){
              Navigator.of(context, rootNavigator: true).pushNamed('/my_profile');

            },
          ),
          ListTile(
            leading: Icon(FontAwesome.getIconData('comments')),
            title: Text('Поддержка'),
            onTap: (){
              Navigator.of(context, rootNavigator: true).pushNamed('/support');

            },
          ),
          ListTile(
            leading: Icon(Entypo.getIconData('info')),
            title: Text('Информация'),
            onTap: (){
              Navigator.of(context, rootNavigator: true).pushNamed('/info');

            },
          ),
          ListTile(
            leading: Icon(Entypo.getIconData('calculator')),
            title: Text('Калькулятор'),
            onTap: (){
              Navigator.of(context, rootNavigator: true).pushNamed('/calc');

            },
          ),
          ListTile(
            leading: Icon(FontAwesome.getIconData('edit')),
            title: Text('Мои спецзапросы'),
            onTap: (){
              Navigator.of(context, rootNavigator: true).pushNamed('/my_specrequest');

            },
          ),
          ListTile(
            leading: Icon(Entypo.getIconData('users')),
            title: Text('Отзывы о нас'),
            onTap: (){
              Navigator.of(context, rootNavigator: true).pushNamed('/feedback');

            },
          ),
          ListTile(
            leading: Icon(Entypo.getIconData('shopping-cart')),
            title: Text('Онлайн магазины'),
            onTap: (){
              Navigator.of(context, rootNavigator: true).pushNamed('/online_shop');

            },
          ),
          ListTile(
            leading: Icon(Entypo.getIconData('list')),
            title: Text('Как с нами связаться'),
            onTap: (){
              Navigator.of(context, rootNavigator: true).pushNamed('/our_address');

            },
          ),
          ScopedModelDescendant<MainModel>(
              builder: (BuildContext context, Widget child, MainModel model){
                return ListTile(
                    leading: Icon(MaterialIcons.getIconData('exit-to-app')),
                    title: Text('Выйти из профиля'),
                    onTap: () {
                      model.logout().then((_){
                        Navigator.of(context, rootNavigator: true).popUntil(ModalRoute.withName('/'));
                      });
//                            Navigator.pushReplacementNamed(context, '/auth');

                    }
                );
              }
          ),
        ],
      ),
    );
  }
}
