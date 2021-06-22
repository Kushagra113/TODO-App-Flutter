import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:todo_flutter_app/global/jwtVerifyFunction.dart';
import 'package:todo_flutter_app/global/serverIp.dart' as globalConstants;
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
        var url = Uri.parse('${globalConstants.severIp}/category');
        var response = await http.post(url,
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'text': textController.text}));
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

  Widget categoryField() {
    return Padding(
        padding: EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: TextFormField(
            keyboardType: TextInputType.text,
            controller: textController,
            autofocus: true,
            decoration: InputDecoration(
                contentPadding: EdgeInsets.all(20.0),
                suffixIcon: Icon(
                  Icons.add_task,
                  color: Colors.blue,
                ),
                hintText: "Category Name",
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
            content: Text("You dont want to Add Category"),
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
      appBar: AppBar(
        title: Text("Add Category"),
        actions: [],
      ),
      body: WillPopScope(
        onWillPop: _onBackPressed,
        child: Column(
          children: <Widget>[
            categoryField(),
            ElevatedButton(
              onPressed: () {
                // print(textController.text);
                if (textController.text == "") {
                  setState(() {
                    error = true;
                    errorText = "Please Enter Category Name to Add Category";
                  });
                } else {
                  addCategory();
                }
              },
              child: Text("Add Category"),
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
    );
  }
}
