import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/entypo.dart';
import 'package:flutter_svg/svg.dart';
import 'package:logistics/pages/main.dart';
import 'package:logistics/scoped_models/main_model.dart';
import 'package:logistics/widgets/check_dialog.dart';

class SocialAuth extends StatefulWidget {

  final MainModel model;
  final double width;

  SocialAuth({Key key, this.model, this.width})
      : super(key: key);

  @override
  _SocialAuthState createState() => _SocialAuthState();
}

class _SocialAuthState extends State<SocialAuth> {

  final _firstNameTextController = TextEditingController();
  final _lastNameTextController = TextEditingController();
  final _emailTextController = TextEditingController();
  final RegExp _noNumberRegExp = RegExp(r"^\D+$");
  final RegExp _emailRegExp = RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?");


  @override
  Widget build(BuildContext context) {
    return _buildSocialAuth(context, widget.width);
  }


  Widget _buildSocialAuth(BuildContext context, double width){

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        _buildGoogleButton(context),
        SizedBox(width: 20,),
        _buildFacebookButton(context),
      ],
    );
  }



  Widget _buildGoogleButton(BuildContext context){
    return Ink(
        decoration: BoxDecoration(
            border: Border.all(width: 1, color: Theme.of(context).accentColor),
            color: Colors.white,
            shape: BoxShape.circle
        ),
        child: InkWell(
            onTap: () => _onGoogleTap(context),
            child: Container(
              padding: EdgeInsets.all(15),
              child: SvgPicture.asset('assets/search.svg', width: 25, height: 25,),
            )
        )

    );
  }


  Widget _buildFacebookButton(BuildContext context){
    return Ink(
        decoration: BoxDecoration(
            border: Border.all(width: 1, color: Theme.of(context).accentColor),
            color: Colors.white,
            shape: BoxShape.circle
        ),
        child: InkWell(

            onTap: () => _onFacebookTap(context),
            child: Container(
              padding: EdgeInsets.all(15),
              child: SvgPicture.asset('assets/facebook-app-symbol.svg', width: 25, height: 25,),
            )
        )

    );
  }


  void _onGoogleTap(BuildContext context){

    widget.model.googleSignIn().then((FirebaseUser user) async {
      print(user);

      await widget.model.socialAuthCheck(user.uid, user.providerData[1].providerId).then((value) async {
        if(value['data']['user_exists']){
          Map<String, dynamic> answer = await widget.model.socialAuthLogin(uid: user.uid, type: user.providerData[1].providerId)
              .then((response){
            if(response['status'] == 'success'){
//              Navigator.pushReplacementNamed(context, '/');
              Navigator.of(context).popUntil(ModalRoute.withName('/'));
              print('google login is $response');
            }
            else if(response['status'] == 'warning'){
              print('google login is $response');
//              Navigator.pushReplacementNamed(context, '/');
              Navigator.of(context).popUntil(ModalRoute.withName('/'));
            }
            else if(response['status'] == 'error'){
              print('google login is $response');
            }
          }).catchError((error){
            print(error);
          });
          print('login is $answer');
        }
        else{

          print('emailll ${user.providerData[1].email}');

          await widget.model.socialAuthRegistration(
              uid: user.uid,
              email: user.providerData[1].email,
              type: user.providerData[1].providerId
          ).then((response){
            if(response['status'] == 'success'){
//              Navigator.pushReplacementNamed(context, '/');
              Navigator.of(context).popUntil(ModalRoute.withName('/'));
              print('google registr is $response');
            }
            else if(response['status'] == 'warning'){
              print('google registr is $response');
//              Navigator.pushReplacementNamed(context, '/');
              Navigator.of(context).popUntil(ModalRoute.withName('/'));
            }
            else if(response['status'] == 'error'){
              print('google registr is $response');
            }

          }).catchError((error){
            print(error);
          });

        }
      });


    }).catchError((error){
      print(error);
    });
  }


  void _onFacebookTap(BuildContext context){
    widget.model.facebookLogIn().then((FirebaseUser user) async {

      if(user != null){
        print('user is $user');

        await widget.model.socialAuthCheck(user.uid, user.providerData[1].providerId).then((value) async {
          if(value['data']['user_exists']){
            Map<String, dynamic> answer = await widget.model.socialAuthLogin(uid: user.uid, type: user.providerData[1].providerId)
                .then((response){
              if(response['status'] == 'success'){
//                Navigator.pushReplacementNamed(context, '/');
                Navigator.of(context).popUntil(ModalRoute.withName('/'));
                print('facebook l ogin is $response');
              }
              else if(response['status'] == 'warning'){
                print('facebook login is $response');
                Navigator.of(context).popUntil(ModalRoute.withName('/'));
//                Navigator.pushReplacementNamed(context, '/');
              }
              else if(response['status'] == 'error'){
                print('facebook login is $response');
                _showCheckDialog(context ,'error', response['message']);
              }
            }).catchError((error){
              print(error);
            });
            print('login is $answer');
          }
          else{

            print('emailll ${user.providerData[1].email}');
            print('display nameeee ${user.providerData[1].displayName}');

            if(user.providerData[1].email == null){
              _showFormDialog(
                  context: context,
                  firstName: _displayNameSplitting(user.providerData[1].displayName)[0],
                  lastName: _displayNameSplitting(user.providerData[1].displayName)[1],
                  type: user.providerData[1].providerId,
                  uid: user.uid,
                  width: widget.width
              );
              return;
            }

            await widget.model.socialAuthRegistration(
                uid: user.uid,
                email: user.providerData[1].email,
                type: user.providerData[1].providerId,
                firstName: _displayNameSplitting(user.providerData[1].displayName)[0],
                lastName: _displayNameSplitting(user.providerData[1].displayName)[1]
            ).then((response){
              print('response facebook $response');
              if(response['status'] == 'success'){
//                Navigator.pushReplacementNamed(context, '/');
                Navigator.of(context).popUntil(ModalRoute.withName('/'));
                print('facebook registr is $response');
              }
              else if(response['status'] == 'warning'){
                print('facebook registr is $response');
//                Navigator.pushReplacementNamed(context, '/');
                Navigator.of(context).popUntil(ModalRoute.withName('/'));
              }
              else if(response['status'] == 'error'){
                print('facebook registr is $response');
                _showCheckDialog(context, 'error', response['message']);
              }
            }).catchError((error){
              print(error);
            });
          }
        });

        print('Facebook user: $user');
      }
      else{
        print('user is $user');
      }
    }).catchError((error){
      print(error);
    });
  }


  List<String> _displayNameSplitting(String name){

    List<String> displayName = name.split(" ");

    String firstName = '';
    String lastName = '';

    if(displayName.length < 2){
      firstName = name;
      lastName = ' ';
    }
    else{
      firstName = displayName[0];
      lastName = displayName[1];
    }
    print('split ${[firstName, lastName]}');

    return [firstName, lastName];
  }


  void _showCheckDialog(BuildContext context, String response, String message){

    showDialog(
        context: context,
        builder: (BuildContext context){

          return CheckDialog(response: response, message: message, navigate: 'pop',);
        }
    );
  }


  void _showFormDialog({BuildContext context, String uid, String type, String firstName, String lastName, double width}){

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context){



          return SimpleDialog(
            title: Text('В соц. сети не указаны некоторые данные, пожалуйста, укажите'),
            children: <Widget>[

              _buildFirstNameForm(firstName),
              _buildLastNameForm(lastName),



              TextFormField(
                decoration: InputDecoration(
                    labelText: 'E-Mail',
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
                controller: _emailTextController,
                keyboardType: TextInputType.emailAddress,
                validator: (String value){
                  if (value.isEmpty){
                    return 'Введите e-mail';
                  }
                  else if(!_emailRegExp.hasMatch(value)){
                    return 'Введите правильный e-mail';
                  }
                },
//              onSaved: (String value) => _formDialog["email"] = value,
              ),


              ButtonTheme(
                minWidth: width,
                child: RaisedButton(
                    child: Text('Вход'),
                    textColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20))
                    ),
                    onPressed: () async{

                      print('controller ${_emailTextController.text}');
                      print('controller ${_firstNameTextController.text}');
                      print('controller ${_lastNameTextController.text}');

                      await widget.model.socialAuthRegistration(
                          uid: uid,
                          email: _emailTextController.text,
                          type: type,
                          firstName: _firstNameTextController.text,
                          lastName: _lastNameTextController.text
                      ).then((response){
                        print('response after facebook $response');
                        Navigator.pop(context);
                        if(response['status'] == 'success'){
//                          Navigator.pushReplacementNamed(context, '/');
                          Navigator.of(context).popUntil(ModalRoute.withName('/'));
                          print('facebook registr is $response');
                        }
                        else if(response['status'] == 'warning'){
                          print('facebook registr is $response');
//                          Navigator.pushReplacementNamed(context, '/');
                          Navigator.of(context).popUntil(ModalRoute.withName('/'));
                        }
                        else if(response['status'] == 'error'){
                          print('facebook registr is $response');
                        }

                      }).catchError((error){
                        print(error);
                      });
                    }
                ),
              )

            ],
          );
        }
    );

  }


  Widget _buildFirstNameForm(String firstName){

    if (firstName == null && _firstNameTextController.text.trim() == '') {

      // no product and no values entered by user
      _firstNameTextController.text = '';
    }
    else if (firstName != null && _firstNameTextController.text.trim() == '') {

      // there is a product and the user didn't entered something
      _firstNameTextController.text = firstName;
    }

    return TextFormField(
      decoration: InputDecoration(
          labelText: 'Имя*',
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
      controller: _firstNameTextController,
      keyboardType: TextInputType.text,
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


  Widget _buildLastNameForm(String lastName){

    if (lastName == null && _lastNameTextController.text.trim() == '') {

      // no product and no values entered by user
      _lastNameTextController.text = '';
    }
    else if (lastName != null && _lastNameTextController.text.trim() == '') {

      // there is a product and the user didn't entered something
      _lastNameTextController.text = lastName;
    }

    return TextFormField(
      decoration: InputDecoration(
          labelText: 'Фамилия*',
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
      controller: _lastNameTextController,
      keyboardType: TextInputType.text,
      validator: (String value){
        if (value.trim().isEmpty){
          return 'Введите свою фамилию';
        }
        else if(!_noNumberRegExp.hasMatch(value)){
          return 'Фамилия не должна содержать цифры';
        }
      },
    );
  }
}
