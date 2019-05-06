import 'package:logistics/models/user.dart';
import 'package:meta/meta.dart';

class SupportList{

  final int id;
  final String title;
  final bool isClosed;
  final String date;
  final UserShort userShort;

  SupportList({
    @required this.id,
    @required this.title,
    @required this.isClosed,
    @required this.date,
    @required this.userShort
  });
}


class SupportChat{

  final int id;
  final bool isOperator;
  final bool isMe;
  final String content;
  final UserShort userShort;
  final String date;

  SupportChat({
    @required this.id,
    @required this.isOperator,
    @required this.isMe,
    @required this.content,
    @required this.userShort,
    @required this.date,
  });
}
