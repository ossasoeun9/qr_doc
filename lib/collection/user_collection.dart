import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_doc/models/user_model.dart';

class UserCollection {
  final collection = FirebaseFirestore.instance
      .collection("users")
      .withConverter<UserModel>(
        fromFirestore: (doc, opt) {
          var data = doc.data();
          return UserModel(
            doc.id,
            data?["username"] ?? "",
            data?["firstName"] ?? "",
            data?["lastName"] ?? "",
            data?["checkpoint"],
          );
        },
        toFirestore: (user, opt) {
          return {
            "username": user.username,
            "firstName": user.firstName,
            "lastName": user.lastName,
          };
        },
      );

  Future<UserModel?> login(String username, String password) async {
    try {
      var res = await collection
          .where(
            Filter.and(
              Filter("username", isEqualTo: username),
              Filter("password", isEqualTo: password),
            ),
          )
          .get();
      return res.docs.firstOrNull?.data();
    } catch (_) {
      rethrow;
    }
  }
}
