import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/entypo.dart';
import 'package:flutter_icons/font_awesome.dart';
import 'package:logistics/models/gender.dart';
import 'package:logistics/scoped_models/main_model.dart';
import 'package:logistics/widgets/check_dialog.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:image_picker/image_picker.dart';

class MyProfilePage extends StatefulWidget {

  @override
  _MyProfilePageState createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  final _firstNameTextController = TextEditingController();
  final _lastNameTextController = TextEditingController();
  final _userNameTextController = TextEditingController();
  final _phoneTextController = TextEditingController();
  final _emailTextController = TextEditingController();
  final _newPasswordTextController = TextEditingController();
  final _confirmPasswordTextController = TextEditingController();

  final RegExp _emailRegExp = RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?");
  final RegExp _noNumberRegExp = RegExp(r"^\D+$");

  Gender _selectedGender;
  List<Gender> _genders = [Gender(null, 'Не выбирать'), Gender('male', 'Мужской'), Gender('female', 'Женский'), ];

  bool _isObscureNewPassword = true;
  bool _isObscureConfirmPassword = true;
  bool _isBirthCheck = true;
  bool _isGenderCheck = true;
  String _parsedDate = 'Выбрать дату';
  static DateTime _now = DateTime.now();
  DateTime _date = DateTime(_now.year - 20, _now.month, _now.day);


  @override
  Widget build(BuildContext context) {

    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 550 ? 600 : deviceWidth * 0.95;
    final double padding = deviceWidth - targetWidth;


    // Todo isActivated need to add
    // Todo image picker, passport

    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model){
        return Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            title: Text('Мой профиль'),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.check),
                color: Colors.white,
                onPressed: () => _onSubmit(model)
              )
            ],
          ),
          body: GestureDetector(
            onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: padding),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
