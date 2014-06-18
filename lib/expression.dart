part of codewriter;

class Parameter extends Object with Textable{
  final String type;
  final String name;
  Parameter(this.name, {this.type: ""});
  List<String> get lines => ["$type $name".trim()];
}

abstract class OptionalParameter extends Parameter {
  final Object defaultValue;
  OptionalParameter(String name, {this.defaultValue, String type})
      : super(name, type: type);
}

class OptionalNamedParameter extends OptionalParameter {
  OptionalNamedParameter(String name, {Object defaultValue, String type})
      : super(name, defaultValue: defaultValue, type: type);
  List<String> get lines =>
      defaultValue == null? [name] : ["$name: $defaultValue"];
}

class OptionalPosParameter extends OptionalParameter {
  OptionalPosParameter(String name, {Object defaultValue, String type})
      : super(name, defaultValue: defaultValue, type: type);
  List<String> get lines =>
      defaultValue == null? [name] : ["$name = $defaultValue"];
}

abstract class Expression extends Object with Textable {
}

class FuncCall extends Expression {
  final String name;
  final List<Expression> positionalParameters;
  final Map<String, Expression> optionalParameters;
  FuncCall(this.name,
      [this.positionalParameters = const[], this.optionalParameters = const{}]);
  List<String> get _posParamLines => 
      Textable.listToLines(positionalParameters, 0);
  List<String> get _optParamLines {
    var result = [];
    optionalParameters.forEach((k, exp) => result.add("$k: ${exp.text}"));
    return result;
  }
  String get _allParamsString =>
      (_posParamLines..addAll(_optParamLines)).join(", ");
  List<String> get lines => ["$name($_allParamsString);"];
}

class UserExpression extends Expression {
  List<String> _lines;
  UserExpression(content) {
    content is List? _lines = content :
      content is String? _lines = [content] : throw "Illegal argument";
  }
  List<String> get lines => _lines;
}

class Declaration extends Object with Textable {
  final String type;
  final String name;
  final Expression calculation;
  Declaration(this.name, {this.type: "", this.calculation});
  String get _proto => "$type $name".trim();
  String get text => calculation == null ?
      "$_proto;" : "$_proto = ${calculation.text};";
  List<String> get lines => [text];
}

abstract class RawFunc extends Expression {
  final List<Parameter> parameters;
  final List<OptionalNamedParameter> optionalNamedParameters;
  final List<OptionalPosParameter> optionalPosParameters;
  RawFunc(this.parameters, this.optionalNamedParameters,
    this.optionalPosParameters) {
    if (optionalNamedParameters.length > 0 && optionalPosParameters.length > 0) {
      throw new ArgumentError("Cannot have positional and named optional parameters");
    }
  }
  String get _optNamedParamsString =>
      optionalNamedParameters.length > 0 ?
          "{" + optionalNamedParameters.map((param) => param.code).join(", ") + "}"
          : null;
  String get _optPosParamsString =>
      optionalPosParameters.length > 0 ?
          "[" + optionalPosParameters.map((param) => param.code).join(", ") + "]"
          : null;
  String get _paramsString =>
      parameters.length > 0 ?
          parameters.map((param) => param.code).join(", ") : null;
  
  List<String> _aggregateParameters() {
    var result = [];
    result..add(_paramsString)
          ..add(_optPosParamsString)
          ..add(_optNamedParamsString);
    result.removeWhere((elem) => elem == null);
    return result;
  }
  
  String get parameterString => "(" + _aggregateParameters().join(", ") + ")";
}

abstract class RegularFunction {
  List<Expression> _expressions = [];
  void addExpression(Expression e) => _expressions.add(e);
  List<String> get expressionLines => Textable.listToLines(_expressions, NTAB);
}

abstract class ShorthandFunction {
  Expression expression;
  List<String> get expressionLines => expression.indentedLines(LTAB);
}

abstract class RawAnonFunc extends RawFunc {
  RawAnonFunc(List<Parameter> parameters, 
    List<OptionalNamedParameter> optionalNamedParameters,
    List<OptionalPosParameter> optionalPosParameters)
      : super(parameters, optionalNamedParameters,
              optionalPosParameters);
}

