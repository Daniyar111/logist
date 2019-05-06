import 'package:flutter/material.dart';
import 'package:logistics/pages/main.dart';
import 'package:logistics/pages/register.dart';
import 'package:logistics/scoped_models/main_model.dart';
import 'package:logistics/widgets/check_dialog.dart';
import 'package:logistics/widgets/or_text.dart';
import 'package:logistics/widgets/social_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:scoped_model/scoped_model.dart';

class AuthPage extends StatefulWidget {

//  final MainModel model;


  @override
  _AuthState createState() => _AuthState();
}

class _AuthState extends State<AuthPage> with TickerProviderStateMixin{

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _emailKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  RegExp _emailRegExp = RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?");

  bool _isObscure = true;


  final _emailForgotTextController = TextEditingController();

  final _emailFieldTextController = TextEditingController();
  final _passwordFieldTextController = TextEditingController();


  Widget _buildLogo(){

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


  Widget _buildEmailTextField(){

    return TextFormField(
      decoration: InputDecoration(
//          hintText: 'example@mail.com',
          labelText: 'E-mail или никнейм',
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
      controller: _emailFieldTextController,
      keyboardType: TextInputType.emailAddress,
      validator: (String value){
        if (value.isEmpty){
          return 'Введите e-mail';
        }
      },
    );
  }

  Widget _buildPasswordTextField(){

    return TextFormField(
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
          labelText: "Пароль",
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
          prefixIcon: Icon(Entypo.getIconData('key'), size: 18,),
          suffixIcon: GestureDetector(
            onTap: (){
              setState(() {
                _isObscure = !_isObscure;
              });
            },
            child: Icon(
                _isObscure
                    ? Entypo.getIconData('eye')
                    : Entypo.getIconData('eye-with-line')
            ),
          )
      ),
      controller: _passwordFieldTextController,
      obscureText: _isObscure,
      validator: (String value){

        if(value.isEmpty){
          return "Введите пароль";
        }
      },

    );
  }


  Widget _buildLoginButton(double width){

    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model){
        return model.isLoading
            ? CircularProgressIndicator()
            : ButtonTheme(
            minWidth: width,
            child: RaisedButton(
                child: Text('Вход'),
                textColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20))
                ),
                onPressed: () => _onSubmit(model)
            )
        );
      },
    );
  }


  void _onSubmit(MainModel model) async{

    if(!_formKey.currentState.validate()){
      return;
    }
    _formKey.currentState.save();

    await model.authLogin(_emailFieldTextController.text, _passwordFieldTextController.text)
        .then((response){
          if(response['status'] == 'success'){
//            Navigator.pushReplacementNamed(context, '/');
            Navigator.of(context).popUntil(ModalRoute.withName('/'));
//            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainPage(model)));
            print('google login is $response');
          }
          else if(response['status'] == 'warning'){
            print('google login is $response');
//            Navigator.pushReplacementNamed(context, '/');
            Navigator.of(context).popUntil(ModalRoute.withName('/'));
//            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainPage(model)));
            _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(response['message'])));
          }
          else if(response['status'] == 'error'){
            print('google login is $response');
            _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(response['message'])));
          }
    }).catchError((error){
      print(error);
    });

  }


  Widget _buildRegister(){

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          child: GestureDetector(
            child: Text(
              'Восстановить пароль',
              style: TextStyle(
                  fontSize: 15,
                  color: Theme.of(context).primaryColor
              ),
            ),
            onTap: _showForgotPasswordDialog,
          ),
        ),
        Container(
          margin: EdgeInsets.only(left: 15),
          child: GestureDetector(
            child: Text(
              'Зарегистрироваться',
              style: TextStyle(
                  fontSize: 15,
                  color: Theme.of(context).primaryColor
              ),
            ),
            onTap: (){
//              Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterPage()));
              Navigator.of(context).pushNamed('/register');
            },
          ),
        )
      ],
    );
  }


  void _showForgotPasswordDialog(){

    showDialog(
        context: context,
        builder: (BuildContext context){

          return Form(
            key: _emailKey,
            child: SimpleDialog(
              title: Text('Восстановление пароля'),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
              children: <Widget>[

                Container(
                  margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  child: _buildEmailForgotForm()
                ),

                ScopedModelDescendant<MainModel>(
                  builder: (BuildContext context, Widget child, MainModel model){
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 15),
                      child: ButtonTheme(
                        child: RaisedButton(
                            child: Text('Отправить'),
                            textColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(10))
                            ),
                            onPressed: () async{
                              if(!_emailKey.currentState.validate()){
                                return;
                              }
                              _emailKey.currentState.save();

                              print('controller ${_emailForgotTextController.text}');

                              await model.forgotPassword(_emailForgotTextController.text).then((response){
                                print('response forgot   $response');
                                Navigator.of(context).pop();
                                if(response['status'] == 'success'){
                                  _showCheckDialog('success', response['message']);
                                }
                                else{
                                  _showCheckDialog('error', response['message']);
                                }
                              }).catchError((error){
                                print(error);
                              });
                            }
                        ),
                      ),
                    );
                  },
                )

              ],
            ),
          );
        }
    );

  }




  void _showCheckDialog(String response, String message){

    showDialog(
        context: context,
        builder: (BuildContext context){

          return CheckDialog(response: response, message: message, navigate: 'pop',);
        }
    );
  }




  Widget _buildEmailForgotForm(){

    return TextFormField(
      decoration: InputDecoration(
          labelText: 'E-Mail',
          hintText: 'mail@example.com',
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: EdgeInsets.symmetric(horizontal: 25, vertical: 15),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(
                  color: Colors.grey,
                  width: 1
              )
          ),
          prefixIcon: Icon(Entypo.getIconData('mail'), size: 18,)
      ),
      controller: _emailForgotTextController,
      keyboardType: TextInputType.emailAddress,
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


  @override
  Widget build(BuildContext context) {

    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 550 ? 600 : deviceWidth * 0.95;
    final double padding = deviceWidth - targetWidth;

    return Scaffold(
            key: _scaffoldKey,
            body: GestureDetector(
              onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
              child: ScopedModelDescendant<MainModel>(
                builder: (BuildContext context, Widget child, MainModel model){
                  return Center(
                    child: SingleChildScrollView(
                      child: Container(
                        padding: EdgeInsets.all(padding),
                        //                color: Colors.red,
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: <Widget>[
                              _buildLogo(),
                              _buildEmailTextField(),
                              SizedBox(height: 10,),
                              _buildPasswordTextField(),
                              SizedBox(height: 25,),
                              model.isLoading
                                  ? Center(child: CircularProgressIndicator(),)
                                  : Column(
                                      children: <Widget>[
                                        _buildLoginButton(targetWidth),
                                        SizedBox(height: 15,),
                                        _buildRegister(),
                                        SizedBox(height: 25,),
                                        OrTextWidget(),
                                        SizedBox(height: 25,),
                                        SocialAuth(model: model, width: targetWidth,)
                                      ],
                                    )

                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
      //      ),
          );
  }

}
