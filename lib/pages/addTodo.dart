import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:todo_flutter_app/global/jwtVerifyFunction.dart';
import 'package:todo_flutter_app/global/serverIp.dart' as globalConstants;
import 'package:todo_flutter_app/pages/login.dart';

class AddTodo extends StatefulWidget {
  final String categoryId;
  AddTodo(this.categoryId);
  // {Key? key} : super(key: key)
  @override
  _AddTodoState createState() => _AddTodoState(categoryId);
}

class _AddTodoState extends State<AddTodo> {
  bool error = false;
  late String categoryId;
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  var errorText = "";
  var responseBody;
  final _titleformKey = GlobalKey<FormState>();
  final _descriptionformKey = GlobalKey<FormState>();

  _AddTodoState(this.categoryId);

  void addTodo() async {
    bool result = await validLogin();
    if (result) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute<void>(builder: (BuildContext context) => Login()),
          (route) => false);
    } else {
      try {
        var url = Uri.parse('${globalConstants.severIp}/todos');
        var response = await http.post(url,
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'categoryId': categoryId,
              'title': titleController.text,
              'description': descriptionController.text,
              'status': 'NC'
            }));
        responseBody = jsonDecode(response.body);
        Navigator.pop(context, [
          responseBody['_id'],
          responseBody['categoryId'],
          responseBody['title'],
          responseBody['description'],
          responseBody['status']
        ]);
      } catch (err) {
        setState(() {
          error = true;
          errorText = "Server Error Please Try Again Later";
        });
        print(err);
      }
    }
  }

  Widget titleField() {
    return Padding(
        padding: EdgeInsets.all(20.0),
        child: Form(
          key: _titleformKey,
          child: TextFormField(
            keyboardType: TextInputType.text,
            controller: titleController,
            autofocus: true,
            decoration: InputDecoration(
                contentPadding: EdgeInsets.all(20.0),
                suffixIcon: Icon(
                  Icons.add_task,
                  color: Colors.blue,
                ),
                hintText: "Todo Title",
                hintStyle: TextStyle(color: Colors.blue[300]),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: BorderSide(color: Colors.blue)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: BorderSide(color: Colors.blue)),
                errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: BorderSide(color: Colors.red, width: 2.0)),
                disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: BorderSide(color: Colors.blue, width: 2.0)),
                errorStyle: TextStyle(fontSize: 15.0)),
            validator: (value) {
              setState(() {
                error = true;
                errorText = "Please Enter Todo Name to add a Todo";
              });
            },
          ),
        ));
  }

  Future<bool> _onBackPressed() async {
    var result = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Are you sure You want to Go Back?'),
            content: Text("You dont want to Add Todo For This Category"),
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
    return result;
  }

  Widget descriptionField() {
    return Padding(
        padding: EdgeInsets.all(20.0),
        child: Form(
          key: _descriptionformKey,
          child: TextFormField(
            keyboardType: TextInputType.text,
            controller: descriptionController,
            autofocus: true,
            maxLines: 6,
            decoration: InputDecoration(
                contentPadding: EdgeInsets.all(20.0),
                suffixIcon: Icon(
                  Icons.add_task,
                  color: Colors.blue,
                ),
                hintText: "Todo Description",
                hintStyle: TextStyle(color: Colors.blue[300]),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: BorderSide(color: Colors.blue)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: BorderSide(color: Colors.blue)),
                errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: BorderSide(color: Colors.red, width: 2.0)),
                disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: BorderSide(color: Colors.blue, width: 2.0)),
                errorStyle: TextStyle(fontSize: 15.0)),
            validator: (value) {
              setState(() {
                error = true;
                errorText = "Please Enter Todo Name to add a Todo";
              });
            },
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(""),
      ),
      body: WillPopScope(
        onWillPop: _onBackPressed,
        child: Center(
          child: Column(
            children: <Widget>[
              titleField(),
              descriptionField(),
              ElevatedButton(
                onPressed: () {
                  // print(textController.text);
                  if (titleController.text == "" ||
                      descriptionController.text == "") {
                    setState(() {
                      error = true;
                      errorText =
                          "Please Enter Todo Name and Todo Description to add it";
                    });
                  } else {
                    addTodo();
                  }
                },
                child: Text(
                  "Add Todo",
                  style: TextStyle(fontSize: 18),
                ),
              ),
              error
                  ? Text(
                      errorText,
                      style: TextStyle(color: Colors.red.shade900),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
