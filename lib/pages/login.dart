import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/style.dart';
import 'package:custom_timer/custom_timer.dart';
import 'package:http/http.dart' as http;
import 'package:todo_flutter_app/global/serverIp.dart' as globalConstants;
import 'package:todo_flutter_app/global/storage.dart' as globalStorage;

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool emailEdit = true;
  bool otpbutton = true;
  bool otpfield = false;
  bool timeText = false;
  bool isLoading = false;
  bool resendOtp = false;
  bool loading = false;
  bool boxes = false;
  bool error = false;
  bool groupNameEdit = true;
  String errorText = "";
  var groupObjectReceived;
  var requestId;

  final emailController = TextEditingController();
  final groupName = new TextEditingController();
  final emailKey = GlobalKey<FormState>();
  final groupNameKey = GlobalKey<FormState>();
  final CustomTimerController _Timecontroller = new CustomTimerController();

  void sendOtpRequest() async {
    try {
      setState(() {
        groupNameEdit = false;
      });
      var result = await http.post(
          Uri.parse("${globalConstants.severIp}/auth/login"),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode(
              {'name': groupName.text, 'emailaddress': emailController.text}));
      var resultBody = jsonDecode(result.body);
      if (resultBody['err'] != null) {
        setState(() {
          groupNameEdit = true;
          emailEdit = true;
          timeText = false;
          otpfield = false;
          error = true;
          errorText = "${resultBody['err']}";
          resendOtp = true;
          isLoading = false;
        });
        print(errorText);
      } else {
        print(resultBody);
        groupObjectReceived = resultBody;
        requestId = resultBody['id'];
        setState(() {
          error = false;
          errorText = "";
          emailEdit = false;
          timeText = true;
          resendOtp = false;
          isLoading = false;
        });
      }
    } catch (err) {
      print(err);
      setState(() {
        groupNameEdit = true;
        resendOtp = true;
        error = true;
        otpfield = false;
        errorText =
            "Some Error Occured While sending OTP Request Please Try Again Later";
        emailEdit = false;
        timeText = false;
        resendOtp = false;
        isLoading = false;
      });
    }
  }

  Widget otpButton() {
    return Container(
      margin: EdgeInsets.only(top: 15),
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              primary: Colors.deepPurpleAccent.shade100,
              padding: EdgeInsets.fromLTRB(30, 10, 30, 10),
              elevation: 10.0),
          onPressed: () {
            if (emailKey.currentState!.validate()) {
              setState(() {
                emailEdit = false;
                otpbutton = false;
                isLoading = true;
              });
              sendOtpRequest();
              setState(() {
                isLoading = false;
                timeText = true;
                boxes = true;
                otpfield = true;
              });
            }
          },
          child: Text("Email The OTP")),
    );
  }

  Widget nameField() {
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Form(
        key: groupNameKey,
        child: TextFormField(
          enabled: groupNameEdit,
          controller: groupName,
          decoration: InputDecoration(
              hintText: "Group Name",
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
                  TextStyle(fontSize: 15.0, fontWeight: FontWeight.w500)),
        ),
      ),
    );
  }

  Widget emailTextField() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Form(
        key: emailKey,
        child: TextFormField(
          keyboardType: TextInputType.emailAddress,
          controller: emailController,
          enabled: emailEdit,
          decoration: InputDecoration(
              contentPadding: EdgeInsets.all(20.0),
              suffixIcon: Icon(
                Icons.email_rounded,
                color: Colors.deepPurple.shade600,
              ),
              hintText: "Email",
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide(
                      color: Colors.deepPurple.shade400, width: 2.0)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide(
                      color: Colors.deepPurple.shade400, width: 2.0)),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide(
                      color: Colors.deepPurple.shade400, width: 2.0)),
              disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide(
                      color: Colors.deepPurple.shade400, width: 2.0)),
              errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide(color: Colors.red, width: 2.0)),
              errorStyle:
                  TextStyle(fontSize: 15.0, fontWeight: FontWeight.w500)),
          validator: (value) {
            if (EmailValidator.validate(value!)) {
              return null;
            }
            return "Please Enter Valid Email Address";
          },
        ),
      ),
    );
  }

  dialog() {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Invalid OTP'),
        content:
            const Text('Please Check the OTP u have received and Enter It'),
        actions: <Widget>[
          TextButton(
            onPressed: () =>
                {Navigator.pop(context, 'OK'), _Timecontroller.start()},
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget otptextfield() {
    return OTPTextField(
      length: 4,
      width: 400,
      // width: MediaQuery.of(context).size.width,
      fieldWidth: 50,
      style: TextStyle(fontSize: 15),
      textFieldAlignment: MainAxisAlignment.spaceAround,
      fieldStyle: FieldStyle.underline,
      onChanged: (value) {
        print(value);
      },
      onCompleted: (String pin) async {
        setState(() {
          isLoading = true;
        });
        _Timecontroller.pause();
        var result = await http.post(
            Uri.parse("${globalConstants.severIp}/otp/verifyOtp"),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'id': requestId, 'otp': pin}));
        var resultBody = jsonDecode(result.body);
        if (resultBody['accessToken'] != null) {
          await globalStorage.storage
              .write(key: 'jwt', value: resultBody['accessToken']);
          setState(() {
            isLoading = false;
          });
          await globalStorage.storage
              .write(key: "groupId", value: groupObjectReceived['groupId']);
          await globalStorage.storage
              .write(key: "groupName", value: groupObjectReceived['name']);

          Navigator.pushNamedAndRemoveUntil(
              context, "/category", (Route<dynamic> route) => false);
          // Navigator.pus
        } else {
          setState(() {
            isLoading = false;
          });
          dialog();
          // print("Invalid");
        }
      },
    );
  }

  Widget otptimer() {
    return CustomTimer(
      from: Duration(minutes: 5),
      to: Duration(minutes: 0),
      controller: _Timecontroller,
      onBuildAction: CustomTimerAction.auto_start,
      builder: (CustomTimerRemainingTime remaining) {
        return Text(
          "Resend the OTP in ${remaining.minutes}:${remaining.seconds}",
          style: TextStyle(fontSize: 18.0),
        );
      },
      onFinish: () {
        setState(() {
          requestId = "";
          timeText = false;
          resendOtp = true;
          otpfield = false;
        });
      },
    );
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 5, 2),
                    child: Text(
                      "Login",
                      style: TextStyle(
                          color: Colors.blueGrey.shade700, fontSize: 20),
                    ),
                  ),
                  nameField(),
                  emailTextField(),
                  otpbutton ? otpButton() : Container(),
                  SizedBox(height: 20),
                  timeText
                      ? Text("OTP Sent",
                          style: TextStyle(
                              color: Colors.green[400], fontSize: 17.0))
                      : Container(),
                  boxes ? SizedBox(height: 20.0) : Container(),
                  otpfield ? otptextfield() : Container(),
                  boxes ? SizedBox(height: 20) : Container(),
                  timeText ? otptimer() : Container(),
                  isLoading ? CircularProgressIndicator() : Container(),
                  resendOtp
                      ? ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              primary: Colors.deepPurpleAccent.shade100,
                              padding: EdgeInsets.fromLTRB(30, 10, 30, 10),
                              elevation: 10.0),
                          onPressed: () {
                            setState(() {
                              isLoading = true;
                              resendOtp = false;
                              // otpfield = false;
                            });
                            sendOtpRequest();
                            setState(() {
                              otpfield = true;
                            });
                          },
                          child: Text("Resend OTP"))
                      : Container(),
                  boxes ? SizedBox(height: 20) : Container(),
                  error ? Text(errorText) : Container(),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, "/singup");
                          },
                          child: Text(
                            "Dont have an account? Signup",
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
