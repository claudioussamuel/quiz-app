import 'package:flutter/material.dart';
import 'generic_dialog.dart';

Future<void> showCantPayDialog(
  BuildContext context,
  String text,
) {
  return showGenericDialog(
    context: context,
    title: "Bill Payment",
    content: text,
    optionBulder: () => {
      "OK": null,
    },
  );
}
