import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:qr_doc/core/constants.dart';
import 'package:qr_doc/core/utils.dart';
import 'package:qr_doc/gen/assets.gen.dart';

import '../models/InvalidOptionModel.dart';
import '../models/user_model.dart';

Map<int, InvalidOptionModel> _invalidOption = InvalidOptions.optionAsMap;

class UserScanListPage extends StatelessWidget {
  const UserScanListPage({super.key});

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
                  onTap: () => context.go("/"),
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

              // 🔹 Group documents by date
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

              return ListView.builder(
                itemCount: sortedKeys.length,
                itemBuilder: (context, index) {
                  final dayKey = sortedKeys[index];
                  final items = grouped[dayKey]!;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🔹 Section header
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          _formatDateHeader(DateTime.parse(dayKey)),
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      // 🔹 Items in this group
                      ...items.map((doc) => _scanLogged(context, doc)),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go("/scan"),
        child: Icon(Icons.qr_code_scanner),
      ),
    );
  }

  Widget _scanLogged(BuildContext context, QueryDocumentSnapshot<Object?> doc) {
    final data = doc.data() as Map<String, dynamic>;
    final qrCodeContent = data["qrCodeContent"];
    final int? invalidOpt = data["invalidOpt"];
    final bool isCompliment = data["isCompliment"];
    final String note = data["note"] ?? "";
    final scannedAt = (data["scannedAt"] as Timestamp?)?.toDate();
    final scannedAtString = scannedAt != null
        ? DateFormat('hh:mm a').format(scannedAt)
        : 'N/A';

    var statusColor = isCompliment ? Colors.green : Colors.red;
    var status = isCompliment ? "ត្រឹមត្រូវ" : "មិនត្រឹមត្រូវ";

    return InkWell(
      onTap: () {
        context.go(
          "/doc/detail",
          extra: {"code": qrCodeContent ?? "", "isViewOnly": "1"},
        );
      },
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 18, vertical: 5),
        child: Padding(
          padding: EdgeInsetsGeometry.symmetric(horizontal: 10, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (qrCodeContent != null) ...{
                Row(
                  children: [
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: context.colorScheme.primary.withAlpha(50),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: EdgeInsetsGeometry.all(10),
                      child: Assets.icons.document.image(),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        qrCodeContent.toString(),
                        style: context.textTheme.titleMedium?.copyWith(
                          color: context.colorScheme.primaryFixed,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              },
              Row(
                children: [
                  Text(
                    "ស្ថានភាព",
                    style: context.textTheme.titleMedium?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                  Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(
                      color: statusColor.withAlpha(50),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status,
                      style: context.textTheme.labelLarge?.copyWith(
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (!isCompliment && invalidOpt != null) ...{
                Container(
                  alignment: Alignment.centerRight,
                  child: Text(
                    InvalidOptions.getOptionById(invalidOpt).title,
                    style: context.textTheme.labelLarge?.copyWith(
                      color: context.colorScheme.primaryFixed,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              },
              Row(
                children: [
                  Text(
                    "ពេលវេលាផ្ទៀងផ្ទាត់",
                    style: context.textTheme.titleMedium?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                  Spacer(),
                  Text(scannedAtString, style: context.textTheme.labelLarge),
                ],
              ),
              if (note.isNotEmpty == true) ...{
                const SizedBox(height: 10),
                RichText(
                  text: TextSpan(
                    text: "ចំណាំ៖ ",
                    style: context.textTheme.titleMedium?.copyWith(
                      color: Colors.grey,
                    ),
                    children: [
                      TextSpan(text: note, style: context.textTheme.labelLarge),
                    ],
                  ),
                ),
              },
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
