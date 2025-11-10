import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:qr_doc/core/utils.dart';
import 'package:qr_doc/pages/qr_detail/dialog/verify_doc_dialog.dart';
import 'package:qr_doc/provider/document_detail_provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../models/user_model.dart';

class QrDetailPage extends StatelessWidget {
  final String code;

  const QrDetailPage({super.key, required this.code});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DocumentDetailProvider(code),
      builder: (context, _) {
        var provider = context.watch<DocumentDetailProvider>();
        var user = UserModel.getProfile();
        return Scaffold(
          appBar: PreferredSize(
            preferredSize: Size(double.infinity, 80),
            child: Container(
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
                        "Hello, ${user?.firstName}!",
                        style: context.textTheme.labelLarge,
                      ),
                    ],
                  ),
                  Image.asset(
                    "assets/images/logo_cir.png",
                    height: 60,
                    width: 60,
                  ),
                ],
              ),
            ),
          ),
          body: _body(provider),
          floatingActionButton: provider.document != null
              ? FilledButton(
                  onPressed: () {
                    showVerifyDocDialog(context, (v1, v2, v3) {
                      Navigator.of(context).pop();
                      showLoadingDialog(context);
                      var f = provider
                          .addScannedData(v1, v2, v3)
                          ?.then((_) {
                            hideLoadingDialog(context);
                            context.go("/");
                          })
                          .catchError((_) {
                            hideLoadingDialog(context);
                          });
                      if (f == null) {
                        hideLoadingDialog(context);
                      }
                    });
                  },
                  child: Text("Verify"),
                )
              : FloatingActionButton(
                  onPressed: () => context.go("/"),
                  child: Icon(Icons.home),
                ),
        );
      },
    );
  }

  Widget _body(DocumentDetailProvider provider) {
    if (provider.error.isNotEmpty) {
      return Center(child: Text("Error: ${provider.error}"));
    }
    if (provider.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (provider.document == null) {
      return Center(
        child: SizedBox(
          width: 200,
          height: 200,
          child: Image.asset("assets/images/no_data.png"),
        ),
      );
    }
    return SfPdfViewer.network(provider.document?.fileUrl ?? "");
  }
}
