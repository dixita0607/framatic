import 'package:flutter/widgets.dart';
import 'package:framatic/core/errors/app_error.dart';
import 'package:sketchy_design_lang/sketchy_design_lang.dart';

extension ErrorSnackBar on BuildContext {
  void showErrorSnackBar(AppError error) {
    SketchySnackBar.show(this, message: error.userMessage);
  }
}
