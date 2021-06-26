import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:todo_flutter_app/global/jwtVerifyFunction.dart';
import 'package:todo_flutter_app/global/serverIp.dart' as globalConstants;
import 'package:todo_flutter_app/pages/login.dart';

// ignore: must_be_immutable
class AddTodo extends StatefulWidget {
  final String categoryId;
  late String initTitle;
  late String initDescription;
  late String todoIdEdit;
  late bool isEdit;
  AddTodo(this.categoryId, this.initTitle, this.initDescription, this.isEdit,
      this.todoIdEdit);
  // {Key? key} : super(key: key)
  @override
  _AddTodoState createState() =>
      _AddTodoState(categoryId, initTitle, initDescription, isEdit, todoIdEdit);
}

class _AddTodoState extends State<AddTodo> {
  bool error = false;
  bool _isLoading = false;
  late String categoryId;
  String initTitle;
  String initDescription;
  late String todoIdEdit;
  bool isEdit;
  var titleController;
  var descriptionController;
  var errorText = "";
  var responseBody;
  final _titleformKey = GlobalKey<FormState>();
  final _descriptionformKey = GlobalKey<FormState>();
  RegExp regExp = new RegExp(
    r"^[A-Za-z0-9]\w+$",
    multiLine: true,
  );

  _AddTodoState(this.categoryId, this.initTitle, this.initDescription,
      this.isEdit, this.todoIdEdit);

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: initTitle);
    descriptionController = TextEditingController(text: initDescription);
  }

  void addTodo() async {
    bool result = await validLogin();
    if (result) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute<void>(builder: (BuildContext context) => Login()),
          (route) => false);
    } else {
      try {
        var headers = await globalConstants.tokenRead();
        var url = Uri.parse('${globalConstants.severIp}/todos');
        var response = await http.post(url,
            headers: headers,
            body: jsonEncode({
              'categoryId': categoryId,
              'title': titleController.text,
              'description': descriptionController.text,
              'status': 'NC'
            }));
        setState(() {
          _isLoading = false;
        });
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

  Widget titleField(
      GlobalKey<FormState> key,
      int maxLines,
      int minLines,
      TextInputType type,
      TextEditingController controller,
      bool autofocus,
      String hintText) {
    return Padding(
        padding: EdgeInsets.all(20.0),
        child: Form(
          key: key,
          child: TextFormField(
            keyboardType: type,
            controller: controller,
            autofocus: autofocus,
            maxLines: maxLines,
            minLines: minLines,
            decoration: InputDecoration(
                contentPadding: EdgeInsets.all(20.0),
                suffixIcon: Icon(
                  Icons.add_task,
                  color: Colors.blue,
                ),
                hintText: hintText,
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
            content: Text("Dont Want to Add Todo?"),
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

  void editTodo() async {
    bool result = await validLogin();
    if (result) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute<void>(builder: (BuildContext context) => Login()),
          (route) => false);
    } else {
      try {
        var headers = await globalConstants.tokenRead();
        var url =
            Uri.parse('${globalConstants.severIp}/todos/edit/$todoIdEdit');
        var response = await http.put(url,
            headers: headers,
            body: jsonEncode({
              'title': titleController.text,
              'description': descriptionController.text
            }));
        setState(() {
          _isLoading = false;
        });
        responseBody = jsonDecode(response.body);
        if (responseBody['err'] != null) {
          throw HttpException("Server Error Occured");
        } else {
          Navigator.pop(context,
              [responseBody, titleController.text, descriptionController.text]);
        }
      } catch (err) {
        print(err);
        setState(() {
          error = true;
          errorText = "Server Error Please Try Again Later";
        });
      }
    }
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
              titleField(_titleformKey, 1, 1, TextInputType.text,
                  titleController, true, "Todo Title"),
              titleField(_descriptionformKey, 10, 1, TextInputType.multiline,
                  descriptionController, false, "Todo Description"),
              _isLoading
                  ? Container()
                  : ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isLoading = true;
                        });
                        descriptionController.text = descriptionController.text
                            .toString()
                            .replaceAll(
                                new RegExp(r'(?:[\t ]*(?:\r?\n|\r))+'), '\n');
                        descriptionController.text = descriptionController.text
                            .toString()
                            .trimLeft()
                            .trimRight();
                        print(descriptionController.text);
                        if (titleController.text == "" ||
                            descriptionController.text == "") {
                          setState(() {
                            _isLoading = false;
                            error = true;
                            errorText =
                                "Please Enter Todo Name and Todo Description to add it";
                          });
                        } else {
                          setState(() {
                            _isLoading = true;
                          });
                          isEdit ? editTodo() : addTodo();
                        }
                      },
                      child: Text(
                        isEdit ? "Done" : "Add Todo",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
              _isLoading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : Container(),
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
