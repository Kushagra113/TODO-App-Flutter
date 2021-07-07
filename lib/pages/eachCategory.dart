import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:todo_flutter_app/blueprint/todo.dart';
import 'package:todo_flutter_app/global/jwtVerifyFunction.dart';
import 'package:todo_flutter_app/pages/addTodo.dart';
import 'package:todo_flutter_app/global/serverIp.dart' as globalConstants;
import 'package:todo_flutter_app/pages/login.dart';
import 'package:todo_flutter_app/global/storage.dart' as globalStorage;

class EachCategory extends StatefulWidget {
  late final String id;
  late final String category;
  late final int nc;
  late final int c;
  EachCategory(this.id, this.category, this.c, this.nc);
//  {Key? key}     : super(key: key);
  @override
  _EachCategoryState createState() => _EachCategoryState(id, category, nc, c);
}

class _EachCategoryState extends State<EachCategory> {
  late final String categoryId;
  late final String category;
  late int nc;
  late int c;
  bool _isLoading = true;
  final TextStyle fontSize = TextStyle(fontSize: 17);
  static ScrollController _controller = ScrollController();
  late var result;
  List<TodoBlueprint> notCompletedTodos = [];
  List<TodoBlueprint> completedTodos = [];
  bool pressedCompleted = false;
  bool pressedNotCompleted = true;
  bool viewMore = false;
  bool addButton = false;
  late int skipComplete;
  late int limitComplete;
  late int skipNotComplete;
  late int limitNotComplete;
  bool completeFirst = true;
  bool groupSet = false;
  late var groupCredentials;

  _EachCategoryState(this.categoryId, this.category, this.nc, this.c);

