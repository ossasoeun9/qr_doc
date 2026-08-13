import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_doc/core/app_navigator.dart';
import 'package:qr_doc/core/utils.dart';

import '../../core/constants.dart';
import '../../provider/verify_doc_provider.dart';

class VerifyDocPage extends StatefulWidget {
  final String docId;
  final String qrCodeContent;
  const VerifyDocPage({
    super.key,
    required this.docId,
    required this.qrCodeContent,
  });

  @override
  State<VerifyDocPage> createState() => _VerifyDocPageState();
}

class _VerifyDocPageState extends State<VerifyDocPage> {
  final invalidOpts = InvalidOptions.options;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.goSafe("/"),
          icon: Icon(Icons.arrow_back),
        ),
        title: Text("ផ្ទៀងផ្ទាត់ឯកសារ"),
      ),
      body: ChangeNotifierProvider<VerifyDocProvider>(
        create: (context) =>
            VerifyDocProvider(widget.docId, widget.qrCodeContent),
        builder: (context, _) {
          var provider = context.watch<VerifyDocProvider>();

          if (provider.docId.isEmpty) {
            return Center(
              child: SizedBox(
                width: 200,
                height: 200,
                child: Image.asset("assets/images/no_data.png"),
              ),
            );
          }

          return Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: 600),
              child: ListView(
                padding: EdgeInsets.all(20),
                children: [
                  _optChoice(
                    () {
                      provider.setIsCompliment(true);
                    },
                    "ត្រឹមត្រូវ",
                    provider.isCompliment,
                    isTitle: true,
                    color: Colors.green,
                  ),
                  _optChoice(
                    () {
                      provider.setIsCompliment(false);
                    },
                    "មិនត្រឹមត្រូវ",
                    !provider.isCompliment,
                    isTitle: true,
                    color: Colors.redAccent,
                  ),
                  if (!provider.isCompliment) ...{
                    Divider(indent: 45, color: Colors.black12),
                    ...List.generate(invalidOpts.length, (index) {
                      var opt = invalidOpts[index];
                      return _optChoice(
                        () {
                          provider.setInvalidOpt(opt.id);
                        },
                        opt.title,
                        opt.id == provider.invalidOptId,
                      );
                    }),
                  },
                  Divider(indent: 45, color: Colors.black12),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(left: 45),
                    child: Text(
                      "ចំណាំ",
                      style: context.textTheme.titleMedium?.copyWith(
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 5, left: 35),
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: provider.noteCtr,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                      style: context.textTheme.bodyMedium,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        labelStyle: TextStyle(color: Colors.black54),
                        hint: Text(
                          "សរសេរបន្ថែមនៅទីនេះ...",
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: Colors.black54,
                          ),
                        ),
                      ),
                      minLines: 1,
                      maxLines: 10,
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      width: 150,
                      height: 40,
                      child: FilledButton.tonal(
                        onPressed: () => provider.addScannedData(
                          onSuccess: () => context.goSafe("/"),
                          onError: () => context.showErrorMessage(),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (provider.isLoading) ...{
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: context.colorScheme.onPrimary,
                                  strokeWidth: 2.5,
                                ),
                              ),
                              const SizedBox(width: 10),
                            } else
                              const SizedBox(width: 30),
                            const Text("រួចរាល់"),
                            const SizedBox(width: 30),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _optChoice(
    void Function() onTap,
    String label,
    bool isCheck, {
    bool isTitle = false,
    Color? color,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(5),
      splashColor: Colors.transparent,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(5),
              child: Icon(
                isCheck ? Icons.radio_button_checked : Icons.radio_button_off,
                color: color ?? (isCheck ? Colors.red : Colors.black54),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: context.textTheme.titleMedium?.copyWith(
                color: color ?? (isCheck ? Colors.red : Colors.black54),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