class AnonFunc extends RawAnonFunc with RegularFunction {
  AnonFunc({List<Parameter> parameters: const[], 
      List<OptionalNamedParameter> optionalNamedParameters: const[],
      List<OptionalPosParameter> optionalPosParams: const[]})
        : super(parameters, optionalNamedParameters,
                optionalPosParams);
  List<String> get lines =>
      ["$parameterString {"]..addAll(expressionLines)..add("}");
}

class ShortAnonFunc extends RawAnonFunc with ShorthandFunction {
  ShortAnonFunc({List<Parameter> parameters: const[], 
        List<OptionalNamedParameter> optionalNamedParameters: const[],
        List<OptionalPosParameter> optionalPosParams: const[]})
          : super(parameters, optionalNamedParameters,
                  optionalPosParams);
  List<String> get lines =>
      ["$parameterString =>"]..addAll(expressionLines);
}

abstract class RawNamedFunc extends RawFunc {
  String name;
  String returnType;
  RawNamedFunc(this.name, this.returnType,
         List<Parameter> parameters, 
         List<OptionalNamedParameter> optionalNamedParameters,
         List<OptionalPosParameter> optionalPosParameters)
            : super(parameters, optionalNamedParameters,
                    optionalPosParameters);
  String get functionHead => "$returnType $name${super.parameterString}".trim();
}

class NamedFunc extends RawNamedFunc with RegularFunction {
  NamedFunc(String name, {String returnType: "",
            List<Parameter> parameters: const[], 
            List<OptionalNamedParameter> optionalNamedParameters: const[],
            List<OptionalPosParameter> optionalPosParameters: const[]})
              : super(name, returnType, parameters, optionalNamedParameters,
                      optionalPosParameters);
  List<String> get lines => ["$functionHead {"]..addAll(expressionLines)..add("}");
}

class ShortNamedFunc extends RawNamedFunc with ShorthandFunction {
  ShortNamedFunc(String name, {String returnType: "",
              List<Parameter> parameters: const[], 
              List<OptionalNamedParameter> optionalNamedParameters: const[],
              List<OptionalPosParameter> optionalPosParameters: const[]})
                : super(name, returnType, parameters,
                        optionalNamedParameters,
                        optionalPosParameters);
  List<String> get lines =>
      ["$functionHead =>"]..addAll(expressionLines);
}

abstract class Statement extends Expression {
  final List<Expression> body;
  Statement(this.body);
  List<String> get bodyLines => Textable.listToLines(body, NTAB);
}

abstract class ConditionalStatement extends Statement {
  final Expression condition;
  ConditionalStatement(this.condition, List<Expression> body)
      :super(body);
}

class IfStatement extends ConditionalStatement {
  final List<Expression> elseBody;
  IfStatement(Expression condition, List<Expression> body, {this.elseBody})
      :super(condition, body);
  List<String> get _ifPart =>
      ["if(${condition.text}) {"]..addAll(bodyLines)..add("}");
  List<String> get _elseBodyLines => Textable.listToLines(elseBody, NTAB);
  List<String> get lines {
    if(elseBody == null) return _ifPart;
    return _ifPart..add("else {")..addAll(_elseBodyLines)..add("}");
  }
}

class WhileStatement extends ConditionalStatement {
  WhileStatement(Expression condition, List<Expression> body)
      :super(condition, body);
  List<String> get lines =>
      ["while(${condition.text}) {"]
        ..addAll(Textable.listToLines(body, NTAB))..add("}");
}

class CodeClass extends Expression{
  String name;
  CodeClass extendedClass;
  final List<CodeClass> mixins;
  final List<Expression> members = [];
  CodeClass(this.name, {this.extendedClass, this.mixins});
  addMember(Expression member) => members.add(member);
  String get memberString => members.map((member) => "  " + member.text).join("\n");
  List<String> get lines => ["class $name {"]
    ..addAll(Textable.listToLines(members, NTAB))..add("}");
}
