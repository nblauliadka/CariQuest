// lib/shared/utils/ui_helpers.dart

import 'package:flutter/material.dart';

abstract class UiHelpers {
  /// Show standard Error SnackBar
  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  /// Show standard Success SnackBar
  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: const Color(0xFF22C55E), // success
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  /// Remove focus from TextField
  static void hideKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }
}
