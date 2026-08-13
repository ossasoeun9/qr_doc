import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_doc/core/app_navigator.dart';
import 'package:qr_doc/provider/document_detail_provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class QrDetailPage extends StatelessWidget {
  final String code;
  final bool isViewOnly;

  const QrDetailPage({super.key, required this.code, this.isViewOnly = false});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DocumentDetailProvider(code),
      builder: (context, _) {
        var provider = context.watch<DocumentDetailProvider>();
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () => context.goSafe("/"),
              icon: Icon(Icons.arrow_back),
            ),
          ),
          body: _body(provider),
          floatingActionButton: provider.document != null && !isViewOnly
              ? FilledButton(
                  onPressed: () {
                    context.goSafe(
                      "/doc-verify",
                      extra: {"code": code, "docId": provider.document?.uuid},
                    );
                  },
                  child: Text("ផ្ទៀងផ្ទាត់"),
                )
              : null,
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
