import 'package:todo_flutter_app/global/storage.dart' as globalStorage;

// Hosted Server IP Link
// final String severIp = "https://todo-app-tj.herokuapp.com";

// Emulator Server IP Link
final String severIp = "http://10.0.2.2:8000";

// Physical Device IP Link
// final String severIp = "http://192.168.43.243:8000";
var jwt;
tokenRead() async {
  jwt = await globalStorage.storage.read(key: "jwt");
  var headers = {
    "Content-Type": "application/json",
    'Authorization': '$jwt',
  };
  return headers;
}
