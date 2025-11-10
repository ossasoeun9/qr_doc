import 'dart:convert';

import 'package:qr_doc/main.dart';

class UserModel {
  final String uuid;
  final String username;
  final String firstName;
  final String lastName;

  String get fullName => "$firstName $lastName";

  UserModel(this.uuid, this.username, this.firstName, this.lastName);

  String toJson() => json.encode({
    "uuid": uuid,
    "username": username,
    "firstName": firstName,
    "lastName": lastName,
  });

  factory UserModel.fromJson(String str) {
    Map<String, dynamic> map = json.decode(str);
    return UserModel(
      map["uuid"],
      map["username"],
      map["firstName"],
      map["lastName"],
    );
  }

  Future<bool> saveToStorage() => storagePref.setString("user", toJson());

  static UserModel? getProfile() {
    var data = storagePref.getString("user");
    if (data == null) return null;
    try {
      return UserModel.fromJson(data);
    } catch (_) {
      return null;
    }
  }
}
