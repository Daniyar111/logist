import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:logistics/scoped_models/main_model.dart';
import 'package:scoped_model/scoped_model.dart';
import '../models/calc.dart';

class CalculatorPage extends StatefulWidget {

  final MainModel model;

  CalculatorPage(this.model);

  @override
  _CalculatorPageState createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _weightTextController = TextEditingController();
  final _lengthTextController = TextEditingController();
  final _widthTextController = TextEditingController();
  final _heightTextController = TextEditingController();

  //Todo focusNode to next input don't forget to all application

  WeightCalc _selectedWeight;
  LengthCalc _selectedLength;
  List<WeightCalc> _weights = [const WeightCalc('kg', 'Килограмм'), const WeightCalc('lb', 'Фунт')];
  List<LengthCalc> _length = [const LengthCalc('cm', 'Сантиметр'), const LengthCalc('in', 'Дюйм')];

  @override
  void initState() {

    _selectedLength = _length.first;
    _selectedWeight = _weights.first;

    super.initState();
  }


  Widget _buildText(){

    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Text('Впишите значения Вашей посылки, указывая меру длины и меру веса', style: TextStyle(fontSize: 15),),
    );
  }


  Widget _buildWeightTextField(){

    return Container(
      margin: EdgeInsets.only(right: 5, bottom: 5),
      child: TextFormField(
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          labelText: "Вес",
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
        ),
        keyboardType: TextInputType.number,
        controller: _weightTextController,
        validator: (String value){

          if(value.isEmpty || !RegExp(r"^(?:[1-9]\d*|0)?(?:[.,]\d+)?$").hasMatch(value)){
            return "Введите цифровые значения";
          }
        },
      ),
    );
  }


  Widget _buildLengthTextField(){

    return Container(
      margin: EdgeInsets.only(left: 5, bottom: 5),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: "Длина",
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
        ),
        keyboardType: TextInputType.number,
        controller: _lengthTextController,
        validator: (String value){
          if(value.isEmpty || !RegExp(r"^(?:[1-9]\d*|0)?(?:[.,]\d+)?$").hasMatch(value)){
            return "Введите цифровые значения";
          }
        },
      ),
    );
  }


  Widget _buildWidthTextField(){

    return Container(
      margin: EdgeInsets.only(top: 5, right: 5),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: "Ширина",
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
        ),
        keyboardType: TextInputType.number,
        controller: _widthTextController,
        validator: (String value){

          if(value.isEmpty || !RegExp(r"^(?:[1-9]\d*|0)?(?:[.,]\d+)?$").hasMatch(value)){
            return "Введите цифровые значения";
          }
        },
      ),
    );
  }


  Widget _buildHeightTextField(){

    return Container(
      margin: EdgeInsets.only(top: 5, left: 5),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: "Высота",
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
        ),
        keyboardType: TextInputType.number,
        controller: _heightTextController,
        validator: (String value){

          if(value.isEmpty || !RegExp(r"^(?:[1-9]\d*|0)?(?:[.,]\d+)?$").hasMatch(value)){
            return "Введите цифровые значения";
          }
        },
      ),
    );
  }


  Widget _buildAnswerText(CalcData data, bool isLoading){

    if(isLoading){
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    else{
      if(data == null){
        return Container();
      }

      else if(data.status == 'success'){
        return Center(
          child: Text('Получилось ${data.value}${data.sign}', style: TextStyle(fontSize: 17),),
        );
      }
      else{
        return Center(
          child: Text(data.message, style: TextStyle(fontSize: 17),),
        );
      }
    }
  }


  Widget _buildCountButton(double width){

    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model){

        return ButtonTheme(
          minWidth: width,
          child: RaisedButton(
              child: Text('Посчитать'),
              textColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20))
              ),
              onPressed: () => _onPressed(model)
          ),
        );
      },
    );
  }


  Future _onPressed(MainModel model) async {

    if(!_formKey.currentState.validate()){
      return;
    }

    _formKey.currentState.save();

    await model.postCalculatorData(double.parse(_weightTextController.text), double.parse(_lengthTextController.text), double.parse(_widthTextController.text), double.parse(_heightTextController.text), _selectedWeight.value, _selectedLength.value)
        .then((response){

      print('calculator $response');

    }).catchError((error){
      print(error);
    });
  }


  @override
  Widget build(BuildContext context) {

    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 550 ? 600 : deviceWidth * 0.95;
    final double padding = deviceWidth - targetWidth;

    return Scaffold(
      appBar: AppBar(
        title: Text('Калькулятор'),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: ScopedModelDescendant<MainModel>(
          builder: (BuildContext context, Widget child, MainModel model){
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: padding),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      _buildText(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.only(right: 5, top: 10),
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.black45,
                                  width: 1,
                                  style: BorderStyle.solid
                                ),
                                borderRadius: BorderRadius.all(Radius.circular(10))
                              ),
                              child: Column(
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(Entypo.getIconData('ruler'), size: 20,),
                                      SizedBox(width: 8,),
                                      Text('Мера длины', style: TextStyle(fontSize: 18),),
                                    ],
                                  ),
                                  Container(
                                    margin: EdgeInsets.all(5),
                                    child: DropdownButton(
                                      isExpanded: true,
                                      value: _selectedLength,
                                      items: _length.map((LengthCalc length){
                                        return DropdownMenuItem(
                                          value: length,
                                          child: Text(
                                            length.name,
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (LengthCalc length){
                                        setState(() {
                                          _selectedLength = length;
                                        });
                                      },
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.only(left: 5, top: 10),
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.black45,
                                      width: 1,
                                      style: BorderStyle.solid
                                  ),
                                  borderRadius: BorderRadius.all(Radius.circular(10))
                              ),
                              child: Column(
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(MaterialCommunityIcons.getIconData('weight'), size: 20,),
                                      SizedBox(width: 8,),
                                      Text('Мера веса', style: TextStyle(fontSize: 18),),
                                    ],
                                  ),
                                  Container(
                                    margin: EdgeInsets.all(5),
                                    child: DropdownButton(
                                      value: _selectedWeight,
                                      isExpanded: true,
                                      items: _weights.map((WeightCalc weight){
                                        return DropdownMenuItem(
                                          value: weight,
                                          child: Text(
                                            weight.name,
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (WeightCalc weight){
                                        setState(() {
                                          _selectedWeight = weight;
                                        });
                                      },
                                    ),
                                  )
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 20,),
                      Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Expanded(child: _buildWeightTextField()),
                              Expanded(child: _buildLengthTextField()),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Expanded(child: _buildWidthTextField()),
                              Expanded(child: _buildHeightTextField())
                            ],
                          )
                        ],
                      ),
                      SizedBox(height: 20,),
                      _buildCountButton(targetWidth),
                      SizedBox(height: 40,),
                      _buildAnswerText(model.calcData, model.isCalcLoading),
                      SizedBox(height: 40,),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      )
    );
  }

  @override
  void dispose() {

    widget.model.removeCalcData();
    super.dispose();
  }
}
