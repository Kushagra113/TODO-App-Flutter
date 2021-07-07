import 'package:flutter/material.dart';
import 'package:todo_flutter_app/pages/addCategory.dart';
import 'package:todo_flutter_app/pages/category.dart';
import 'package:todo_flutter_app/pages/login.dart';
import 'package:todo_flutter_app/global/jwtVerifyFunction.dart';
import 'package:todo_flutter_app/pages/singup.dart';
import 'package:page_transition/page_transition.dart';
// import 'package:todo_flutter_app/global/storage.dart' as globalStorage;

var iniRoute;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await globalStorage.storage.delete(key: "jwt");
  bool isLoggedIn = await validLogin();
  iniRoute = isLoggedIn ? '/login' : '/category';
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/login':
            return PageTransition(
                child: Login(),
                type: PageTransitionType.scale,
                alignment: Alignment.bottomLeft,
                settings: settings);
          case '/singup':
            return PageTransition(
                child: SingupPage(),
                type: PageTransitionType.scale,
                alignment: Alignment.topLeft,
                settings: settings);
          default:
            return null;
        }
      },
      initialRoute: iniRoute,
      routes: {
        "/category": (context) => Category(),
        "/addCategory": (context) => AddCategory(),
      },
    );
  }
}
