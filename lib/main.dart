import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:logistics/pages/blog_details.dart';
import 'package:logistics/pages/different/support/appeal_support.dart';
import 'package:logistics/pages/different/support/support_chat.dart';
import 'package:logistics/pages/main.dart';
import 'package:logistics/pages/register.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:logistics/scoped_models/main_model.dart';

import 'helpers/adaptive_theme.dart';
import 'helpers/custom_routes.dart';
import 'pages/welcome.dart';
import 'pages/auth.dart';
import 'pages/calculator.dart';
import 'pages/info.dart';
import 'package:logistics/pages/different/feedback/feedback.dart';
import 'pages/different/my_address.dart';
import 'pages/different/my_profile.dart';
import 'pages/different/my_specrequest.dart';
import 'pages/different/online_shop.dart';
import 'pages/different/our_address.dart';
import 'pages/different/stock.dart';
import 'package:logistics/pages/different/support/support.dart';


  void main() {
  //  debugPaintSizeEnabled = true;
    runApp(MainApplication());
  }


  class MainApplication extends StatefulWidget {

    @override
    _MainApplicationState createState() => _MainApplicationState();
  }

  class _MainApplicationState extends State<MainApplication> {

    final MainModel _model = MainModel();
    bool _isAuthenticated = false;

    @override
    void initState() {

      _model.autoAuthenticate();
      _model.userSubject.listen((bool isAuthenticated){
        setState(() {
          _isAuthenticated = isAuthenticated;
          print('is auth $_isAuthenticated');
        });
      });
//      _channel = IOWebSocketChannel.connect(_mo)

      super.initState();
    }

    @override
    Widget build(BuildContext context) {
      print('is auth build');

//      return _isAuthenticated
//          ? StreamBuilder(
//              stream: IOWebSocketChannel.connect(_model.webSocketUrl).stream,
//              builder: (context, snapshot){
//                return _buildApp(snapshot: snapshot);
//              },
//            )
//          : _buildApp();




      return _buildApp();
    }

    Widget _buildApp(){
      return ScopedModel<MainModel>(
        model: _model,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: getAdaptiveThemeData(context),
          routes: {
            '/': (BuildContext context) => !_isAuthenticated ? WelcomePage() : MainPage(_model),
//            '/auth': (BuildContext context) => AuthPage(),
//            '/info': (BuildContext context) => InfoPage(),
            //          '/auth': (BuildContext context) => !_isAuthenticated ? AuthPage(_model) : MainPage(_model),
//            '/calc': (BuildContext context) => CalculatorPage(),
            //          '/register': (BuildContext context) => !_isAuthenticated ? RegisterPage() : MainPage(_model),
            //          '/main': (BuildContext context) => !_isAuthenticated ? WelcomePage() : MainPage(),
            '/feedback': (BuildContext context) => FeedbackPage(/*channel: IOWebSocketChannel.connect('')*/),
            '/my_address': (BuildContext context) => MyAddressPage(),
            '/my_profile': (BuildContext context) => MyProfilePage(),
            '/my_specrequest': (BuildContext context) => MySpecRequestPage(),
            '/online_shop': (BuildContext context) => OnlineShopPage(),
            '/our_address': (BuildContext context) => OurAddressPage(),
            '/stock': (BuildContext context) => StockPage(),
            '/support': (BuildContext context) => SupportPage(_model),
            '/blog_details': (BuildContext context) => BlogDetailsPage(_model),
            '/appeal_support': (BuildContext context) => AppealSupportPage(),
            '/support_chat': (BuildContext context) => SupportChatPage(model: _model),
          },
          onGenerateRoute: (RouteSettings settings){
            print('route ${settings.name}');
//            if(!_isAuthenticated){
//              return CustomRoute<bool>(
//                  builder: (BuildContext context) => WelcomePage()
//              );
//            }


            if(settings.name == '/auth'){
              return FadeRoute<bool>(
                  builder: (BuildContext context) => AuthPage()
              );
            }
            else if(settings.name == '/info'){
              return FadeRoute<bool>(
                  builder: (BuildContext context) => InfoPage()
              );
            }
            else if(settings.name == '/calc'){
              return FadeRoute<bool>(
                  builder: (BuildContext context) => CalculatorPage(_model)
              );
            }
            else if(settings.name == '/register'){
              return SlideRightRoute(
                  widget: RegisterPage()
              );
            }



//            if(settings.name == '/blog_details'){
//              return CustomRoute<bool>(
//                builder: (BuildContext context) => BlogDetailsPage(_model)
//              );
//            }
          },
          onUnknownRoute: (RouteSettings settings){
//            return CustomRoute(
//                builder: (BuildContext context) => !_isAuthenticated ? WelcomePage() : MainPage(_model)
//            );
          },
        ),
      );
    }
  }
