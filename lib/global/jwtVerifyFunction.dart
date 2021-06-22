import 'package:todo_flutter_app/global/storage.dart' as globalStorage;
import 'package:jwt_decoder/jwt_decoder.dart';

validLogin() async {
  // await globalStorage.storage.delete(key: "jwt");
  var result;
  var jwt = await globalStorage.storage.read(key: "jwt");
  try {
    result = JwtDecoder.isExpired(jwt.toString());
  } catch (err) {
    return true;
  }
  return result;
}
