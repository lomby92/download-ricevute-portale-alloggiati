import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CredentialsModel extends ChangeNotifier {
  static FlutterSecureStorage store = const FlutterSecureStorage();

  String? _username;

  String? _password;

  String? _wskey;

  String? token;

  static Future<CredentialsModel> create() async {
    var model = CredentialsModel._create();

    WidgetsFlutterBinding.ensureInitialized();
    model._username = await store.read(key: 'username');
    model._wskey = await store.read(key: 'wskey');

    return model;
  }

  CredentialsModel._create() {
    _username = null;
    _password = null;
    _wskey = null;
    token = null;
  }

  String? getUsername() {
    return _username;
  }

  String? getPassword() {
    return _password;
  }

  String? getWskey() {
    return _wskey;
  }

  void setUsername(String username) {
    _username = username;
    store.write(key: 'username', value: username);
  }

  void setPassword(String password) {
    _password = password;
  }

  void setWskey(String wskey) {
    _wskey = wskey;
    store.write(key: 'wskey', value: wskey);
  }
}
