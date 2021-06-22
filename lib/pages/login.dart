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
  bool boxes = false;
  var requestId;

  final emailController = TextEditingController();
  int serverotp = 1111;
  final _formKey = GlobalKey<FormState>();

  void sendOtpRequest() async {
    var result =
        await http.post(Uri.parse("${globalConstants.severIp}/otp/sendOtp"),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'emailaddress': emailController.text}));
    var resultBody = jsonDecode(result.body);
    requestId = resultBody['id'];
    // requestId = resultBody
    setState(() {
      emailEdit = false;
      timeText = true;
      resendOtp = false;
      isLoading = false;
    });
  }

  Widget otpButton() {
    return ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
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
        child: Text("Email The OTP"));
  }

  Widget emailTextField() {
    return Padding(
        padding: EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: TextFormField(
            keyboardType: TextInputType.emailAddress,
            controller: emailController,
            autofocus: true,
            enabled: emailEdit,
            decoration: InputDecoration(
                contentPadding: EdgeInsets.all(20.0),
                suffixIcon: Icon(
                  Icons.email_rounded,
                  color: Colors.blue,
                ),
                hintText: "Email Address",
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
                // errorText: "Please Enter Some Text",
                errorStyle: TextStyle(fontSize: 15.0)),
            validator: (value) {
              if (EmailValidator.validate(value!)) {
                return null;
              }
              return "Please Enter Valid Email Address";
            },
          ),
        ));
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
            onPressed: () => Navigator.pop(context, 'OK'),
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
          Navigator.pushNamedAndRemoveUntil(
              context, "/category", (Route<dynamic> route) => false);
        } else {
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
      appBar: AppBar(
        title: Text("Login To App"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            emailTextField(),
            otpbutton ? otpButton() : Container(),
            SizedBox(height: 20),
            timeText
                ? Text("OTP Sent",
                    style: TextStyle(color: Colors.green[400], fontSize: 17.0))
                : Container(),
            boxes ? SizedBox(height: 20.0) : Container(),
            otpfield ? otptextfield() : Container(),
            boxes ? SizedBox(height: 20) : Container(),
            timeText ? otptimer() : Container(),
            isLoading ? CircularProgressIndicator() : Container(),
            resendOtp
                ? ElevatedButton(
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
          ],
        ),
      ),
    );
  }
}
