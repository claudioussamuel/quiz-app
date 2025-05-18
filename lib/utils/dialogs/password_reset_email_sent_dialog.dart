import 'package:flutter/widgets.dart';
import '/utils/dialogs/generic_dialog.dart';

Future<void> showPasswordResetSentDialog(BuildContext context) {
  return showGenericDialog(
      context: context,
      title: "Password Reset",
      content:
          "We have now sent you a password reset link. Please check your email for more information",
      optionBulder: () => {
            "Ok": null,
          });
}
