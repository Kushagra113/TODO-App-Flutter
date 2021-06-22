import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:todo_flutter_app/blueprint/todo.dart';
import 'package:todo_flutter_app/global/jwtVerifyFunction.dart';
import 'package:todo_flutter_app/pages/addTodo.dart';
import 'package:todo_flutter_app/global/serverIp.dart' as globalConstants;
import 'package:todo_flutter_app/pages/login.dart';

class EachCategory extends StatefulWidget {
  late final String id;
  late final String category;
  EachCategory(this.id, this.category);
//  {Key? key}     : super(key: key);
  @override
  _EachCategoryState createState() => _EachCategoryState(id, category);
}

class _EachCategoryState extends State<EachCategory> {
  late final String categoryId;
  late final String category;
  bool _isLoading = false;
  bool _getAllTodos = false;
  final TextStyle fontSize = TextStyle(fontSize: 17);
  static ScrollController _controller = ScrollController();
  late var result;
  _EachCategoryState(this.categoryId, this.category);
  List<TodoBlueprint> todos = [];
  bool pressedCompleted = false;
  bool pressedNotCompleted = true;

  void addTodo() async {
    result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddTodo(categoryId),
        ));
    setState(() {
      todos.add(TodoBlueprint(
          id: result[0],
          categoryId: categoryId,
          todoTitle: result[2],
          todoDescription: result[3],
          todoStatus: result[4]));
    });
  }

  void markAsNotComplete(String id) async {
    await http.put(Uri.parse("${globalConstants.severIp}/todos/Markcomplete"),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'todoId': id, 'categoryId': categoryId}));
  }

  void getNotCompletedTodos(String id) async {
    await http.put(
        Uri.parse("${globalConstants.severIp}/todos/Marknotcomplete"),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'todoId': id, 'categoryId': categoryId}));
  }

  Future<void> getTodos(String url) async {
    var result = await http.post(Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'categoryId': categoryId}));
    var allTodos = jsonDecode(result.body);
    todos.removeRange(0, todos.length);
    // print(allTodos);
    allTodos.forEach((todo) => {
          todos.add(TodoBlueprint(
              id: todo['_id'],
              categoryId: todo['categoryId'],
              todoTitle: todo['title'],
              todoDescription: todo['description'],
              todoStatus: todo['status']))
        });
    setState(() {
      _getAllTodos = true;
    });
  }

  void checkLogin() async {
    bool result = await validLogin();
    if (result) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute<void>(builder: (BuildContext context) => Login()),
          (route) => false);
    }
  }

  @override
  void initState() {
    super.initState();
    checkLogin();
    if (this.mounted) {
      getTodos("${globalConstants.severIp}/todos/Notcompleted");
    }
  }

  Widget data(element) {
    return GestureDetector(
        onTap: () {},
        child: Card(
          color: element.todoStatus == "NC"
              ? Colors.yellow.shade700
              : Colors.greenAccent.shade400,
          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          element.todoTitle,
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(2, 15, 10, 10),
                      child: Text(
                        element.todoDescription,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        TextButton(
                            onPressed: () {
                              todos.remove(element);
                              element.todoStatus == "NC"
                                  ? markAsNotComplete(element.id)
                                  : getNotCompletedTodos(element.id);
                              setState(() {});
                            },
                            child: element.todoStatus == "NC"
                                ? Text(
                                    "Mark As Complete",
                                    style: TextStyle(fontSize: 15),
                                  )
                                : Text("Mark As Not Complete"))
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("Todos Of Category $category")),
      ),
      body: RefreshIndicator(
        onRefresh: () => pressedCompleted
            ? getTodos("${globalConstants.severIp}/todos/completed")
            : getTodos("${globalConstants.severIp}/todos/Notcompleted"),
        child: SingleChildScrollView(
          controller: _controller,
          physics: AlwaysScrollableScrollPhysics(),
          child: Container(
              // : Center(child: CircularProgressIndicator()),
              child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 15, 20, 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    OutlinedButton(
                      onPressed: () {
                        setState(() {
                          pressedCompleted = false;
                          pressedNotCompleted = true;
                        });
                        getTodos(
                            "${globalConstants.severIp}/todos/Notcompleted");
                      },
                      style: ButtonStyle(backgroundColor:
                          MaterialStateProperty.resolveWith<Color>((states) {
                        if (pressedNotCompleted) {
                          return Colors.grey.shade300;
                        }
                        return Colors.transparent;
                      })),
                      child: Text("Not Completed", style: fontSize),
                    ),
                    OutlinedButton(
                        onPressed: () {
                          setState(() {
                            pressedCompleted = true;
                            pressedNotCompleted = false;
                          });
                          getTodos(
                              "${globalConstants.severIp}/todos/completed");
                        },
                        style: ButtonStyle(backgroundColor:
                            MaterialStateProperty.resolveWith<Color>((states) {
                          if (pressedCompleted) {
                            return Colors.grey.shade300;
                          }
                          return Colors.transparent;
                        })),
                        child: Text("Completed", style: fontSize)),
                  ],
                ),
              ),
              SizedBox(
                height: 15,
              ),
              _getAllTodos
                  ? ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: _isLoading ? todos.length : todos.length,
                      itemBuilder: (context, index) {
                        if (todos.length == index) {
                          return Center(child: CircularProgressIndicator());
                        }
                        // print(todos);
                        return data(todos[index]);
                        // return categories[index];
                      },
                    )
                  : CircularProgressIndicator(),
              _getAllTodos
                  ? Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FloatingActionButton(
                          onPressed: () {
                            addTodo();
                          },
                          child: Icon(Icons.add),
                        ),
                      ))
                  : Container(),
            ],
          )),
        ),
      ),
    );
  }
}
