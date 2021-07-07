import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:http/http.dart' as http;
import 'package:todo_flutter_app/global/serverIp.dart' as globalConstants;

class SingupPage extends StatefulWidget {
  const SingupPage({Key? key}) : super(key: key);

  @override
  _SingupPageState createState() => _SingupPageState();
}

class _SingupPageState extends State<SingupPage> {
  final groupName = new TextEditingController();
  final groupEmails = new TextEditingController();
  final _nameKey = GlobalKey<FormState>();
  final _mailKey = GlobalKey<FormState>();
  late String nameError;
  bool nameErrorField = false;
  bool isLoading = false;
  bool emailErrorField = false;
  bool serverError = false;
  bool singupbutton = true;
  String serverErrorText = "";
  late String emailError;
  int invalidEmailCount = 0;
  var result;
  List<String> sendEmails = [];

  Widget nameField() {
    return Form(
      key: _nameKey,
      child: TextFormField(
        controller: groupName,
        decoration: InputDecoration(
          fillColor: Colors.black,
          hintText: "Group Name",
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.0),
              borderSide:
                  BorderSide(color: Colors.deepPurple.shade400, width: 2.0)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.0),
              borderSide:
                  BorderSide(color: Colors.deepPurple.shade400, width: 2.0)),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.0),
              borderSide:
                  BorderSide(color: Colors.deepPurple.shade400, width: 1.0)),
          errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.0),
              borderSide: BorderSide(color: Colors.red, width: 2.0)),
          errorText: nameErrorField ? nameError : null,
          errorStyle: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w500),
          errorMaxLines: 3,
        ),
        validator: (value) {
          // groupName.text = value.toString().trimLeft().trimRight();
          if (value == "") {
            setState(() {
              nameErrorField = true;
              nameError = "Please Enter a Name for the Group";
            });
            return "Please Enter a Name for the Group";
          } else if (value.toString().length < 3 ||
              value.toString().length > 15) {
            return "Group Name Should be between 3 to 15 characters";
          }
          setState(() {
            nameErrorField = false;
          });
        },
        onChanged: (value) {
          if (value == " ") {
          } else {
            setState(() {
              nameErrorField = false;
            });
          }
        },
      ),
    );
  }

  Widget emailsField() {
    return Form(
      key: _mailKey,
      child: TextFormField(
        keyboardType: TextInputType.multiline,
        controller: groupEmails,
        maxLines: 6,
        decoration: InputDecoration(
            errorMaxLines: 3,
            fillColor: Colors.black,
            hintText: "Group Emails",
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.0),
                borderSide:
                    BorderSide(color: Colors.deepPurple.shade400, width: 2.0)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.0),
                borderSide:
                    BorderSide(color: Colors.deepPurple.shade400, width: 2.0)),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.0),
                borderSide:
                    BorderSide(color: Colors.deepPurple.shade400, width: 2.0)),
            errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.0),
                borderSide: BorderSide(color: Colors.red, width: 2.0)),
            errorText: emailErrorField ? emailError : null,
            errorStyle: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w500)),
        validator: (value) {
          if (value == "") {
            setState(() {
              emailErrorField = true;
              emailError = "Please Enter Email Address To Add";
            });
            return "Please Enter Email Address To Add";
          } else {
            invalidEmailCount = 0;

            result = value.toString().split(",");
            if (result.length > 5) {
              setState(() {
                emailErrorField = true;
                emailError =
                    "You Cannot Add More Than 5 Email Addresses For A Group";
              });
              return "You Cannot Add More Than 5 Email Addresses For A Group";
            } else if (result.length > 0) {
              sendEmails = [];
              result.forEach((element) {
                element = element.toString().trimLeft().trimRight();
                sendEmails.add(element);
                if (!EmailValidator.validate(element)) {
                  invalidEmailCount += 1;
                }
              });
              print(sendEmails);
              if (invalidEmailCount == 0) {
                return null;
              } else {
                setState(() {
                  emailErrorField = true;
                  emailError =
                      "Out of ${result.length} , $invalidEmailCount Email Address are Invalid";
                });
                return "Out of ${result.length} , $invalidEmailCount Email Address are Invalid";
              }
            }
          }
        },
      ),
    );
  }

  Widget singupButton() {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
            primary: Colors.deepPurpleAccent.shade100,
            padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
            elevation: 10.0),
        onPressed: () async {
          try {
            setState(() {
              serverError = false;
              // serverErrorText = "Server Error Occured Please Try Again Later";
              nameErrorField = false;
              emailErrorField = false;
            });
            if (_nameKey.currentState!.validate() &&
                _mailKey.currentState!.validate()) {
              setState(() {
                isLoading = true;
                singupbutton = false;
              });
              var response = await http.post(
                  Uri.parse("${globalConstants.severIp}/auth/signup"),
                  headers: {
                    'Content-Type': 'application/json',
                  },
                  body: jsonEncode(
                      {'name': groupName.text, 'emails': sendEmails}));
              setState(() {
                isLoading = false;
              });
              print(jsonDecode(response.body));
              Navigator.pushNamed(context, "/login");
            }
          } catch (err) {
            setState(() {
              singupbutton = true;
              serverError = true;
              serverErrorText = "Server Error Occured Please Try Again Later";
              isLoading = false;
            });
          }
        },
        child: Text(
          "Signup",
          style: TextStyle(fontSize: 20),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
              margin: EdgeInsets.only(top: 10),
              padding: EdgeInsets.fromLTRB(20, 5, 20, 0),
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
              height: 550,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 5, 2),
                    child: Text(
                      "Signup",
                      style: TextStyle(
                          color: Colors.blueGrey.shade700, fontSize: 20),
                    ),
                  ),
                  SizedBox(
                    height: 14,
                  ),
                  nameField(),
                  SizedBox(
                    height: 14,
                  ),
                  emailsField(),
                  SizedBox(
                    height: 14,
                  ),
                  Center(
                      child: isLoading
                          ? Padding(
                              padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
                              child: CircularProgressIndicator(
                                color: Colors.deepPurple.shade900,
                              ),
                            )
                          : serverError
                              ? Text(serverErrorText)
                              : Container()),
                  singupbutton
                      ? Center(
                          child: singupButton(),
                        )
                      : Container(),
                  Center(
                    child: Container(
                        margin: EdgeInsets.fromLTRB(12, 20, 12, 5),
                        child: Text(
                          "Note: Add Multiple Email Addresses Using a comma. You Can Add Upto 5 Email Addresses Only For a group. Dont End Group Email address statement with a Comma ",
                          style: TextStyle(
                              fontSize: 15,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                        )),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, "/login");
                          },
                          child: Text(
                            "Already Have an Account? Login Here",
                            style: TextStyle(color: Colors.deepPurple.shade900),
                          )),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
