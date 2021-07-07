class TodoBlueprint {
  late String id;
  late String groupId;
  late String categoryId;
  late String todoTitle;
  late String todoDescription;
  late String todoStatus;

  TodoBlueprint(
      {required this.id,
      required this.groupId,
      required this.categoryId,
      required this.todoTitle,
      required this.todoDescription,
      required this.todoStatus});
}
