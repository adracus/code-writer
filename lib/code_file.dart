part of codewriter;

class Import extends Object with Textable{
  final String namespace;
  final String name;
  final List<String> show;
  final String as;
  final bool _raw;
  
  Import(this.name, {this.namespace: "dart", this.show, this.as}): _raw = false;
  Import.raw(this.name) : _raw = true, namespace = "", as = null, show = null;
  
  List<String> get lines {
    if(_raw) return ["import '$name';"];
    var result = "import \"$namespace:$name\"";
    if(as != null) result += " as $as";
    if(show != null) result += " show ${show.join(", ")}";
    return ["$result;"];
  }
}

abstract class CodeFile extends Object with Textable{
  final String name;
  List<Expression> _content = [];
  CodeFile(this.name);
  addContent(Expression element) => _content.add(element);
  List<String> get lines =>
      Textable.listToLines(_content, 0);
  Future writeToFile([String location = ""]) {
    var f = new File(location + name);
    var sink = f.openWrite();
    String content = this.text;
    sink.write(this.text);
    return sink.flush().whenComplete(() => sink.close());
  }
}

class StandardFile extends CodeFile {
  final List<Import> _imports = [];
  StandardFile(String name)
      : super(name);
  void addImport(Import import) => _imports.add(import);
  List<String> get importLines => Textable.listToLines(_imports, 0);
  List<String> get lines => importLines..add("")..add("")..addAll(super.lines);
}

class LibraryFile extends StandardFile {
  final String libraryName;
  List<String> _parts = [];
  LibraryFile(String name, this.libraryName)
      : super(name);
  addPart(String part) => _parts.add(part);
  List<String> get partLines => _parts.map((part) =>
      "part '$part';").toList(growable:true);
  String get partString => _parts.map((part) => "part '$part';").join("\n");
  List<String> get lines =>
      ["library $libraryName;"]..addAll(partLines)..addAll(super.lines);
}

class LibraryPartFile extends CodeFile {
  final String parentLibrary;
  LibraryPartFile(String name, this.parentLibrary)
      : super(name);
  List<String> get lines =>
      ["part of $parentLibrary;"]..add("")..add("")..addAll(super.lines);
}