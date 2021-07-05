import 'package:flutter/material.dart';
import 'package:todo_flutter_app/pages/login.dart';

class SingupPage extends StatefulWidget {
  const SingupPage({Key? key}) : super(key: key);

  @override
  _SingupPageState createState() => _SingupPageState();
}

class _SingupPageState extends State<SingupPage> {
  final groupName = new TextEditingController();
  final groupEmails = new TextEditingController();

  Widget nameField() {
    return TextField(
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
                  BorderSide(color: Colors.deepPurple.shade400, width: 1.0))),
    );
  }

  Widget emailsField() {
    return TextField(
      controller: groupEmails,
      maxLines: 6,
      decoration: InputDecoration(
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
                  BorderSide(color: Colors.deepPurple.shade400, width: 2.0))),
    );
  }

  Widget singupButton() {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
            primary: Colors.deepPurpleAccent.shade100,
            padding: EdgeInsets.fromLTRB(30, 10, 30, 10),
            elevation: 10.0),
        onPressed: () {},
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
              padding: EdgeInsets.all(15.0),
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
              height: 530,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                    height: 20,
                  ),
                  nameField(),
                  SizedBox(
                    height: 20,
                  ),
                  emailsField(),
                  SizedBox(
                    height: 20,
                  ),
                  Center(child: singupButton()),
                  Center(
                    child: Container(
                        margin: EdgeInsets.fromLTRB(12, 20, 12, 5),
                        child: Text(
                          "Note: Add Multiple Email Addresses Using a comma. You Can Add Upto 5 Email Addresses Only For a group",
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
