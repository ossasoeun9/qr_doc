import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_doc/core/constants.dart';

class _VerifyDocProvider extends ChangeNotifier {
  final noteCtr = TextEditingController();
  bool _isCompliment = true;

  bool get isCompliment => _isCompliment;

  void setIsCompliment(bool v) {
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
    _invalidOptId = v;
    notifyListeners();
  }
}

void showVerifyDocDialog(
  BuildContext context,
  void Function(bool, int?, String) onSubmit,
) {
  const invalidOpts = InvalidOptions.options;
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return ChangeNotifierProvider<_VerifyDocProvider>(
        create: (context) => _VerifyDocProvider(),
        builder: (context, _) {
          var provider = context.watch<_VerifyDocProvider>();
          return AlertDialog(
            title: Text("ផ្ទៀងផ្ទាត់ឯកសារ"),
            content: Container(
              constraints: BoxConstraints(maxWidth: 600),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _optChoice(
                    () {
                      provider.setIsCompliment(true);
                    },
                    "ត្រឹមត្រូវ",
                    provider.isCompliment,
                  ),
                  _optChoice(
                    () {
                      provider.setIsCompliment(false);
                    },
                    "មិនត្រឹមត្រូវ",
                    !provider.isCompliment,
                  ),
                  if (!provider.isCompliment) ...{
                    Divider(),
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
                    Divider(),
                  },
                  TextField(
                    controller: provider.noteCtr,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(labelText: "ចំណាំ"),
                  ),
                ],
              ),
            ),
            actions: [
              FilledButton(
                onPressed: () => onSubmit(
                  provider.isCompliment,
                  provider.invalidOptId,
                  provider.noteCtr.text.trim(),
                ),
                child: Text("រួចរាល់"),
              ),
            ],
          );
        },
      );
    },
  );
}

Widget _optChoice(void Function() onTap, String label, bool isCheck) {
  return InkWell(
    splashColor: Colors.transparent,
    onTap: onTap,
    child: Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(5),
          child: Icon(
            isCheck ? Icons.radio_button_checked : Icons.radio_button_off,
          ),
        ),
        const SizedBox(width: 10),
        Text(label),
      ],
    ),
  );
}
