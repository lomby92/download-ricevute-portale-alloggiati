import 'package:download_ricevute_portale_alloggiati/exceptions/authentication_failure_exception.dart';
import 'package:download_ricevute_portale_alloggiati/models/credentials.dart';
import 'package:download_ricevute_portale_alloggiati/screens/download_page.dart';
import 'package:download_ricevute_portale_alloggiati/services/portale_alloggiati_web_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatelessWidget {
  static const routeName = '/login';

  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    var wskey = context.select<CredentialsModel, String?>(
        (credentials) => credentials.getWskey());
    var username = context.select<CredentialsModel, String?>(
        (credentials) => credentials.getUsername());
    String? password;

    return Scaffold(
      appBar: AppBar(title: const Text('DoRPA - Login')),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(
            minWidth: 150.0,
            maxWidth: 600.0,
            minHeight: 200.0,
            maxHeight: 500.0,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey,
                spreadRadius: 5,
                blurRadius: 10,
              ),
            ],
          ),
          margin: const EdgeInsets.all(20.0),
          padding: const EdgeInsets.all(30.0),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 32.0),
                  child: Text(
                    'Entra con le credenziali del Portale Alloggiati',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textScaleFactor: 2.0,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: TextFormField(
                    autofocus: true,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      filled: true,
                      hintText: 'Inserisci la WS key',
                      labelText: 'WS key',
                    ),
                    obscureText: true,
                    initialValue: wskey,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Il campo è richiesto';
                      }

                      return null;
                    },
                    onSaved: (value) => wskey = value,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 16.0),
                  child: Divider(
                    color: Colors.brown,
                    indent: 16,
                    endIndent: 16,
                    thickness: 1,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: TextFormField(
                    autofocus: true,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      filled: true,
                      hintText: 'Inserisci username nel formato AB123456',
                      labelText: 'Username',
                    ),
                    maxLength: 8,
                    initialValue: username,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Il campo è richiesto';
                      }

                      if (value.length != 8) {
                        return "L'username deve essere di 8 caratteri";
                      }

                      return null;
                    },
                    onSaved: (value) => username = value,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: TextFormField(
                    autofocus: true,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      filled: true,
                      hintText: 'Inserisci la password',
                      labelText: 'Password',
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Il campo è richiesto';
                      }

                      return null;
                    },
                    onSaved: (value) => password = value,
                  ),
                ),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(20.0),
                    ),
                    child: const Text('Login'),
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        // Save the form to have the updated password value
                        formKey.currentState!.save();

                        _login(
                          context,
                          Navigator.of(context),
                          wskey,
                          username,
                          password,
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _login(
    BuildContext context,
    NavigatorState navigator,
    wskey,
    username,
    password,
  ) async {
    var credentials = context.read<CredentialsModel>();

    // Store credentials
    credentials.setWskey(wskey);
    credentials.setUsername(username);
    credentials.setPassword(password);

    try {
      // HTTP call to GenerateToken
      var token = await PortaleAlloggiatiWebService.generateToken(credentials);

      // Store token
      credentials.token = token;

      // Go to download page
      navigator.pushReplacementNamed(DownloadPage.routeName);
    } on AuthenticationFailureException catch (authenticationFailure) {
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Errore'),
          content: Text(authenticationFailure.toString()),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'Ok'),
              child: const Text('Ok'),
            ),
          ],
        ),
      );
    }
  }
}
