import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class _VerifyDocProvider extends ChangeNotifier {
  final noteCtr = TextEditingController();
  bool _isCompliment = true;

  bool get isCompliment => _isCompliment;

  void setIsCompliment(bool v) {
    if (v) {
      _invalidOpt = null;
    } else {
      _invalidOpt = 3;
    }
    _isCompliment = v;
    notifyListeners();
  }

  int? _invalidOpt;

  int? get invalidOpt => _invalidOpt;

  void setInvalidOpt(int v) {
    _invalidOpt = v;
    notifyListeners();
  }
}

void showVerifyDocDialog(
  BuildContext context,
  void Function(bool, int?, String) onSubmit,
) {
  const invalidOpts = [
    "Invalid date",
    "Invalid quantiy",
    "Invalid location",
    "Other",
  ];
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return ChangeNotifierProvider<_VerifyDocProvider>(
        create: (context) => _VerifyDocProvider(),
        builder: (context, _) {
          var provider = context.watch<_VerifyDocProvider>();
          return AlertDialog(
            title: Text("Verify Document"),
            content: Container(
              constraints: BoxConstraints(maxWidth: 600),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _optChoice(
                    () {
                      provider.setIsCompliment(true);
                    },
                    "Compliment",
                    provider.isCompliment,
                  ),
                  _optChoice(
                    () {
                      provider.setIsCompliment(false);
                    },
                    "Non-compliment",
                    !provider.isCompliment,
                  ),
                  if (!provider.isCompliment) ...{
                    Divider(),
                    ...List.generate(invalidOpts.length, (index) {
                      return _optChoice(
                        () {
                          provider.setInvalidOpt(index);
                        },
                        invalidOpts[index],
                        index == provider.invalidOpt,
                      );
                    }),
                    Divider(),
                  },
                  TextField(
                    controller: provider.noteCtr,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(labelText: "Note"),
                  ),
                ],
              ),
            ),
            actions: [
              FilledButton(
                onPressed: () => onSubmit(
                  provider.isCompliment,
                  provider.invalidOpt,
                  provider.noteCtr.text.trim(),
                ),
                child: Text("Done"),
              ),
            ],
          );
        },
      );
    },
  );
}

Widget _optChoice(void Function() onTap, String label, bool isCheck) {
  return Row(
    children: [
      Padding(
        padding: const EdgeInsets.all(5),
        child: InkWell(
          onTap: onTap,
          child: Icon(
            isCheck ? Icons.radio_button_checked : Icons.radio_button_off,
          ),
        ),
      ),
      const SizedBox(width: 10),
      Text(label),
    ],
  );
}
