// To parse this JSON data, do
//
//     final userModel = userModelFromJson(jsonString);

import 'dart:convert';

UserModel userModelFromJson(String str) {
  final jsonData = json.decode(str);
  return UserModel.fromJson(jsonData);
}

String userModelToJson(UserModel data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

class UserModel {
  int id;
  String firstName;
  String lastName;
  String gender;
  String username;
  String email;
  bool isEmailVerified;
  String birthdate;
  String phone;
  bool isActivated;

  UserModel({
    this.id,
    this.firstName,
    this.lastName,
    this.gender,
    this.username,
    this.email,
    this.isEmailVerified,
    this.birthdate,
    this.phone,
    this.isActivated,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => new UserModel(
    id: json["id"],
    firstName: json["first_name"],
    lastName: json["last_name"],
    gender: json["gender"],
    username: json["username"],
    email: json["email"],
    isEmailVerified: json["is_email_verified"],
    birthdate: json["birthdate"],
    phone: json["phone"],
    isActivated: json["is_activated"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "first_name": firstName,
    "last_name": lastName,
    "gender": gender,
    "username": username,
    "email": email,
    "is_email_verified": isEmailVerified,
    "birthdate": birthdate,
    "phone": phone,
    "is_activated": isActivated,
  };
}
