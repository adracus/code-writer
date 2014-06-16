import 'package:unittest/unittest.dart';
import '../lib/codewriter.dart';

main() {
  test("Test funcion generation", () {
    print(new ShortNamedFunc("datfunc", returnType: "String",
        parameters: [new Parameter("foo")])..e = new Expression.raw("\"wat\""));
    var lib = new LibraryFile("mylib.dart", "mylib");
    lib.addImport(new Import("io"));
    var myClass = new CodeClass("test");
    lib.addContent(myClass);
    print(lib);
    lib.writeToFile();
  });
}