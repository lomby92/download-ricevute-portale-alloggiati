import 'dart:convert';
import 'dart:io';

import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:download_ricevute_portale_alloggiati/exceptions/authentication_failure_exception.dart';
import 'package:download_ricevute_portale_alloggiati/exceptions/no_receipt_available_for_date_exception.dart';
import 'package:download_ricevute_portale_alloggiati/models/credentials.dart';
import 'package:download_ricevute_portale_alloggiati/screens/login_page.dart';
import 'package:download_ricevute_portale_alloggiati/services/portale_alloggiati_web_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class DownloadPage extends StatelessWidget {
  static const routeName = '/download';

  const DownloadPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // If here, the token must be generated so we can safely assume that
    // username and token are not null.
    var username = context.select<CredentialsModel, String>(
        (credentials) => credentials.getUsername()!);
    var token = context
        .select<CredentialsModel, String>((credentials) => credentials.token!);

    final _formKey = GlobalKey<FormState>();

    DateTime? date;

    return Scaffold(
      appBar:
          AppBar(title: const Text('DoRPA - Download ricevute'), primary: true),
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
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 32.0),
                  child: Text(
                    'Scarica la ricevuta degli invii',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textScaleFactor: 2.0,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: DateTimeField(
                    decoration: const InputDecoration(
                      filled: true,
                      hintText: 'Inserisci la data per cui scaricare il file',
                    ),
                    format: DateFormat('yyyy-MM-dd'),
                    onShowPicker: (context, currentValue) {
                      return showDatePicker(
                        context: context,
                        firstDate:
                            DateTime.now().subtract(const Duration(days: 30)),
                        initialDate: currentValue ?? DateTime.now(),
                        lastDate: DateTime.now(),
                      );
                    },
                    onSaved: (value) => date = value,
                  ),
                ),
                Center(
                  child: ElevatedButton(
                    child: const Text('Download'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(20.0),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        _download(context, date!, username, token);
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

  void _download(
    BuildContext context,
    DateTime date,
    String username,
    String token,
  ) async {
    try {
      // HTTP call to get file content
      var pdfAsBase64String = await PortaleAlloggiatiWebService.retrieveReceipt(
          date, username, token);

      // Ask user for output file folder and name
      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Seleziona la destinazione:',
        fileName: 'ricevuta-${DateFormat('yyyy-MM-dd').format(date)}.pdf',
      );

      // If output file is null, the user has canceled the input
      if (outputFile == null) {
        return;
      }

      // Create the file
      var file = File(outputFile);
      file.writeAsBytesSync(base64.decode(pdfAsBase64String));

      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Successo'),
          content: Text('File salvato correttamente su $outputFile'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'Ok'),
              child: const Text('Ok'),
            ),
          ],
        ),
      );
    } on NoReceiptAvailableForDateException catch (noReceiptAvailableForDateException) {
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Attenzione'),
          content: Text(noReceiptAvailableForDateException.toString()),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'Ok'),
              child: const Text('Ok'),
            ),
          ],
        ),
      );
    } on AuthenticationFailureException {
      Navigator.pushReplacementNamed(context, LoginPage.routeName);
    }
  }
}
