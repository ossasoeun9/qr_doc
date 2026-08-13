import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_doc/core/app_navigator.dart';
import 'package:qr_doc/core/constants.dart';
import 'package:qr_doc/core/utils.dart';
import 'package:qr_doc/gen/assets.gen.dart';

import '../models/user_model.dart';

final _iconOpts = {
  4: Assets.images.shopping,
  1: Assets.images.overflow,
  5: Assets.images.deliveryTruck,
  3: Assets.images.option,
};

class UserScanListPage extends StatefulWidget {
  const UserScanListPage({super.key});

  @override
  State<UserScanListPage> createState() => _UserScanListPageState();
}

class _UserScanListPageState extends State<UserScanListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(double.infinity, 80),
        child: Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: 1200),
            color: context.colorScheme.surface,
            padding: EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "QR DOC",
                      style: context.textTheme.titleLarge?.copyWith(
                        color: context.colorScheme.primary,
                      ),
                    ),
                    Text(
                      "សួស្តី, ${UserModel.getProfile()?.fullName ?? ""}!",
                      style: context.textTheme.labelLarge,
                    ),
                  ],
                ),
                InkWell(
                  onTap: () => context.goSafe("/"),
                  radius: 30,
                  child: Image.asset(
                    "assets/images/logo_cir.png",
                    height: 60,
                    width: 60,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 1180),
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("scannedList")
                .where(
                  "userId",
                  isEqualTo: FirebaseFirestore.instance
                      .collection('users')
                      .doc(UserModel.getProfile()?.uuid),
                )
                .orderBy("scannedAt", descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: SelectableText("Error ${snapshot.error}"));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data!.docs;

              if (docs.isEmpty) {
                return Center(
                  child: SizedBox(
                    width: 200,
                    height: 200,
                    child: Image.asset("assets/images/no_data.png"),
                  ),
                );
              }

              final Map<String, List<QueryDocumentSnapshot>> grouped = {};
              for (var doc in docs) {
                final data = doc.data() as Map<String, dynamic>;
                final scannedAt = (data["scannedAt"] as Timestamp?)?.toDate();

                final dayKey = scannedAt != null
                    ? DateFormat('yyyy-MM-dd').format(scannedAt)
                    : "Unknown";

                grouped.putIfAbsent(dayKey, () => []).add(doc);
              }

              final sortedKeys = grouped.keys.toList()
                ..sort((a, b) => b.compareTo(a)); // newest first

              return ScrollConfiguration(
                behavior: ScrollConfiguration.of(
                  context,
                ).copyWith(scrollbars: false),
                child: ListView.builder(
                  padding: EdgeInsets.all(18).copyWith(top: 0, bottom: 100),
                  itemCount: sortedKeys.length,
                  itemBuilder: (context, index) {
                    final dayKey = sortedKeys[index];
                    final items = grouped[dayKey]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 25,
                            vertical: 10,
                          ),
                          child: Text(
                            _formatDateHeader(DateTime.parse(dayKey)),
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        ...items.map((doc) => _scanLogged(context, doc)),
                      ],
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: "fab1",
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("ចេញ"),
                    content: const Text("តើអ្នកប្រាកដក្នុងការចាកចេញទេ?"),
                    actions: [
                      TextButton(
                        child: const Text("ទេ"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: const Text("បាទ/ចាស៎"),
                        onPressed: () {
                          Navigator.of(context).pop();
                          LoginManager.removeLogin();
                          context.goSafe("/");
                        },
                      ),
                    ],
                  );
                },
              );
            },
            child: Icon(Icons.logout_outlined),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: () => context.goSafe("/scan"),
            child: Icon(Icons.qr_code_scanner),
          ),
        ],
      ),
    );
  }

  Widget _scanLogged(BuildContext context, QueryDocumentSnapshot<Object?> doc) {
    final data = doc.data() as Map<String, dynamic>;
    final qrCodeContent = data["qrCodeContent"];
    final int? invalidOpt = data["invalidOpt"];
    final bool isCompliment = data["isCompliment"];
    final String userFullName = data["userFullName"] ?? "";
    final String note = data["note"] ?? "";
    final scannedAt = (data["scannedAt"] as Timestamp?)?.toDate();
    final scannedAtString = scannedAt != null
        ? DateFormat('dd MMM yyyy hh:mm a', "km")
              .format(scannedAt)
              .replaceFirst("a", "ព្រឹក")
              .replaceFirst("p", "ល្ងាច")
        : 'N/A';
    var statusColor = isCompliment ? Colors.green : Colors.red;
    var status = isCompliment ? "ត្រឹមត្រូវ" : "មិនត្រឹមត្រូវ";

    var complimentImage = isCompliment
        ? Assets.images.checklist
        : Assets.images.cancel;

    var iconOpt = _iconOpts[invalidOpt] ?? Assets.images.option;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 7.5),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: qrCodeContent != null
            ? () {
                context.goSafe(
                  "/doc-detail",
                  extra: {"code": qrCodeContent ?? "", "isViewOnly": "1"},
                );
              }
            : null,
        child: Container(
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(25),
                blurRadius: 10,
                spreadRadius: 1,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: CircleAvatar(
                  backgroundColor: statusColor.withAlpha(30),
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: complimentImage.image(color: statusColor),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (qrCodeContent != null) ...{
                      Text(qrCodeContent, style: context.textTheme.titleMedium),
                      SizedBox(height: 5),
                    },
                    Text(
                      status,
                      style: context.textTheme.titleMedium?.copyWith(
                        color: statusColor,
                      ),
                    ),
                    SizedBox(height: 5),
                    if (!isCompliment) ...{
                      Row(
                        children: [
                          SizedBox(
                            width: 25,
                            height: 25,
                            child: iconOpt.image(color: Colors.black),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            InvalidOptions.optionAsMap[invalidOpt]?.title ??
                                "ផ្សេងៗ",
                            style: context.textTheme.titleMedium?.copyWith(
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                    },
                    Text(
                      userFullName,
                      style: context.textTheme.titleMedium?.copyWith(
                        color: Colors.black54,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      scannedAtString,
                      style: context.textTheme.titleMedium?.copyWith(
                        color: Colors.black54,
                      ),
                    ),
                    SizedBox(height: 5),
                    if (note.isNotEmpty)
                      Text(
                        note,
                        style: context.textTheme.bodyLarge?.copyWith(
                          color: Colors.black54,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Helper: make section header more user friendly
  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));
    final target = DateTime(date.year, date.month, date.day);

    if (target == today) {
      return "ថ្ងៃនេះ";
    } else if (target == yesterday) {
      return "ម្សិលមិញ";
    } else {
      return DateFormat("dd MMM yyyy", "km").format(date);
    }
  }
}