  void addTodo() async {
    result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddTodo(categoryId, "", "", false, ""),
        ));
    if (result != null) {
      setState(() {
        notCompletedTodos.add(TodoBlueprint(
            id: result[0],
            groupId: "HardCode GroupId",
            categoryId: categoryId,
            todoTitle: result[2],
            todoDescription: result[3],
            todoStatus: result[4]));
      });
    }
  }

  void markAsNotComplete(String id) async {
    var headers = await globalConstants.tokenRead();
    await http.put(
        Uri.parse("${globalConstants.severIp}/todos/Marknotcomplete"),
        headers: headers,
        body: jsonEncode({'todoId': id, 'categoryId': categoryId}));
  }

  void markAsComplete(String id) async {
    var headers = await globalConstants.tokenRead();
    await http.put(Uri.parse("${globalConstants.severIp}/todos/Markcomplete"),
        headers: headers,
        body: jsonEncode({'todoId': id, 'categoryId': categoryId}));
  }

  Future<void> getCompletedTodos(String url, int limit, int skip) async {
    var headers = await globalConstants.tokenRead();
    var result = await http.post(Uri.parse(url),
        headers: headers,
        body: jsonEncode(
            {'categoryId': categoryId, 'limit': limit, 'skip': skip}));
    var allTodos = jsonDecode(result.body);
    if (!viewMore) {
      completedTodos.removeRange(0, completedTodos.length);
    } else {}
    allTodos.forEach((todo) => {
          completedTodos.add(TodoBlueprint(
              id: todo['_id'],
              groupId: "HardCode GroupId",
              categoryId: todo['categoryId'],
              todoTitle: todo['title'],
              todoDescription: todo['description'],
              todoStatus: todo['status']))
        });
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> getNotCompeletedTodos(String url, int limit, int skip) async {
    var headers = await globalConstants.tokenRead();
    var result = await http.post(Uri.parse(url),
        headers: headers,
        body: jsonEncode(
            {'categoryId': categoryId, 'limit': limit, 'skip': skip}));
    var allTodos = jsonDecode(result.body);
    if (!viewMore) {
      notCompletedTodos.removeRange(0, notCompletedTodos.length);
    } else {}
    allTodos.forEach((todo) => {
          notCompletedTodos.add(TodoBlueprint(
              id: todo['_id'],
              groupId: "HardCode GroupId",
              categoryId: todo['categoryId'],
              todoTitle: todo['title'],
              todoDescription: todo['description'],
              todoStatus: todo['status']))
        });
    setState(() {
      viewMore = false;
      _isLoading = false;
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

  void getGroupCredentials() async {
    var result = await globalStorage.storage.readAll();
    groupCredentials = [result['groupId'], result['groupName']];
    setState(() {
      groupSet = true;
    });
  }

  @override
  void initState() {
    super.initState();
    checkLogin();
    getGroupCredentials();
    setState(() {
      skipNotComplete = 4;
      limitNotComplete = notCompletedTodos.length;
    });
    if (this.mounted) {
      getNotCompeletedTodos("${globalConstants.severIp}/todos/Notcompleted",
              skipNotComplete, limitNotComplete)
          .then((value) => {
                if (notCompletedTodos.length >= nc)
                  {
                    setState(() {
                      addButton = true;
                    })
                  }
              });
    }
  }

  void _editTodo(TodoBlueprint todo) async {
    var result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddTodo(todo.categoryId, todo.todoTitle,
              todo.todoDescription, true, todo.id),
        ));
    setState(() {
      notCompletedTodos.remove(todo);
      notCompletedTodos.add(TodoBlueprint(
          id: todo.id,
          groupId: "HardCode GroupId",
          categoryId: categoryId,
          todoTitle: result[1],
          todoDescription: result[2],
          todoStatus: todo.todoStatus));
    });
  }

  void _deleteTodo(TodoBlueprint todo) async {
    var result = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Are you sure?'),
            content: Text("You Want to Delete Todo ${todo.todoTitle} ?"),
            actions: <Widget>[
              TextButton(
                child: Text('NO'),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              TextButton(
                child: Text('YES'),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          );
        });
    if (result != null) {
      if (result) {
        var headers = await globalConstants.tokenRead();
        var deleteRequest = await http.delete(
            Uri.parse("${globalConstants.severIp}/todos/delete/${todo.id}"),
            headers: headers);
        if (jsonDecode(deleteRequest.body)['success'] != null) {
          todo.todoStatus == "NC" ? nc -= 1 : c -= 1;
          final snackBar = SnackBar(
            content: Text(
              'Deletion Of ${todo.todoTitle} Successfull',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          );
          setState(() {
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
            if (todo.todoStatus == "NC") {
              notCompletedTodos.remove(todo);
              nc -= 1;
            } else {
              completedTodos.remove(todo);
              c -= 1;
            }
          });
        }
      }
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
          child: Padding(
            padding: const EdgeInsets.fromLTRB(5, 2, 0, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 5, 5, 0),
                      child: Text(
                        element.todoTitle,
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    IconButton(
                        onPressed: () {
                          _deleteTodo(element);
                        },
                        icon: Icon(
                          Icons.delete,
                          color: Colors.black54,
                        ))
                  ],
                ),
                Divider(
                  color: Colors.blueGrey.shade600,
                  endIndent: 10,
                  height: 1,
                  indent: 10,
                  thickness: 1,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 5, 10),
                  child: Text(
                    element.todoDescription,
                    style: TextStyle(fontSize: 17),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    TextButton(
                        onPressed: () {
                          _editTodo(element);
                        },
                        child: element.todoStatus == "NC"
                            ? Text(
                                "Edit",
                                style: TextStyle(fontSize: 15),
                              )
                            : Container()),
                    TextButton(
                        onPressed: () {
                          if (element.todoStatus == "NC") {
                            notCompletedTodos.remove(element);
                            markAsComplete(element.id);
                            nc -= 1;
                            c += 1;
                          } else {
                            completedTodos.remove(element);
                            markAsNotComplete(element.id);
                            c -= 1;
                            nc += 1;
                          }
                          setState(() {});
                        },
                        child: element.todoStatus == "NC"
                            ? Text(
                                "Mark As Complete",
                                style: TextStyle(fontSize: 15),
                              )
                            : Text("Mark As Not Complete")),
                  ],
                )
              ],
            ),
          ),
        ));
  }

  Widget viewMoreButton() {
    return Container(
        margin: EdgeInsets.fromLTRB(40, 5, 40, 5),
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            fixedSize: Size.fromWidth(10.0),
          ),
          onPressed: () {
            setState(() {
              viewMore = true;
              if (pressedCompleted) {
                limitComplete = 4;
                skipComplete = completedTodos.length;
              } else {
                limitNotComplete = 4;
                skipNotComplete = notCompletedTodos.length;
              }
            });
            pressedNotCompleted
                ? getNotCompeletedTodos(
                        "${globalConstants.severIp}/todos/Notcompleted",
                        limitNotComplete,
                        skipNotComplete)
                    .then((value) => {
                          if (notCompletedTodos.length >= nc)
                            {
                              setState(() {
                                viewMore = false;
                                addButton = true;
                              })
                            }
                        })
                : getCompletedTodos(
                        "${globalConstants.severIp}/todos/completed",
                        limitComplete,
                        skipComplete)
                    .then((value) => {
                          print("hi"),
                          if (completedTodos.length >= c)
                            {
                              setState(() {
                                viewMore = false;
                              })
                            }
                        });
          },
          child: Text(
            "View More",
            style: TextStyle(fontSize: 20),
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("$category")),
      ),
      body: RefreshIndicator(
        onRefresh: () {
          setState(() {
            skipComplete = 0;
            skipNotComplete = 0;
            limitComplete = completedTodos.length;
            limitNotComplete = notCompletedTodos.length;
          });
          return pressedCompleted
              ? getCompletedTodos("${globalConstants.severIp}/todos/completed",
                  limitComplete, skipComplete)
              : getNotCompeletedTodos(
                  "${globalConstants.severIp}/todos/Notcompleted",
                  limitNotComplete,
                  skipNotComplete);
        },
        child: Container(
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
                            _isLoading = true;
                            limitNotComplete = notCompletedTodos.length;
                            skipNotComplete = 0;
                          });
                          getNotCompeletedTodos(
                              "${globalConstants.severIp}/todos/Notcompleted",
                              limitNotComplete,
                              skipNotComplete);
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
                              _isLoading = true;
                              limitComplete =
                                  completeFirst ? 4 : completedTodos.length;
                              skipComplete = 0;
                              completeFirst = false;
                            });
                            print(limitComplete);
                            print(skipComplete);
                            getCompletedTodos(
                                "${globalConstants.severIp}/todos/completed",
                                limitComplete,
                                skipComplete);
                          },
                          style: ButtonStyle(backgroundColor:
                              MaterialStateProperty.resolveWith<Color>(
                                  (states) {
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
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: pressedCompleted
                            ? completedTodos.length + 1
                            : notCompletedTodos.length + 1,
                        itemBuilder: (context, index) {
                          if (pressedCompleted
                              ? completedTodos.length == index
                              : notCompletedTodos.length == index) {
                            return pressedNotCompleted
                                ? notCompletedTodos.length < nc
                                    ? viewMoreButton()
                                    : Container()
                                : completedTodos.length < c
                                    ? viewMoreButton()
                                    : Container();
                          }
                          return pressedCompleted
                              ? data(completedTodos[index])
                              : data(notCompletedTodos[index]);
                        },
                      ),
                _isLoading
                    ? Container()
                    : pressedNotCompleted
                        ? addButton
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
                            : Container()
                        : Container()
              ],
            )),
          ),
        ),
      ),
    );
  }
}
