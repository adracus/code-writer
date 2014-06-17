part of codewriter_internal;

class Import extends Object with Textable{
  final String namespace;
  final String name;
  final List<String> show;
  final String as;
  final bool _raw;
  
  Import(this.name, {this.namespace: "dart", this.show, this.as}): _raw = false;
  Import.raw(this.name) : _raw = true, namespace = "", as = null, show = null;
  
  String get text {
    if(_raw) return "import '$name';";
    var result = "import \"$namespace:$name\"";
    if(as != null) result += " as $as";
    if(show != null) result += " show ${show.join(", ")}";
    return result += ";";
  }
}

abstract class CodeFile extends Object with Textable{
  final String name;
  List _content = [];
  CodeFile(this.name);
  addContent(element) => _content.add(element);
  String get text => _content.map((elem) =>
      elem is Expression? elem.code : elem.toString()).join("\n");
  Future writeToFile([String location = ""]) {
    var f = new File(location + name);
    var sink = f.openWrite();
    sink.write(this.text);
    return sink.flush().whenComplete(() => sink.close());
  }
}

class StandardFile extends CodeFile {
  final List<Import> _imports = [];
  StandardFile(String name)
      : super(name);
  void addImport(Import import) => _imports.add(import);
  String get importString => _imports.map((import) => import.text).join("\n");
  String get text => importString + "\n\n" + super.text;
}

class LibraryFile extends StandardFile {
  final String libraryName;
  List<String> _parts = [];
  LibraryFile(String name, this.libraryName)
      : super(name);
  addPart(String part) => _parts.add(part);
  String get partString => _parts.map((part) => "part '$part';").join("\n");
  String get text => "library $libraryName;\n$partString\n${super.text}";
}

class LibraryPartFile extends CodeFile {
  final String parentLibrary;
  LibraryPartFile(String name, this.parentLibrary)
      : super(name);
  String get text => "part of $parentLibrary;\n\n${super.text}";
}