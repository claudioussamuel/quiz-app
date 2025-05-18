import 'package:flutter/material.dart';
import '/utils/dialogs/generic_dialog.dart';

Future<bool> showVerifyEmailDialog(BuildContext context, String details) {
  return showGenericDialog(
    context: context,
    title: "Is this You?",
    content: details,
    optionBulder: () => {
      "No": false,
      "Yes": true,
    },
  ).then(
    (value) => value ?? false,
  );
}
