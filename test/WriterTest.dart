import 'package:unittest/unittest.dart';
import '../lib/codewriter.dart';

main() {
  test("Expression generation", () {
    var e = new Expression.raw("my rawExpression");
    expect(e.code, equals("my rawExpression"));
    e.outCommented = true;
    expect(e.code, equals("/*my rawExpression*/"));
  });
  
  test("Test function generation", () {
    var shortFunc = new ShortNamedFunc("datfunc", returnType: "String",
        parameters: [new Parameter("foo")])..e = new Expression.raw("\"wat\"");
    print(shortFunc.code);
    expect(shortFunc.code, equals("String datfunc(foo) => \"wat\";"));
    var longFunc = new NamedFunc("myFunc", returnType: "Future",
        optionalNamedParameters: [new OptionalNamedParameter("myParam", defaultValue: "0")]);
    print(longFunc.code);
  });
  
  test("File generation", () {
    var rImp = new Import.raw("rawImport.dart");
    expect(rImp.code, equals("import 'rawImport.dart';"));
    var lib = new LibraryFile("mylib.dart", "mylib");
    lib.addImport(new Import("io"));
    var myClass = new CodeClass("test");
    lib.addContent(myClass);
    print(lib);
    lib.writeToFile();
  });
}