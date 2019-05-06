import 'package:flutter/material.dart';
import 'package:logistics/models/user.dart';

class BlogList{

  final int id;
  final String title;
  final String context;
  final String imageNormalUrl;
  final bool isPinned;
  final int numberOfComments;
  final String date;

  BlogList({
    @required this.id,
    @required this.title,
    @required this.context,
    @required this.imageNormalUrl,
    @required this.isPinned,
    @required this.numberOfComments,
    @required this.date,
  });
}

class Blog{

  final int id;
  final String title;
  final String content;
  final List<String> imagesNormalUrl;
  int numberOfComments;
  final String date;

  Blog({
    @required this.id,
    @required this.title,
    @required this.content,
    @required this.imagesNormalUrl,
    @required this.numberOfComments,
    @required this.date,
  });
}

class Comment{

  final int id;
  final String content;
  final bool canRemove;
  final bool canReply;
  final String date;
  List<Comment> replies;
  final UserShort userShort;

  Comment({
    @required this.id,
    @required this.content,
    @required this.canRemove,
    @required this.canReply,
    @required this.date,
    this.replies,
    @required this.userShort
  });


  String toString(){
    return 'id: $id, '
        'content: $content, '
        'canRemove: $canRemove, '
        'canReply: $canReply, '
        'date: $date, '
        'replies: ${replies.toString()}, '
        'userShort: ${userShort.toString()}';
  }
}