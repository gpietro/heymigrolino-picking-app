import 'package:demo/app_config.dart';
import 'package:demo/flavor.dart';
import 'package:provider/provider.dart';
import 'package:demo/state/application_state.dart';
import 'package:flutter/material.dart';
import 'package:scandit_flutter_datacapture_barcode/scandit_flutter_datacapture_barcode.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env.dev_gooods');
  await ScanditFlutterDataCaptureBarcode.initialize();
  const appConfig = AppConfig(
    appName: AppNames.gooodsDev,
    verifyBarcode: 7630048367525,
    child: AppRouter(),
  );
  runApp(MultiProvider(providers: [
    Provider<Flavor>.value(value: Flavor.dev_gooods),
    ChangeNotifierProvider(
      create: (context) => ApplicationState(),
    )
  ], child: appConfig));
}
