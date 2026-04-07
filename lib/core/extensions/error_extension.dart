import 'package:flutter/material.dart';
import 'package:framatic/core/errors/app_error.dart';

extension ErrorSnackBar on BuildContext {
  void showErrorSnackBar(AppError error) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(content: Text(error.userMessage)),
    );
  }
}
