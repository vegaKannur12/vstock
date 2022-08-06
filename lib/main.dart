import 'package:barcodescanner/controller/provider_controller.dart';
import 'package:barcodescanner/controller/registration_controller.dart';
import 'package:barcodescanner/screen/barcode_scanner.dart';
import 'package:barcodescanner/screen/createDir.dart';
import 'package:barcodescanner/screen/device_info.dart';
import 'package:barcodescanner/screen/registrationScreen.dart';
import 'package:barcodescanner/screen/scan_type.dart';
import 'package:barcodescanner/screen/splashScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ProviderController()),
          ChangeNotifierProvider(
            create: (_) => RegistrationController(),
          ),
        ],
        child: MyApp(),
      ),
    );
  });
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.grey[200],
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: Color(0xFF424242),
          secondary: Color(0xFF424242),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
