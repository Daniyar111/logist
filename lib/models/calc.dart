import 'package:meta/meta.dart';

class LengthCalc{

  final String value;
  final String name;

  const LengthCalc(this.value, this.name);
}

class WeightCalc{

  final String value;
  final String name;

  const WeightCalc(this.value, this.name);
}

class CalcData{

  final int value;
  final String sign;
  final String message;
  final String status;

  CalcData({
    @required this.value,
    @required this.sign,
    @required this.message,
    @required this.status,
  });
}