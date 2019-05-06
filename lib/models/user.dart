import 'package:flutter/material.dart';

class User{

  final String token;

  User({
    @required this.token,
  });

}

class UserShort{

  final String firstName;
  final String lastName;
  final String imageThumbUrl;

  UserShort({
    @required this.firstName,
    @required this.lastName,
    @required this.imageThumbUrl,
  });

  String toString(){
    return 'firstName: $firstName, '
        'lastName: $lastName, '
        'imageThumbUrl: $imageThumbUrl';
  }
}