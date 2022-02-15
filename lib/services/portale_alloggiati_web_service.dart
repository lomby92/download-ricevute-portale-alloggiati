import 'dart:convert';
import 'dart:io';

import 'package:download_ricevute_portale_alloggiati/exceptions/authentication_failure_exception.dart';
import 'package:download_ricevute_portale_alloggiati/exceptions/no_receipt_available_for_date_exception.dart';
import 'package:download_ricevute_portale_alloggiati/models/credentials.dart';
import 'package:intl/intl.dart';
import 'package:xml/xml.dart';

class PortaleAlloggiatiWebService {
  static const portaleAlloggiatiWebServiceUri =
      'https://alloggiatiweb.poliziadistato.it/service/Service.asmx';

  static final httpClient = HttpClient();

  static Future<String> generateToken(CredentialsModel credentials) async {
    var request = await _getPostRequest();

    HtmlEscape xmlEscape = const HtmlEscape();
    var body = '''
<?xml version="1.0" encoding="utf-8"?>
<soap12:Envelope
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:xsd="http://www.w3.org/2001/XMLSchema"
  xmlns:soap12="http://www.w3.org/2003/05/soap-envelope"
>
  <soap12:Body>
    <GenerateToken xmlns="AlloggiatiService">
      <Utente>${xmlEscape.convert(credentials.getUsername()!)}</Utente>
      <Password>${xmlEscape.convert(credentials.getPassword()!)}</Password>
      <WsKey>${xmlEscape.convert(credentials.getWskey()!)}</WsKey>
    </GenerateToken>
  </soap12:Body>
</soap12:Envelope>
''';
    request.write(body);

    HttpClientResponse response = await request.close();

    // Process the response
    var responseBody = await response.transform(utf8.decoder).join();

    _assertSuccessfulResponse(responseBody);

    // Parse response
    return XmlDocument.parse(responseBody)
        .findAllElements('token')
        .first
        .innerText;
  }

  static Future<String> retrieveReceipt(
      DateTime date, String username, String token) async {
    var request = await _getPostRequest();

    HtmlEscape xmlEscape = const HtmlEscape();
    var body = '''
<?xml version="1.0" encoding="utf-8"?>
<soap12:Envelope
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:xsd="http://www.w3.org/2001/XMLSchema"
  xmlns:soap12="http://www.w3.org/2003/05/soap-envelope"
>
  <soap12:Body>
    <Ricevuta xmlns="AlloggiatiService">
      <Utente>${xmlEscape.convert(username)}</Utente>
      <token>${xmlEscape.convert(token)}</token>
      <Data>${DateFormat('yyyy-MM-dd').format(date)}</Data>
    </Ricevuta>
  </soap12:Body>
</soap12:Envelope>
''';
    request.write(body);

    HttpClientResponse response = await request.close();

    // Process the response
    var responseBody = await response.transform(utf8.decoder).join();

    _assertSuccessfulResponse(responseBody);

    // Parse response
    return XmlDocument.parse(responseBody)
        .findAllElements('PDF')
        .first
        .innerText;
  }

  static void _assertSuccessfulResponse(String responseBody) {
    var xml = XmlDocument.parse(responseBody);
    var isSuccessful = xml.findAllElements('esito').first.innerText == 'true';

    if (!isSuccessful) {
      var errorMessage = xml.findAllElements('ErroreDes').first.innerText;

      if (errorMessage == 'ERRORE_RECUPERO_RICEVUTA') {
        throw NoReceiptAvailableForDateException();
      }

      throw AuthenticationFailureException(errorMessage);
    }
  }

  static Future<HttpClientRequest> _getPostRequest() async {
    HttpClientRequest request =
        await httpClient.postUrl(Uri.parse(portaleAlloggiatiWebServiceUri));

    // Setup headers
    request.headers.contentType =
        ContentType.parse('application/soap+xml; charset=utf-8');

    return request;
  }
}
