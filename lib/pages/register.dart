import 'package:flutter/material.dart';
import 'package:logistics/pages/main.dart';
import 'package:logistics/scoped_models/main_model.dart';
import 'package:logistics/widgets/or_text.dart';
import 'package:logistics/widgets/social_auth.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_svg/flutter_svg.dart';
//import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';

class RegisterPage extends StatefulWidget {

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<RegisterPage> with TickerProviderStateMixin{

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  final _firstNameTextController = TextEditingController();
  final _lastNameTextController = TextEditingController();
  final _emailTextController = TextEditingController();

  final RegExp _emailRegExp = RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?");
  final RegExp _noNumberRegExp = RegExp(r"^\D+$");


  Widget _buildRegisterText(){

    return Container(
      child: Text('Зарегистрируйтесь и начните использовать свой собственный адрес доставки в США и Германии прямо сейчас!'),
    );
  }


  Widget _buildEmailTextField(){

    return TextFormField(
      decoration: InputDecoration(
          hintText: 'example@mail.com',
          labelText: 'E-mail',
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: EdgeInsets.symmetric(horizontal: 25, vertical: 15),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(22)),
              borderSide: BorderSide(
                  color: Colors.grey,
                  width: 1
              )
          ),
          prefixIcon: Icon(Entypo.getIconData('mail'), size: 18,)
      ),
      keyboardType: TextInputType.text,
      controller: _emailTextController,
      validator: (String value){
        if (value.isEmpty){
          return 'Введите e-mail';
        }
        else if(!_emailRegExp.hasMatch(value)){
          return 'Введите правильный e-mail';
        }
      },
    );
  }


  Widget _buildNameTextField(){

    return TextFormField(
      decoration: InputDecoration(
          labelText: 'Имя',
//          hintText: 'Семен',
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: EdgeInsets.symmetric(horizontal: 25, vertical: 15),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(22)),
              borderSide: BorderSide(
                  color: Colors.grey,
                  width: 1
              )
          ),
          prefixIcon: Icon(Entypo.getIconData('user'), size: 18,)
      ),
      keyboardType: TextInputType.text,
      controller: _firstNameTextController,
      validator: (String value){
        if (value.trim().isEmpty){
          return 'Введите свое имя';
        }
        else if(!_noNumberRegExp.hasMatch(value)){
          return 'Имя не должно содержать цифры';
        }
      },
    );
  }



  Widget _buildSurnameTextField(){

    return TextFormField(
      decoration: InputDecoration(
          labelText: 'Фамилия',
//          hintText: 'Семенов',
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: EdgeInsets.symmetric(horizontal: 25, vertical: 15),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(22)),
              borderSide: BorderSide(
                  color: Colors.grey,
                  width: 1
              )
          ),
          prefixIcon: Icon(Entypo.getIconData('user'), size: 18,)
      ),
      keyboardType: TextInputType.emailAddress,
      controller: _lastNameTextController,
      validator: (String value){
        print(value);
        if (value.trim().isEmpty){
          return 'Введите свою фамилию';
        }
        else if(!_noNumberRegExp.hasMatch(value)){
          return 'Фамилия не должна содержать цифры';
        }
      },
    );
  }


//  Widget _buildRequiredText(){
//
//    return Container(
//      child: Text('*Указывайте свое реальное имя латинскими буквами'),
//    );
//  }



  Widget _buildRegisterButton(MainModel model, double width){

    return ButtonTheme(
      minWidth: width,
      child: RaisedButton(
          child: Text('Зарегистрироваться'),
          textColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20))
          ),
          onPressed: () => _onSubmit(model)
      ),
    );
  }


  void _onSubmit(MainModel model) async {

    if(!_formKey.currentState.validate()){
      return;
    }
    _formKey.currentState.save();

    Map<String, dynamic> response = await model.authRegistration(_emailTextController.text, _firstNameTextController.text, _lastNameTextController.text);

    if(response['status'] == 'success'){
////            Navigator.pushReplacementNamed(context, '/');
//      print('google login is $response');
      Navigator.of(context).popUntil(ModalRoute.withName('/'));
    }
    else if(response['status'] == 'warning'){
//      print('google login is $response');
////            Navigator.pushReplacementNamed(context, '/');
      Navigator.of(context).popUntil(ModalRoute.withName('/'));
      _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(response['message'])));
    }
    else if(response['status'] == 'error'){
      print('google login is $response');
      _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(response['message'])));
    }


  }


  Widget _buildLogin(){

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text('Есть аккаунт?', style: TextStyle(fontSize: 15),),
        Container(
          margin: EdgeInsets.only(left: 6),
          child: GestureDetector(
            child: Text(
              'Войти',
              style: TextStyle(
                  fontSize: 15,
                  color: Theme.of(context).primaryColor
              ),
            ),
            onTap: (){
              Navigator.pop(context);
            },
          ),
        )
      ],
    );
  }


  @override
  Widget build(BuildContext context) {

    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 550 ? 600 : deviceWidth * 0.95;
    final double padding = deviceWidth - targetWidth;

    return /*WillPopScope(
      onWillPop: (){},
      child: */Scaffold(
      key: _scaffoldKey,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(padding),
//                color: Colors.red,
              child: Form(
                key: _formKey,
                child: ScopedModelDescendant<MainModel>(
                  builder: (BuildContext context, Widget child, MainModel model){
                    return Column(
                      children: <Widget>[
                        _buildRegisterText(),
                        SizedBox(height: 25,),
                        _buildEmailTextField(),
                        SizedBox(height: 10,),
                        _buildNameTextField(),
                        SizedBox(height: 10,),
                        _buildSurnameTextField(),
                        SizedBox(height: 10,),
//                        _buildRequiredText(),
                        SizedBox(height: 25,),
                        _buildRegisterButton(model, targetWidth),
                        SizedBox(height: 15,),
                        _buildLogin(),
                        SizedBox(height: 25,),
                        OrTextWidget(),
                        SizedBox(height: 25,),
                        SocialAuth(model: model, width: targetWidth,)
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
//      ),
    );
  }

}
