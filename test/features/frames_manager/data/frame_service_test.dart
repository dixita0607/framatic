import 'package:flutter_test/flutter_test.dart';
import 'package:framatic/core/errors/app_error.dart';
import 'package:framatic/features/frames_manager/data/frame_service.dart';

void main() {
  test('constructor surfaces an unopened database as a domain error', () {
    expect(() => FrameService(), throwsA(isA<DatabaseError>()));
  });
}
