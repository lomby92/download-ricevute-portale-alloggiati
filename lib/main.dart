import 'package:download_ricevute_portale_alloggiati/models/credentials.dart';
import 'package:download_ricevute_portale_alloggiati/screens/download_page.dart';
import 'package:download_ricevute_portale_alloggiati/screens/login_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  CredentialsModel.create().then((model) {
    runApp(
      ChangeNotifierProvider(
        create: (context) => model,
        child: const DownloadRicevutePortaleAlloggiati(),
      ),
    );
  });
}

class DownloadRicevutePortaleAlloggiati extends StatelessWidget {
  const DownloadRicevutePortaleAlloggiati({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DoRPA - Download Ricevute Portale Alloggiati',
      theme: ThemeData(
        primarySwatch: Colors.brown,
      ),
      initialRoute: '/login',
      routes: {
        LoginPage.routeName: (context) => const LoginPage(),
        DownloadPage.routeName: (context) => const DownloadPage(),
      },
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('it', 'IT')],
    );
  }
}
