import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dartx/dartx.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:im_stepper/stepper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:telcabo/FormStepper.dart';
import 'package:telcabo/LoginWidget.dart';
import 'package:telcabo/NotificationExample.dart';
import 'package:telcabo/Tools.dart';
import 'package:telcabo/custome/ConnectivityCheckBlocBuilder.dart';
import 'package:telcabo/custome/ImageFieldBlocbuilder.dart';
import 'package:telcabo/models/response_get_demandes.dart';
import 'package:telcabo/models/response_get_liste_etats.dart';
import 'dart:convert';

import 'dart:developer' as developer;

import 'package:flutter/services.dart';
import 'package:telcabo/ui/DrawerWidget.dart';
import 'package:telcabo/ui/InterventionHeaderInfoWidget.dart';



final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();


class DemandeList extends StatefulWidget {

  @override
  State<DemandeList> createState() => _DemandeListState();
}

class _DemandeListState extends State<DemandeList> {
  final _scrollController = ScrollController();
  // late ResponseGetDemandesList demandesList;
  final _formKey = GlobalKey<FormBuilderState>();



  GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
  GlobalKey<RefreshIndicatorState>();
  ResponseGetDemandesList? demandesList;
  ResponseGetDemandesList? demandesListSaved;
  Future<void>? _initDemandesData;



  TextEditingController _searchController = TextEditingController(

  );

  late NavigatorState navigator;


