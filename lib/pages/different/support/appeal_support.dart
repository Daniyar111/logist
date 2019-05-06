import 'package:flutter/material.dart';
import 'package:flutter_icons/entypo.dart';

class AppealSupportPage extends StatefulWidget {
  @override
  _AppealSupportPageState createState() => _AppealSupportPageState();
}

class _AppealSupportPageState extends State<AppealSupportPage> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _titleTextController = TextEditingController();
  final _contentTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 550 ? 600 : deviceWidth * 0.97;
    final double padding = deviceWidth - targetWidth;

    return Scaffold(
      appBar: AppBar(
        title: Text('Обращение'),
        centerTitle: true,
        leading: GestureDetector(
          onTap: (){},
          child: Text('Отмена'),
        ),
        actions: <Widget>[
          Icon(Icons.check)
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: padding, vertical: 20),
              child: Column(
                children: <Widget>[
                  _buildTitleTextField(),
                  SizedBox(height: 20,),
                  _buildContentTextField(),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildTitleTextField(){

    return TextFormField(
      textAlign: TextAlign.justify,
      decoration: InputDecoration(
          labelText: 'Тема',
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
      ),
      controller: _titleTextController,
      keyboardType: TextInputType.text,
      validator: (String value){
        if (value.trim().isEmpty){
          return 'Тема не должна быть пустой';
        }
      },
    );
  }


  Widget _buildContentTextField(){

    return TextFormField(
      textAlign: TextAlign.justify,
      decoration: InputDecoration(
        labelText: 'Сообщение',
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
      ),
      controller: _contentTextController,
      keyboardType: TextInputType.text,
      validator: (String value){
        if (value.trim().isEmpty){
          return 'Сообщение обязательно';
        }
      },
    );
  }
}
