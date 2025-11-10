import 'package:cloud_firestore/cloud_firestore.dart';

class DocumentModel {
  final String uuid;
  final String qrCodeContent;
  final String fileUrl;
  final Timestamp? createdAt;

  DocumentModel(this.uuid, this.qrCodeContent, this.fileUrl, this.createdAt);

  factory DocumentModel.fromMap(String uuid, Map<String, dynamic> map) =>
      DocumentModel(
        uuid,
        map["qrCodeContent"] ?? "",
        map["fileUrl"] ?? "",
        map["createdAt"],
      );
}
