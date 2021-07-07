import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:todo_flutter_app/global/jwtVerifyFunction.dart';
import 'package:todo_flutter_app/global/serverIp.dart' as globalConstants;
import 'package:todo_flutter_app/global/storage.dart' as globalStorage;
import 'package:todo_flutter_app/pages/login.dart';

class AddCategory extends StatefulWidget {
  const AddCategory({Key? key}) : super(key: key);

  @override
  _AddCategoryState createState() => _AddCategoryState();
}

class _AddCategoryState extends State<AddCategory> {
  final textController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool error = false;
  var errorText = "";
  var responseBody;
  bool _isLoading = false;
  bool _addCategory = true;
  late var groupId;

  void addCategory() async {
    setState(() {
      error = false;
      errorText = "";
    });
    bool result = await validLogin();
    if (result) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute<void>(builder: (BuildContext context) => Login()),
          (route) => false);
    } else {
      try {
        var headers = await globalConstants.tokenRead();
        var url = Uri.parse('${globalConstants.severIp}/category');
        var response = await http.post(url,
            headers: headers,
            body:
                jsonEncode({'text': textController.text, 'groupId': groupId}));
        responseBody = jsonDecode(response.body);
        Navigator.pop(context, [responseBody['_id'], responseBody['text']]);
      } catch (err) {
        setState(() {
          error = true;
          errorText = "Server Error Please Try Again Later";
        });
        print(err);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getGroupCredentials();
  }

  // TODO: Add Check Whether Is it Logged in Or not and then call storage.readAll()

  void getGroupCredentials() async {
    var result = await globalStorage.storage.readAll();
    groupId = result['groupId'];
    setState(() {});
  }

  Widget categoryField() {
    return Padding(
        padding: EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: TextFormField(
            keyboardType: TextInputType.text,
            controller: textController,
            // autofocus: true,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.all(20.0),
              suffixIcon: Icon(
                Icons.add_task,
                color: Colors.deepPurple.shade400,
              ),
              hintText: "Category Name",
              hintStyle: TextStyle(color: Colors.deepPurple.shade400),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide(
                      color: Colors.deepPurple.shade400, width: 2.0)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide(
                      color: Colors.deepPurple.shade400, width: 2.0)),
              disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide(
                      color: Colors.deepPurple.shade400, width: 2.0)),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide(
                      color: Colors.deepPurple.shade400, width: 1.0)),
              errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide(color: Colors.red, width: 2.0)),
              errorStyle:
                  TextStyle(fontSize: 15.0, fontWeight: FontWeight.w500),
            ),
            validator: (value) {
              setState(() {
                error = true;
                errorText = "Please Enter Category Name to Add Category";
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
            title: Text('Are you sure?'),
            content: Text("You dont want to Add Category ?"),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text("Add Category"),
      //   actions: [],
      // ),
      body: Stack(
        children: <Widget>[
          Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("images/login_singup_background.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
              child: null),
          Center(
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(15.0),
              ),
              width: 340,
              height: 200,
              child: WillPopScope(
                onWillPop: _onBackPressed,
                child: Column(
                  children: <Widget>[
                    categoryField(),
                    _addCategory
                        ? ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                primary: Colors.deepPurpleAccent.shade100,
                                padding: EdgeInsets.fromLTRB(30, 10, 30, 10),
                                elevation: 10.0),
                            onPressed: () {
                              setState(() {
                                _isLoading = true;
                              });
                              // print(textController.text);
                              if (textController.text == "") {
                                setState(() {
                                  _isLoading = false;
                                  error = true;
                                  errorText =
                                      "Please Enter Category Name to Add Category";
                                });
                              } else {
                                setState(() {
                                  _addCategory = false;
                                });
                                addCategory();
                              }
                            },
                            child: Text("Add Category"),
                          )
                        : Container(),
                    _isLoading
                        ? Center(child: CircularProgressIndicator())
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
          ),
        ],
      ),
    );
  }
}
