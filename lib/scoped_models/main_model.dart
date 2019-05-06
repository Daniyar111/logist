import 'package:scoped_model/scoped_model.dart';
import 'package:logistics/scoped_models/connected_model.dart';

class MainModel extends Model with ConnectedModel, AuthModel, CalculatorModel, BlogModel, SupportModel{

}