import 'package:flutter/material.dart';
import 'package:logistics/models/image.dart';

class Profile{

  final String firstName;
  final String lastName;
  final String gender;
  final String username;
  final String email;
  final bool isEmailVerified;
  final String birthDate;
  final String phone;
  final bool isActivated;
  final ImageData imageData;

  Profile({
    @required this.firstName,
    @required this.lastName,
    @required this.gender,
    @required this.username,
    @required this.email,
    @required this.isEmailVerified,
    @required this.birthDate,
    @required this.phone,
    @required this.isActivated,
    @required this.imageData,
  });

}