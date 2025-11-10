import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:qr_doc/models/document_model.dart';

import '../models/user_model.dart';

class DocumentDetailProvider extends ChangeNotifier {
  DocumentDetailProvider(this._code) {
    _getDocument();
  }
  final String _code;
  final CollectionReference _docsRef = FirebaseFirestore.instance.collection(
    'documents',
  );

  DocumentModel? _document;
  DocumentModel? get document => _document;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _error = "";
  String get error => _error;

  void _getDocument() async {
    _isLoading = true;
    notifyListeners();
    try {
      var res = await _docsRef.where("qrCodeContent", isEqualTo: _code).get();
      var doc = res.docs.firstOrNull;
      if (doc != null) {
        _document = DocumentModel.fromMap(
          doc.id,
          doc.data() as Map<String, dynamic>,
        );
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = "Error: $e";
      _isLoading = false;
      notifyListeners();
    }
  }

  final _scannedListRef = FirebaseFirestore.instance.collection("scannedList");
  final _userRef = FirebaseFirestore.instance.collection("users");
  Future? addScannedData(bool isCompliment, int? invalidOpt, String note) {
    if (document == null) return null;
    return _scannedListRef.add({
      "userId": _userRef.doc(UserModel.getProfile()!.uuid),
      "userFullName": UserModel.getProfile()?.fullName ?? "",
      "docId": _docsRef.doc(document!.uuid),
      "isCompliment": isCompliment,
      if (invalidOpt != null) "invalidOpt": invalidOpt,
      if (note.isNotEmpty) "note": note,
      "scannedAt": Timestamp.now(),
    });
  }
}
