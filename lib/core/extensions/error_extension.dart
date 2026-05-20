import 'package:flutter/widgets.dart';
import 'package:framatic/core/errors/app_error.dart';
import 'package:framatic/core/sketch_ui/sketch_ui.dart';

extension ErrorToast on BuildContext {
  void showErrorToast(AppError error) {
    SketchToast.show(this, error.userMessage, isError: true);
  }
}
