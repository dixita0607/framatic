import 'package:framatic/models/frame.dart';

abstract class DBTypes {
  static const String integer = 'INTEGER';
  static const String real = 'REAL';
  static const String text = 'TEXT';
  static const String blob = 'BLOB';
}

abstract class DBSchemaValues {
  static const String fileName = 'framatic.db';
  static const String dbName = 'Framatic';
  static const int dbVersion = 1;
  static const String framesTable = FramesTable.name;
}
