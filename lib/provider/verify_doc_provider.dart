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
  void addScannedData({required void Function() onSuccess, required void Function() onError}) {
    _isLoading = true;
    notifyListeners();
    _scannedListRef.add({
      "userId": _userRef.doc(UserModel.getProfile()!.uuid),
      "userFullName": UserModel.getProfile()?.fullName ?? "",
      "docId": _docsRef.doc(docId),
      "isCompliment": isCompliment,
      "qrCodeContent": qrCodeContent,
      if (invalidOptId != null) "invalidOpt": invalidOptId,
      if (noteCtr.text.isNotEmpty) "note": noteCtr.text,
      "scannedAt": Timestamp.now(),
    }).then((v) {
      _isLoading = false;
      notifyListeners();
      onSuccess();
    }).catchError((e) {
      _isLoading = false;
      notifyListeners();
      onError();
    });
  }
}
