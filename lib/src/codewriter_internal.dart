library codewriter_internal;

import 'dart:io';
import 'dart:async' show Future;

part 'code_file.dart';
part 'expression.dart';

abstract class Textable {
  bool outCommented = false;
  String get text;
  String get code => outCommented? "/*" + text + "*/" : text;
}