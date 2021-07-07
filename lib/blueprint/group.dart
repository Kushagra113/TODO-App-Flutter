class Group {
  late String id;
  late String name;
  Group();
  void idSetter(String id) {
    this.id = id;
  }

  void nameSetter(String name) {
    this.id = name;
  }

  String getterId() {
    return this.id;
  }

  String getterName() {
    return this.name;
  }
}
