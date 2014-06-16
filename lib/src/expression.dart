part of codewriter_internal;

class Parameter {
  final String type;
  final String name;
  Parameter(this.name, {this.type: ""});
  toString() => "$type $name".trim();
}

class Expression {
  final String str;
  Expression() : str = "";
  Expression.raw(this.str);
  toString() => str;
}

abstract class RawFunc extends Expression {
  final List<Parameter> parameters;
  RawFunc(this.parameters);
  String get proto => "(${parameters.join(", ")})";
  toString() => "RawFunc $proto";
}

abstract class RegularFunction {
  List<Expression> _expressions = [];
  void addExpression(Expression e) => _expressions.add(e);
  String get expressionString =>
      _expressions.map((e) => e.toString() + ";").join("\n");
  String get body => "{\n${expressionString}\n}";
}

abstract class ShorthandFunction {
  Expression e;
  String get expressionString => e.toString() + ";";
}

abstract class RawAnonFunc extends RawFunc {
  RawAnonFunc(List<Parameter> parameters): super(parameters);
}

class AnonFunc extends RawAnonFunc with RegularFunction {
  AnonFunc({List<Parameter> parameters: const[]}): super(parameters);
  toString() => super.proto + " => " + body;
}

class ShortAnonFunc extends RawAnonFunc with ShorthandFunction {
  ShortAnonFunc({List<Parameter> parameters: const[]}): super(parameters);
  toString() => super.proto + " => " + expressionString;
}

abstract class RawNamedFunc extends RawFunc {
  String name;
  String returnType;
  RawNamedFunc(this.name, this.returnType, List<Parameter> parameters)
      : super(parameters);
  String get proto => "$returnType $name${super.proto}".trim();
}

class NamedFunc extends RawNamedFunc with RegularFunction {
  NamedFunc(String name, {String returnType: "", List<Parameter> parameters: const[]})
      : super(name, returnType, parameters);
  toString() => super.proto + body;
}

class ShortNamedFunc extends RawNamedFunc with ShorthandFunction {
  ShortNamedFunc(String name, {String returnType: "", List<Parameter> parameters: const[]})
      : super(name, returnType, parameters);
  toString() => super.proto + " => " + expressionString;
}

class CodeClass extends Expression{
  String name;
  List<Expression> members = [];
  CodeClass(this.name);
  addMember(Expression member) => members.add(member);
  String get memberString => members.map((member) => "  " + member.toString()).join("\n");
  toString() => "class $name {\n$memberString\n}";
}
