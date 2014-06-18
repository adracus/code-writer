library codewriter;

import 'dart:io';
import 'dart:async' show Future;

part 'code_file.dart';
part 'expression.dart';

var NTAB = 2;
var LTAB = NTAB * 2;

abstract class Textable {
  bool outCommented = false;
  String get text => lines.join("\n");
  List<String> get lines;
  List<String> indentedLines(int indent) => indentLines(lines, indent);
  String get code => outCommented? "/*" + text + "*/" : text;
  static List<String> listToLines(List<Textable> textables, int indent) =>
      textables.length == 0 ? [] :
      indentLines(textables.map((e) => e.lines)
          .reduce((e1, e2) => e1..addAll(e2)), indent); 
  static List<String> indentLines(List<String> lines, int indent) =>
      indent < 0 ?
          throw "Indent can't be < 0" :
            lines.map((line) => " " * indent + line).toList(growable: true);
}