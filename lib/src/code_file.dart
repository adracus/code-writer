part of codewriter_internal;

class Import {
  String namespace;
  String path;
  Import(this.namespace, [this.path="dart"]);
  toString() => 'import "$namespace:$path";';
}

abstract class CodeFile {
  final String name;
  List<Object> _content = [];
  CodeFile(this.name);
  addContent(Object element) => _content.add(element);
  toString() => _content.map((elem) => elem.toString()).join("\n");
  Future writeToFile([String location = ""]) {
    var f = new File(location + name);
    var sink = f.openWrite();
    sink.write(this.toString());
    return sink.flush().whenComplete(() => sink.close());
  }
}

class StandardFile extends CodeFile {
  List<Import> _imports = [];
  StandardFile(String name)
      : super(name);
  void addImport(Import import) => _imports.add(import);
  String get importString => _imports.map((import) => import.toString()).join("\n");
  toString() => importString + "\n\n" + super.toString();
}

class LibraryFile extends StandardFile {
  final String libraryName;
  List<String> parts = [];
  LibraryFile(String name, this.libraryName)
      : super(name);
  String get partString => parts.map((part) => "part '$part';").join("\n");
  toString() => "library $libraryName;\n$partString\n${super.toString()}";
}

class LibraryPartFile extends CodeFile {
  String parentLibrary;
  LibraryPartFile(String name, this.parentLibrary)
      : super(name);
  toString() => "part of $parentLibrary;\n\n${super.toString()}";
}