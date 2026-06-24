import 'package:flutter_test/flutter_test.dart';
import 'package:framatic/core/utils/constants.dart';

void main() {
  test('keeps user-visible app name and frame border values stable', () {
    expect(AppConstants.appName, 'Framatic');
    expect(AppConstants.frameBorderRatio, 0.04);
    expect(AppConstants.maxFrameBorderShortSideRatio, 0.08);
  });
}