  @override
  void didChangeDependencies() {
    navigator = Navigator.of(context);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    // _navigator.pushAndRemoveUntil(..., (route) => ...);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Tools.colorPrimary,
      drawer: DrawerWidget(),
      body: MultiBlocProvider(
        providers: [
          BlocProvider<WizardFormBloc>(
            create: (BuildContext context) => WizardFormBloc(),
          ),
          BlocProvider<InternetCubit>(
            create: (BuildContext context) =>
                InternetCubit(connectivity: Connectivity()),
          ),
        ],
        child: MultiBlocListener(
          listeners: [
            BlocListener<InternetCubit, InternetState>(
              listener: (context, state) async {
                if(state is InternetConnected){
                  print("InternetConnected");
                  showSimpleNotification(
                    Text("status : en ligne , synchronisation en cours "),
                    // subtitle: Text("onlime"),
                    background: Colors.green,
                    duration: Duration(seconds: 5),
                  );

                  await Tools.readFileTraitementList();

                  final items = await Tools.getDemandes();

                  setState(() {
                    demandesListSaved = items ;
                    demandesList = items;
                  });

                }
                if(state is InternetDisconnected ){
                  showSimpleNotification(
                    Text("Offline"),
                    // subtitle: Text("onlime"),
                    background: Colors.red,
                    duration: Duration(seconds: 5),
                  );
                }
              },
            ),

          ],
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            controller: _scrollController, // <---- Same as the Scrollbar controller

            // padding: const EdgeInsets.all(24.0),
            child: Column(
              children: <Widget>[
                SizedBox(height: 50.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton.icon(
                      icon: Icon(
                        Icons.menu,
                        color: Colors.white,
                        size: 25,
                      ),
                      label: Container(
                        child: Text(
                          "Liste demandes".tr().capitalize(),
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0),
                        ),
                      ),
                      onPressed: () {
                        // Navigator.pop(context);
                        scaffoldKey.currentState!.openDrawer();

                      },
                    ),
                   ElevatedButton.icon(onPressed: () async {



                   }, icon: Icon(Icons.filter_list), label: Text("Filtrer"))
                  ],
                ),
                SizedBox(height: 20.0),

                Container(
                  height: MediaQuery.of(context).size.height - 140.0,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(75.0)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child:  Column(children: <Widget>[
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelText: 'Nom client'.tr().capitalize(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        onChanged: (value) {},
                        // valueTransformer: (text) => num.tryParse(text),

                        keyboardType: TextInputType.text,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      TextButton.icon(
                        icon: Icon(Icons.search),
                        label: Text('chercher'.tr().capitalize()),
                        style: TextButton.styleFrom(

                          minimumSize: Size(500, 50),
                          primary: Colors.white,
                          backgroundColor: Tools.colorPrimary,
                          // shape: const BeveledRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                        ),
                        onPressed: () {
                            print("Search value ==> ${_searchController.value.text}");

                            _filterListByCLient(_searchController.value.text);
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text("${demandesListSaved?.demandes?.length ?? 0} Demandes disponibles" ,
                          style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'Open Sans',
                                  letterSpacing: 1.3,
                                  fontSize: 16),
                          ),
                      ),

                      SizedBox(
                        height: 20,
                      ),

                      Expanded(
                        child: Container(
                          height: MediaQuery.of(context).size.height,
                          child: FutureBuilder(
                            future: _initDemandesData,
                            builder: (BuildContext context, snapshot) {
                              switch (snapshot.connectionState) {
                                case ConnectionState.none:
                                case ConnectionState.waiting:
                                case ConnectionState.active:
                                  {
                                    return Center(
                                      child: Text('Loading...'),
                                    );
                                  }
                                case ConnectionState.done:
                                  {
                                    return RefreshIndicator(
                                        key: _refreshIndicatorKey,
                                        displacement: 0,
                                        onRefresh: _refreshList,
                                        child: ListView.builder(
                                          itemCount: demandesList?.demandes?.length  ?? 0,
                                          itemBuilder: (BuildContext context, index) {

                                            final item = demandesList?.demandes?[index];

                                            return Padding(
                                              padding: const EdgeInsets.only(bottom: 8),
                                              child: DemandeListItem(demande: item!, navigator: navigator),
                                            );
                                          },
                                        ));
                                  }
                              }
                            },
                          ),
                          // FutureBuilder<ResponseGetDemandesList>(
                          //   future: Tools.getListDemandeFromLocalAndINternet(),
                          //   builder: (BuildContext context, AsyncSnapshot<ResponseGetDemandesList> snapshot) {
                          //     List<Widget> children;
                          //     if (snapshot.hasData) {
                          //       return RefreshIndicator(
                          //         onRefresh: () async {
                          //           refreshDemandeList();
                          //         },
                          //         child: Scrollbar(
                          //           isAlwaysShown: true,
                          //           child: ListView.builder(
                          //             // Let the ListView know how many items it needs to build.
                          //             itemCount: snapshot.data?.demandes?.length  ?? 0,
                          //             // Provide a builder function. This is where the magic happens.
                          //             // Convert each item into a widget based on the type of item it is.
                          //             itemBuilder: (context, index) {
                          //               final item = snapshot.data?.demandes?[index];
                          //
                          //               return Padding(
                          //                 padding: const EdgeInsets.only(bottom: 8),
                          //                 child: DemandeListItem(demande: item!,),
                          //               );
                          //             },),
                          //         ),
                          //       );
                          //     } else if (snapshot.hasError) {
                          //       return Center(
                          //         child: Column(
                          //           mainAxisAlignment: MainAxisAlignment.center,
                          //           children: [
                          //             Icon(
                          //               Icons.error_outline,
                          //               color: Colors.red,
                          //               size: 60,
                          //             ),
                          //             Padding(
                          //               padding: const EdgeInsets.only(top: 16),
                          //               child: Text('Error: ${snapshot.error}'),
                          //             )
                          //           ],
                          //         ),
                          //       );
                          //
                          //     } else {
                          //       return Center(
                          //         child: Column(
                          //           mainAxisAlignment: MainAxisAlignment.center,
                          //           children: [
                          //             SizedBox(
                          //               width: 60,
                          //               height: 60,
                          //               child: CircularProgressIndicator(),
                          //             ),
                          //             Padding(
                          //               padding: EdgeInsets.only(top: 16),
                          //               child: Text('résultat en attente...'),
                          //             )
                          //           ],
                          //         ),
                          //       );
                          //
                          //     }
                          //
                          //   },
                          // ),
                        ),
                      ),
                    ]),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );


  }



  Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print("Handling a background message: ${message.messageId}");
    // Tools.getDemandes();
    final items = await Tools.getDemandes();

    setState(() {
      demandesListSaved = items ;
      demandesList = items;
    });
  }


  late final FirebaseMessaging _messaging;
  PushNotification? _notificationInfo;

  void registerNotification() async {
    await Firebase.initializeApp();
    _messaging = FirebaseMessaging.instance;

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);



    // String deviceToken = "" ;
    // await _messaging.getToken().then((value) {
    //   print("Device Token ${value}");
    //   deviceToken = value ?? "" ;
    // });
    //
    // Tools.deviceToken = deviceToken;
    // print("registerNotification "+ Tools.deviceToken );


    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');

      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        print(
            'Message title: ${message.notification?.title}, body: ${message.notification?.body}, data: ${message.data}');

        // Parse the message received
        PushNotification notification = PushNotification(
          title: message.notification?.title,
          body: message.notification?.body,
          dataTitle: message.data['title'],
          dataBody: message.data['body'],
        );


        final items = await Tools.getDemandes();

        setState(() {
          demandesListSaved = items ;
          demandesList = items;
        });



        if (_notificationInfo != null) {
          // For displaying the notification as an overlay
          showSimpleNotification(
            Text(_notificationInfo!.title!),
            leading: NotificationBadge(totalNotifications: 100),
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

      print("*** FirebaseMessaging.instance.getInitialMessage() ***");


      PushNotification notification = PushNotification(
        title: initialMessage.notification?.title,
        body: initialMessage.notification?.body,
        dataTitle: initialMessage.data['title'],
        dataBody: initialMessage.data['body'],
      );

      // Tools.getDemandes();

      final items = await Tools.getDemandes();

      setState(() {
        demandesListSaved = items ;
        demandesList = items;
      });
    }


    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {

      print("*** onMessageOpenedApp ***");

      PushNotification notification = PushNotification(
        title: message.notification?.title,
        body: message.notification?.body,
        dataTitle: message.data['title'],
        dataBody: message.data['body'],
      );

      // Tools.getDemandes();
      final items = await Tools.getDemandes();

      setState(() {
        demandesListSaved = items ;
        demandesList = items;
      });

    });


  }


  @override
  void initState() {
    super.initState();
    Tools.getDemandes();

    _initDemandesData = _initList();

    registerNotification();
    checkForInitialMessage();


    Tools.readFileTraitementList();
  }





  Future<void> _initList() async {
    final items = await Tools.getListDemandeFromLocalAndINternet();
    setState(() {
      demandesListSaved = items ;
      demandesList = items;
    });
  }

  Future<void> _refreshList() async {
    final items = await Tools.getListDemandeFromLocalAndINternet();
    setState(() {
      demandesListSaved = items ;
      demandesList = items;
    });
  }
  Future<void> _filterListByCLient(String client) async {
    final items = ResponseGetDemandesList(
      demandes: demandesListSaved?.demandes?.where((element) {
        print("check ${element.client}");
        return element.client?.toLowerCase().contains(client.toLowerCase()) ?? false;
      }).toList()
    );
    setState(() {
      demandesList = items;
    });
  }




}




class EndDrawerFilterWidget extends StatelessWidget {
  const EndDrawerFilterWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/bg_home.jpg"),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: [
              Text("Commentaires"),

            ],
          ),
        ),
      ),
    );
  }
}