//                      SizedBox(height: 15,),
//                      RaisedButton(
//                        child: Text('Image from Gallery'),
//                        onPressed: model.imageSelectorGallery,
//                      ),
//                      RaisedButton(
//                        child: Text('Image from Camera'),
//                        onPressed: model.imageSelectorCamera,
//                      ),
                      _buildSelectedFile(model.logoFile, model.profile.imageData.normal, model),

                      SizedBox(height: 20,),
                      Container(alignment: Alignment.centerLeft, child: Text('Личная информация', style: TextStyle(color: Colors.black, fontSize: 18),)),
                      SizedBox(height: 10,),
                      _buildFirstNameTextField(model.profile.firstName),
                      SizedBox(height: 10,),
                      _buildLastNameTextField(model.profile.lastName),
                      SizedBox(height: 10,),
                      _buildUserNameTextField(model.profile.username),
                      SizedBox(height: 10,),
                      _buildGenderField(targetWidth, model.profile.gender),
                      SizedBox(height: 10,),
                      _buildDatePicker(context, model.profile.birthDate),
                      SizedBox(height: 10,),
                      _buildPhoneTextField(model.profile.phone),
                      SizedBox(height: 20,),
                      Container(alignment: Alignment.centerLeft, child: Text('Настройки аккаунта', style: TextStyle(color: Colors.black, fontSize: 18),)),
                      SizedBox(height: 10,),
                      _buildEmailTextField(model.profile.email),
                      !model.profile.isEmailVerified ? Text('Ваш email не подтвержден, пожалуйста, подтвердите Вашу почту') : Container(),
                      SizedBox(height: 20,),
                      _buildNewPasswordTextField(),
                      SizedBox(height: 10,),
                      _buildConfirmPasswordTextField(),
                      SizedBox(height: 10,),
                    ],
                  ),
                ),
              ),
            ),
          )
        );
      },
    );
  }


  void _logoBottomSheet(BuildContext context, MainModel model){

    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc){
          return Container(
            child: Wrap(
              children: <Widget>[
                ListTile(
                    leading: Icon(FontAwesome.getIconData('th-large')),
                    title: Text('Выбрать из галлереи'),
                    onTap: model.imageSelectorGallery
                ),
                ListTile(
                  leading: Icon(FontAwesome.getIconData('camera')),
                  title: Text('Сфотографировать'),
                  onTap: model.imageSelectorCamera,
                ),
              ],
            ),
          );
        }
    );
  }

  void _onSubmit(MainModel model) async{

    if(!_formKey.currentState.validate()){
      return;
    }
    _formKey.currentState.save();

    print('parsed date $_parsedDate');
    await model.updateUserProfile(
      firstName: _firstNameTextController.text,
      lastName: _lastNameTextController.text,
      userName: _userNameTextController.text == '' ? null : _userNameTextController.text,
      phone: _phoneTextController.text == '' ? null : _phoneTextController.text,
      email: _emailTextController.text,
      gender: _selectedGender.value,
      birthDate: (_parsedDate == 'Выбрать дату') ? null : _parsedDate.replaceAll(' ', ''),
      newPassword: _newPasswordTextController.text == '' ? null : _newPasswordTextController.text,
      confirmPassword: _confirmPasswordTextController.text == '' ? null : _confirmPasswordTextController.text
    )
        .then((response) async {
      if(response['status'] == 'success'){
        print('success ${response['message']}');
        _showCheckDialog(context, 'success', response['message']);
        if(model.logoFile != null){
          await model.uploadLogo(model.logoFile).then((logoData){

            if(logoData['status'] == 'success'){
              _showCheckDialog(context, 'success', response['message']);
            }
            else{
              _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(response['message'])));
            }
          }).catchError((error){
            print(error);
          });
        }

      }
      else if(response['status'] == 'warning'){
        print('warning ${response['message']}');
//            Navigator.pushReplacementNamed(context, '/');
//        Navigator.of(context).popUntil(ModalRoute.withName('/'));
//            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainPage(model)));
        _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(response['message'])));
      }
      else if(response['status'] == 'error'){
        print('error ${response['message']}');
        _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(response['message'])));
      }
    }).catchError((error){
      print(error);
    });

  }


  void _showCheckDialog(BuildContext context, String response, String message){
    print('CHECKDI');
    showDialog(
        context: context,
        builder: (BuildContext context){

          return CheckDialog(response: response, message: message, navigate: 'main',);
        }
    );
  }


  Widget _buildSelectedFile(File file, String imageUrl, MainModel model){
    return GestureDetector(
      onTap: (){
        _logoBottomSheet(context, model);
      },
      child: Container(
          width: double.infinity,
          child: file == null
              ? FadeInImage(
                  image: NetworkImage(imageUrl),
                  placeholder: AssetImage('assets/place_holder.png'),
                  //            height: 300,
                  fit: BoxFit.cover,
                )
              : Image.file(file, fit: BoxFit.cover,)
      ),
    );
  }


  Widget _buildFirstNameTextField(String firstName){


    if (firstName == null && _firstNameTextController.text.trim() == '') {

      // no product and no values entered by user
      _firstNameTextController.text = '';
    }
    else if (firstName != null && _firstNameTextController.text.trim() == '') {

      // there is a product and the user didn't entered something
      _firstNameTextController.text = firstName;
    }


    return TextFormField(
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
          labelText: 'Имя*',
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
          prefixIcon: Icon(Entypo.getIconData('user'), size: 18)
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



  Widget _buildLastNameTextField(String lastName){


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
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(
                  color: Colors.grey,
                  width: 1
              )
          ),
          prefixIcon: Icon(Entypo.getIconData('user'), size: 18,)
      ),
      keyboardType: TextInputType.text,
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


  Widget _buildUserNameTextField(String userName){


    if (userName == null && _userNameTextController.text.trim() == '') {

      // no product and no values entered by user
      _userNameTextController.text = '';
    }
    else if (userName != null && _userNameTextController.text.trim() == '') {

      // there is a product and the user didn't entered something
      _userNameTextController.text = userName;
    }


    return TextFormField(
      decoration: InputDecoration(
          labelText: 'Никнейм',
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
          prefixIcon: Icon(Entypo.getIconData('user'), size: 18,)
      ),
      keyboardType: TextInputType.text,
      controller: _userNameTextController,
      validator: (String value){
        print('username is $value');
        // Todo username must be unique
      },
    );
  }


  Widget _buildGenderField(double width, String gender){

    print('sel gender $gender');

    if(_isGenderCheck && gender != null){
      if(gender == 'male'){
        _selectedGender = _genders[1];
      }
      else if(gender == 'female'){
        _selectedGender = _genders[2];
      }
      _isGenderCheck = false;
    }
    else if(_isGenderCheck && gender == null){

      _selectedGender = _genders[0];
      _isGenderCheck = false;
    }
    print('sele gen ${_selectedGender.name}');

    return Container(
      width: width,
      child: Row(
        children: <Widget>[

          Expanded(
            child: Text('Пол'),
            flex: 1,
          ),

          Expanded(
            flex: 3,
            child: DropdownButton(
              isExpanded: true,
              elevation: 3,
              value: _selectedGender,
              items: _genders.map((Gender gender){
                return DropdownMenuItem(
                  value: gender,
                  child: Text(
                    gender.name,
                  ),
                );
              }).toList(),
              onChanged: (Gender gender){
                print('gen ${gender.name}');
                setState(() {
                  _selectedGender = gender;
                });
                print('gesfan ${_selectedGender.name}');
              },
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildMenu(List<Widget> children) {

    return Container(
      decoration: BoxDecoration(
//        color: Colors.white,
        border: const Border(
          top: BorderSide(color: Color(0xFFBCBBC1), width: 0.0),
          bottom: BorderSide(color: Color(0xFFBCBBC1), width: 0.0),
        ),
      ),
      height: 44.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 1.0),
        child: SafeArea(
          top: false,
          bottom: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: children,
          ),
        ),
      ),
    );
  }


  Widget _buildDatePicker(BuildContext context, String birthDate) {

    if(_isBirthCheck && birthDate != null){
      List<String> birthDateSplit = birthDate.split('-');
      _date = DateTime(int.parse(birthDateSplit[0]), int.parse(birthDateSplit[1]), int.parse(birthDateSplit[2]));
      _parsedDate = '${_date.day} - ${(_date.month.toString().length < 2) ? '0${_date.month}' : '${_date.month}'} - ${_date.year}';
      _isBirthCheck = false;
    }

    return GestureDetector(
      onTap: () {
        showCupertinoModalPopup<void>(
          context: context,
          builder: (BuildContext context) {
            return _buildBottomPicker(
              CupertinoDatePicker(
                maximumYear: _now.year - 16,
                mode: CupertinoDatePickerMode.date,
                initialDateTime: _date,
                minimumYear: _now.year - 80,
                onDateTimeChanged: (DateTime newDateTime) {
                  setState(() {
                    _date = newDateTime;
                    _parsedDate = '${_date.day} - ${(_date.month.toString().length < 2) ? '0${_date.month}' : '${_date.month}'} - ${_date.year}';
                  });
                },
              ),
            );
          },
        );
      },
      child: _buildMenu(
          <Widget>[
            const Text('Дата рождения'),
            Text(
              _parsedDate,
              style: const TextStyle(color: Colors.black, fontSize: 18),
            ),
            ButtonTheme(
              minWidth: 30,
              child: FlatButton(
                onPressed: (){
                  setState(() {
                    _parsedDate = 'Выбрать дату';
                  });
                },
                child: Icon(Icons.close),
                shape: CircleBorder(),
              ),
            )
          ]
      ),
    );
  }




  Widget _buildBottomPicker(Widget picker) {

    return Container(
      height: 216,
      padding: const EdgeInsets.only(top: 6.0),
      color: CupertinoColors.white,
      child: DefaultTextStyle(
        style: const TextStyle(
          color: CupertinoColors.black,
          fontSize: 22.0,
        ),
        child: GestureDetector(
          // Blocks taps from propagating to the modal sheet and popping.
          onTap: () {},
          child: SafeArea(
            top: false,
            child: picker,
          ),
        ),
      ),
    );
  }



  Widget _buildPhoneTextField(String phone){


    if (phone == null && _phoneTextController.text.trim() == '') {

      // no product and no values entered by user
      _phoneTextController.text = '';
    }
    else if (phone != null && _phoneTextController.text.trim() == '') {

      // there is a product and the user didn't entered something
      _phoneTextController.text = phone;
    }

    return TextFormField(
      decoration: InputDecoration(
        hintText: '+996555000000',
        labelText: 'Телефон',
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
        prefixIcon: Icon(FontAwesome.getIconData('phone'), size: 18,)
      ),
      keyboardType: TextInputType.phone,
      controller: _phoneTextController,
      validator: (String value){
        print(value);

      },
    );
  }


  Widget _buildEmailTextField(String email){

    if (email == null && _emailTextController.text.trim() == '') {

      // no product and no values entered by user
      _emailTextController.text = '';
    }
    else if (email != null && _emailTextController.text.trim() == '') {

      // there is a product and the user didn't entered something
      _emailTextController.text = email;
    }

    return TextFormField(
      decoration: InputDecoration(
        hintText: 'example@mail.com',
        labelText: 'E-mail*',
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
      keyboardType: TextInputType.emailAddress,
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



//  Widget _buildIsEmailVerified(){
//
//    return
//  }



  Widget _buildNewPasswordTextField(){

    return TextFormField(
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
          labelText: "Новый пароль",
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
          prefixIcon: Icon(Entypo.getIconData('key'), size: 18,),
          suffixIcon: GestureDetector(
            onTap: (){
              setState(() {
                _isObscureNewPassword = !_isObscureNewPassword;
              });
            },
            child: Icon(
                _isObscureNewPassword
                    ? Entypo.getIconData('eye')
                    : Entypo.getIconData('eye-with-line')
            ),
          )
      ),
      controller: _newPasswordTextController,
      obscureText: _isObscureNewPassword,
      validator: (String value){
        if(value != _confirmPasswordTextController.text){
          return 'Пароли не совпадают';
        }
      },

    );
  }


  Widget _buildConfirmPasswordTextField(){

    return TextFormField(
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
          labelText: "Подтверждение пароля",
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
          prefixIcon: Icon(Entypo.getIconData('key'), size: 18,),
          suffixIcon: GestureDetector(
            onTap: (){
              setState(() {
                _isObscureConfirmPassword = !_isObscureConfirmPassword;
              });
            },
            child: Icon(
                _isObscureConfirmPassword
                    ? Entypo.getIconData('eye')
                    : Entypo.getIconData('eye-with-line')
            ),
          )
      ),
      controller: _confirmPasswordTextController,
      obscureText: _isObscureConfirmPassword,
      validator: (String value){

        if(value != _newPasswordTextController.text){
          return 'Пароли не совпадают';
        }
      },

    );
  }







}
