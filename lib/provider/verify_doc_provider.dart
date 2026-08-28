import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/user_model.dart';

class VerifyDocProvider extends ChangeNotifier {
  VerifyDocProvider(this.docId, this.qrCodeContent);
  final CollectionReference _docsRef = FirebaseFirestore.instance.collection(
    'documents',
  );
  final String docId;
  final String qrCodeContent;
  final noteCtr = TextEditingController();
  bool _isCompliment = true;
  bool get isCompliment => _isCompliment;

  void setIsCompliment(bool v) {
    if (v == isCompliment) return;
    if (v) {
      _invalidOptId = null;
    } else {
      _invalidOptId = 3;
    }
    _isCompliment = v;
    notifyListeners();
  }

  int? _invalidOptId;
  int? get invalidOptId => _invalidOptId;

  void setInvalidOpt(int v) {
    if (v == invalidOptId) return;
    _invalidOptId = v;
    notifyListeners();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final _scannedListRef = FirebaseFirestore.instance.collection("scannedList");
  final _userRef = FirebaseFirestore.instance.collection("users");
  void addScannedData({
    required void Function() onSuccess,
    required void Function() onError,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();
      var user = UserModel.getProfile();
      var checkpointData = await user?.checkpoint?.get();
      var checkpointName = checkpointData?.data()?["name"];
      var userDoc = _userRef.doc(user?.uuid);
      _scannedListRef
          .add({
            "userId": userDoc,
            "userFullName": user?.fullName ?? "",
            "docId": _docsRef.doc(docId),
            "isCompliment": isCompliment,
            "qrCodeContent": qrCodeContent,
            if (checkpointName != null) "checkpointName": checkpointName,
            if (user?.checkpoint != null) "checkpoint": user?.checkpoint,
            if (invalidOptId != null) "invalidOpt": invalidOptId,
            if (noteCtr.text.isNotEmpty) "note": noteCtr.text,
            "scannedAt": FieldValue.serverTimestamp(),
          })
          .then((v) async {
            _isLoading = false;
            notifyListeners();
            onSuccess();
            try {
              if (checkpointData != null) {
                var data = checkpointData.data();
                data!["latestScannedAt"] = FieldValue.serverTimestamp();
                user?.checkpoint?.set(data);
              }
              var userData = await userDoc.get();
              var uData = userData.data() as Map<String, dynamic>;
              uData["latestScannedAt"] = FieldValue.serverTimestamp();
              userDoc.set(uData);
            } catch (e) {
              onError();
              print("eeee: $e");
            }
          })
          .catchError((e) {
            _isLoading = false;
            notifyListeners();
            onError();
          });
    } catch (e) {
      print("eeee: $e");
      onError();
    }
  }
}
