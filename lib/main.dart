
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:notification_permissions/notification_permissions.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:telcabo/DemandeList.dart';
import 'package:telcabo/FormStepper.dart';
import 'package:telcabo/NotificationExample.dart';
import 'package:telcabo/SplashPage.dart';
import 'package:telcabo/TestWatermark.dart';
import 'package:telcabo/Tools.dart';
import 'package:telcabo/UploadTest.dart';

import 'InterventionWidget.dart';
import 'LoginWidget.dart';


import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';



Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
  Tools.getDemandes();
}



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();


  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  Tools.initFiles();
  NotificationPermissions.requestNotificationPermissions(
      iosSettings: const NotificationSettingsIos(
          sound: true, badge: true, alert: true))
      .then((_) {
    // when finished, check the permission status

  });

  var cameraPermission = Permission.camera;
  var storagePermission = Permission.storage;
  var locationPermission = Permission.location;

  if (await cameraPermission.status.isDenied) {
    // We didn't ask for permission yet or the permission has been denied before but not permanently.
    if (await cameraPermission.request().isGranted) {
      // Either the permission was already granted before or the user just granted it.
    }
  }

  if (await storagePermission.status.isDenied) {
    // We didn't ask for permission yet or the permission has been denied before but not permanently.
    if (await storagePermission.request().isGranted) {
      // Either the permission was already granted before or the user just granted it.
    }
  }

  if (await locationPermission.status.isDenied) {
    // We didn't ask for permission yet or the permission has been denied before but not permanently.
    if (await locationPermission.request().isGranted) {
      // Either the permission was already granted before or the user just granted it.
    }
  }


  HttpOverrides.global = MyHttpOverrides();

  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: [Locale('fr')],
      path: 'assets/translations', // <-- change the path of the translation files
      fallbackLocale: Locale('fr'),
      startLocale: Locale('fr'),
      saveLocale: false,
      // child: NotificationMessagesApp(),
      child: MyApp(),


    ),
  );
}



class MyApp extends StatefulWidget {

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {


  void getDeviceToken() async {
    await Firebase.initializeApp();
    final FirebaseMessaging _messaging = FirebaseMessaging.instance;
    String deviceToken = "" ;
    await _messaging.getToken().then((value) {
      print("Device Token ${value}");
      deviceToken = value ?? "" ;
    });

    Tools.deviceToken = deviceToken;
    print("registerNotification "+ Tools.deviceToken );

  }



  @override
  Widget build(BuildContext context) {
    Tools.languageCode = context.locale.languageCode ;

    List<LocalizationsDelegate<dynamic>> localizationsDelegatesList = context.localizationDelegates;
    localizationsDelegatesList.addAll([
      FormBuilderLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ]);

    FieldBlocBuilder.defaultErrorBuilder =
        (BuildContext context,
        Object error,
        FieldBloc fieldBloc,
        ) {
      switch (error) {
        case FieldBlocValidatorsErrors.required:
          // return "required".tr();
          return "Ce champ est obligatoire" ;

        default:
          return error.toString();
      }
    };



    return OverlaySupport(
      child: MaterialApp(
          localizationsDelegates: localizationsDelegatesList,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          debugShowCheckedModeBanner: false,
          // theme: ThemeData.dark().copyWith(
            // appBarTheme:AppBarTheme(
            //   backgroundColor: Color(0xff0a0e21),
            //
            // ),
            // scaffoldBackgroundColor: Color(0xff0a0e21),
            // primaryColor: Tools.colorPrimary
          // ),
          // home: HomePage()
          theme: ThemeData(
            // fontFamily: 'Roboto',
            colorScheme: ColorScheme.light().copyWith(primary: Tools.colorPrimary),
            // textTheme: TextTheme(labelMedium: TextStyle(
            //   fontSize: 30
            // )),

              appBarTheme:AppBarTheme(
            //   backgroundColor: Color(0xff0a0e21),
            //
            ),
          ),
          // home: WizardForm(),
          // home: InterventionFormStep1(),
          // home: TestWatermark(),
          home: SplashPage(),
          // home: FutureBuilder<bool>(
          //     future: _checkLogin(),
          //     builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          //       switch (snapshot.connectionState) {
          //         case ConnectionState.waiting:
          //           return Center(child: const CircularProgressIndicator());
          //         default:
          //           if (snapshot.hasError) {
          //             return Text('Error: ${snapshot.error}');
          //           } else {
          //             if(snapshot.data == true){
          //               return DemandeList();
          //             }else{
          //               return LoginWidget();
          //             }
          //           }
          //       }
          //     }),
          routes: {

          },
      ),
    );

  }


  @override
  void initState() {
    getDeviceToken();
    checkInternet();


    // checkForInitialMessage();
  }

  void checkInternet() async {
    Tools.connectivityResult = await (Connectivity().checkConnectivity());

  }
}



class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}