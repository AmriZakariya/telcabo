import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:notification_permissions/notification_permissions.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:telcabo/DemandeList.dart';
import 'package:telcabo/FormStepper.dart';
import 'package:telcabo/InterventionFormStep2.dart';
import 'package:telcabo/NotificationExample.dart';
import 'package:telcabo/TestWatermark.dart';
import 'package:telcabo/Tools.dart';
import 'package:telcabo/UploadTest.dart';

import 'InterventionWidget.dart';
import 'InterventionWidgetStep1.dart';
import 'LoginWidget.dart';


import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';



Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
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
  late final FirebaseMessaging _messaging;

  late int _totalNotifications;

  PushNotification? _notificationInfo;

  Future<String> registerNotification() async {
    await Firebase.initializeApp();
    String deviceToken = "" ;
    _messaging = FirebaseMessaging.instance;

    await _messaging.getToken().then((value) {
      print("Device Token ${value}");
      deviceToken = value ?? "" ;
    });

    Tools.deviceToken = deviceToken;
    print("registerNotification "+ Tools.deviceToken );
    return deviceToken ;


    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print(
            'Message title: ${message.notification?.title}, body: ${message.notification?.body}, data: ${message.data}');

        // Parse the message received
        PushNotification notification = PushNotification(
          title: message.notification?.title,
          body: message.notification?.body,
          dataTitle: message.data['title'],
          dataBody: message.data['body'],
        );

        // setState(() {
        //   _notificationInfo = notification;
        //   _totalNotifications++;
        // });

        if (_notificationInfo != null) {
          // For displaying the notification as an overlay
          showSimpleNotification(
            Text(_notificationInfo!.title!),
            leading: NotificationBadge(totalNotifications: _totalNotifications),
            subtitle: Text(_notificationInfo!.body!),
            background: Colors.cyan.shade700,
            duration: Duration(seconds: 2),
          );
        }
      });
    } else {
      print('User declined or has not accepted permission');
    }
  }

  // For handling notification when the app is in terminated state
  checkForInitialMessage() async {
    await Firebase.initializeApp();
    RemoteMessage? initialMessage =
    await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      PushNotification notification = PushNotification(
        title: initialMessage.notification?.title,
        body: initialMessage.notification?.body,
        dataTitle: initialMessage.data['title'],
        dataBody: initialMessage.data['body'],
      );

      // setState(() {
      //   _notificationInfo = notification;
      //   _totalNotifications++;
      // });
    }
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
          home: FutureBuilder<bool>(
              future: _checkLogin(),
              builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return Center(child: const CircularProgressIndicator());
                  default:
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      if(snapshot.data == true){
                        return DemandeList();
                      }else{
                        return LoginWidget();
                      }
                    }
                }
              }),
          routes: {
            'form': (context) => InterventionFormStep2(),
            'login': (context) => LoginWidget(),
            'intervention': (context) => InterventionWidget(),
          },
      ),
    );

  }

  Future<bool> _checkLogin() async {
    final prefs = await SharedPreferences.getInstance();

    Tools.userId =  prefs.getString('userId') ?? "" ;
    Tools.userName =  prefs.getString('userName') ?? "" ;
    Tools.userEmail =  prefs.getString('userEmail') ?? "" ;

    return prefs.getBool('isOnline') ?? false  ;
  }

  @override
  void initState() {
    registerNotification();

  }
}
