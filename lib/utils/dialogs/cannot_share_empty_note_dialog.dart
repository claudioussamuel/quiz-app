import 'package:flutter/material.dart';
import 'generic_dialog.dart';

Future<void> showCannotShareEpmtyNoteDialog(BuildContext context) {
  return showGenericDialog<void>(
    context: context,
    title: "Sharing",
    content: "You cannot share an empty note!",
    optionBulder: () => {
      "OK": null,
    },
  );
}
