part of codewriter_internal;

class Parameter extends Object with Textable{
  final String type;
  final String name;
  Parameter(this.name, {this.type: ""});
  String get text => "$type $name".trim();
}

abstract class OptionalParameter extends Parameter {
  final Object defaultValue;
  OptionalParameter(String name, {this.defaultValue, String type})
      : super(name, type: type);
}

class OptionalNamedParameter extends OptionalParameter {
  OptionalNamedParameter(String name, {Object defaultValue, String type})
      : super(name, defaultValue: defaultValue, type: type);
  String get text =>
      defaultValue == null? "$name" : "$name: $defaultValue";
}

class OptionalPosParameter extends OptionalParameter {
  OptionalPosParameter(String name, {Object defaultValue, String type})
      : super(name, defaultValue: defaultValue, type: type);
  String get text =>
      defaultValue == null? "$name" : "$name = $defaultValue";
}

class Expression extends Object with Textable {
  final String str;
  Expression() : str = "";
  Expression.raw(this.str);
  String get text => str;
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
    result..add(_optNamedParamsString)
          ..add(_optPosParamsString)
          ..add(_paramsString);
    result.removeWhere((elem) => elem == null);
    return result;
  }
  
  String get parameterString => "(" + _aggregateParameters().join(", ") + ")";
}

abstract class RegularFunction {
  List<Expression> _expressions = [];
  void addExpression(Expression e) => _expressions.add(e);
  String get expressionString =>
      _expressions.map((e) => e.text + ";").join("\n");
  String get body => "{\n${expressionString}\n}";
}

abstract class ShorthandFunction {
  Expression e;
  String get expressionString => e.text + ";";
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
  String get text => super.parameterString + " =>\n    " + body;
}

class ShortAnonFunc extends RawAnonFunc with ShorthandFunction {
  ShortAnonFunc({List<Parameter> parameters: const[], 
        List<OptionalNamedParameter> optionalNamedParameters: const[],
        List<OptionalPosParameter> optionalPosParams: const[]})
          : super(parameters, optionalNamedParameters,
                  optionalPosParams);
  String get text => super.parameterString + " => " + expressionString;
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
  String get text => super.functionHead + body;
}

class ShortNamedFunc extends RawNamedFunc with ShorthandFunction {
  ShortNamedFunc(String name, {String returnType: "",
              List<Parameter> parameters: const[], 
              List<OptionalNamedParameter> optionalNamedParameters: const[],
              List<OptionalPosParameter> optionalPosParameters: const[]})
                : super(name, returnType, parameters,
                        optionalNamedParameters,
                        optionalPosParameters);
  String get text => super.functionHead + " => " + expressionString;
}

class CodeClass extends Expression{
  String name;
  CodeClass extendedClass;
  final List<CodeClass> mixins;
  final List<Expression> members = [];
  CodeClass(this.name, {this.extendedClass, this.mixins});
  addMember(Expression member) => members.add(member);
  String get memberString => members.map((member) => "  " + member.text).join("\n");
  String get text => "class $name {\n$memberString\n}";
}
