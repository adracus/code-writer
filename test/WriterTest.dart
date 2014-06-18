import 'package:unittest/unittest.dart';
import '../lib/codewriter.dart';

main() {
  test("Expression generation", () {
    var e = new UserExpression("my rawExpression");
    expect(e.code, equals("my rawExpression"));
    e.outCommented = true;
    expect(e.code, equals("/*my rawExpression*/"));
  });
  
  test("Test function generation", () {
    var shortFunc = new ShortNamedFunc("datfunc", returnType: "String",
        parameters: [new Parameter("foo")])..expression = new UserExpression('"wat\";');
    expect(shortFunc.code, equals("String datfunc(foo) =>\n    \"wat\";"));
    var longFunc = new NamedFunc("myFunc", returnType: "Future",
        optionalNamedParameters: [new OptionalNamedParameter("myParam", defaultValue: "0")]);
    expect(longFunc.code, equals("Future myFunc({myParam: 0}) {\n}"));
  });
  
  test("Test statement generation", () {
    var bodyStmnt = new Declaration("watanga", type: "int");
    var ifStmnt = new IfStatement(new UserExpression("1==1"), [bodyStmnt]);
    expect(ifStmnt.code, equals("if(1==1) {\n  int watanga;\n}"));
  });
  
  test("Test class generation", () {
    var clazz = new CodeClass("MyClass");
    var bodyStmnt = new Declaration("watanga", type: "int");
    var ifStmnt = new IfStatement(new UserExpression("1==1"), [bodyStmnt]);
    clazz.addMember(ifStmnt);
    expect(clazz.code, equals("class MyClass {\n  if(1==1) {\n    int watanga;\n" +
                              "  }\n}"));
  });
  
  test("Test function call generation", () {
    var funcCall = new FuncCall("myFunc",
        [new UserExpression("1 + 1")], {"body": new UserExpression("true")});
    print(funcCall.code);
    expect(funcCall.code, equals("myFunc(1 + 1, body: true);"));
  });
  
  test("File generation", () {
    var rImp = new Import.raw("rawImport.dart");
    expect(rImp.code, equals("import 'rawImport.dart';"));
    var lib = new LibraryFile("mylib.dart", "mylib");
    lib.addImport(new Import("io"));
    var myClass = new CodeClass("Test");
    lib.addContent(myClass);
    lib.writeToFile();
  });
}