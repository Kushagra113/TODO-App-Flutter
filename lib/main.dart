import 'package:flutter/material.dart';
import 'package:todo_flutter_app/pages/addCategory.dart';
import 'package:todo_flutter_app/pages/category.dart';
import 'package:todo_flutter_app/pages/login.dart';
import 'package:todo_flutter_app/global/jwtVerifyFunction.dart';

var iniRoute;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool isLoggedIn = await validLogin();
  iniRoute = isLoggedIn ? '/login' : '/category';
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: iniRoute,
      routes: {
        "/login": (context) => Login(),
        "/category": (context) => Category(),
        "/addCategory": (context) => AddCategory(),
      },
    );
  }
}
