import 'dart:io';

import 'package:flutter/material.dart';
import 'package:logistics/helpers/bottom_navigation.dart';
import 'package:logistics/helpers/custom_routes.dart';
import 'package:logistics/pages/different/different_page.dart';
import 'package:logistics/models/user_model.dart';
import 'package:logistics/pages/blog_details.dart';
import 'package:logistics/pages/ppp.dart';
import 'package:logistics/scoped_models/main_model.dart';
import 'package:scoped_model/scoped_model.dart';

import 'profile.dart';
import 'on_stock.dart';
//import 'ppp.dart';
import 'send_page.dart';


class MainPage extends StatefulWidget {

  final MainModel model;
  final ValueChanged<int> onPush;

  MainPage(this.model, {this.onPush});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {

  int _currentTab = 0;
  final int _pageCount = 5;

//  TabItem _currentTab = TabItem.profile;
//
//  Map<TabItem, GlobalKey<NavigatorState>> _navigatorKeys = {
//    TabItem.profile: GlobalKey<NavigatorState>(),
//    TabItem.onStock: GlobalKey<NavigatorState>(),
//    TabItem.sendPage: GlobalKey<NavigatorState>(),
//    TabItem.ppp: GlobalKey<NavigatorState>(),
//  };

  void _onTabTapped(int tab){
    setState(() {
      _currentTab = tab;
    });
  }

  @override
  void initState() {

    print('main initState');
    widget.model.getUserProfile().then((UserModel model) async {
//      _bloc.addUser(model);
//      await DBProvider.db.addUser(model);
    }).catchError((error){
      print('error is $error');
    });


    super.initState();


  }

  @override
  Widget build(BuildContext context) {

    print('main build');

    if(widget.model.isUserChanged){
      widget.model.getUserProfile().then((model){

      }).catchError((error){
        print('error is $error');
      });
    }

    return Scaffold(
//                different: DrawerSettings(),
      body: _body(),
//                ),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentTab,
        items: [
          BottomNavigationBarItem(

            icon: Icon(Icons.person, color: _currentTab == 0 ? Theme.of(context).primaryColor : Colors.black45,),
            title: Text('Профиль', style: TextStyle(color: _currentTab == 0 ? Theme.of(context).primaryColor : Colors.black45,),)
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_box_outline_blank, color: _currentTab == 1 ? Theme.of(context).primaryColor : Colors.black45,),
            title: Text('На складе', style: TextStyle(color: _currentTab == 1 ? Theme.of(context).primaryColor : Colors.black45,),)
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.drive_eta, color: _currentTab == 2 ? Theme.of(context).primaryColor : Colors.black45,),
            title: Text('Отправленные', style: TextStyle(color: _currentTab == 2 ? Theme.of(context).primaryColor : Colors.black45,),)
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart, color: _currentTab == 3 ? Theme.of(context).primaryColor : Colors.black45,),
            title: Text('ПпП', style: TextStyle(color: _currentTab == 3 ? Theme.of(context).primaryColor : Colors.black45,))
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list, color: _currentTab == 4 ? Theme.of(context).primaryColor : Colors.black45,),
            title: Text('Разное', style: TextStyle(color: _currentTab == 4 ? Theme.of(context).primaryColor : Colors.black45,))
          ),
        ],
        onTap: _onTabTapped,
      ),
    );
  }


  Widget _body(){

    return Stack(
      children: List<Widget>.generate(_pageCount, (int index){
        return IgnorePointer(
          ignoring: index != _currentTab,
          child: Opacity(
            opacity: _currentTab == index ? 1 : 0,
            child: Navigator(
              onGenerateRoute: (RouteSettings settings){
                print('settings ${settings.name}');
                if(settings.name == '/'){
                  return MaterialPageRoute(
                      builder: (_) => _page(index),
                      settings: settings
                  );
//                  return PageRouteBuilder(
//                    pageBuilder:(BuildContext context, Animation animation, Animation secondaryAnimation){
//                      return _page(index);
//                    }
//                  );
                }
                else if(settings.name == '/blog_details') {
                  return FadeRoute<bool>(
                    builder: (BuildContext context) {
                      return ScopedModelDescendant<MainModel>(
                        builder: (BuildContext context, Widget child, MainModel model){
                          return BlogDetailsPage(model);
                        },
                      );
                    }
                  );
//                  return PageRouteBuilder(
//                      pageBuilder: (BuildContext context, Animation animation,
//                          Animation secondaryAnimation) {
//                        return ScopedModelDescendant<MainModel>(
//                            builder: (BuildContext context, Widget child,
//                                MainModel model) {
//                              return BlogDetailsPage(model);
//                            }
//                        );
//                      }
//                  );
                }
              },
            ),
          ),
        );
      })
    );
  }

  Widget _page(int index){

    switch (index){
      case 0:
        return ScopedModelDescendant<MainModel>(
          builder: (BuildContext context, Widget child, MainModel model){
            return /*(model.isLoading) ? Center(
            child: CircularProgressIndicator(),
          ) : */ProfilePage(model);
          },
        );
      case 1:
        return OnStockPage();
      case 2:
        return SendPage();
      case 3:
        return PppPage();
      case 4:
        return DifferentPage();
    }
    throw "Invalid index $index";
  }

//  void _push(BuildContext context){
//
//    Navigator.push(context, MaterialPageRoute(builder: (context){
//      _routeBuilders(context)[TabNavigatorRoutes.detail](context);
//    }));
//  }

//  Widget _buildOffstageNavigator(TabItem tabItem){
//
//    return Offstage(
//      offstage: _currentTab != tabItem,
//      child: TabNavigator(
//        navigatorKey: _navigatorKeys[tabItem],
//        tabItem: tabItem,
//      )
//    );
//  }

  @override
  void deactivate() {
    print('main deactivate');

    super.deactivate();
  }


  @override
  void dispose() {
    widget.model.removeBlogList();
    print('main dispose');
    super.dispose();
  }
}
