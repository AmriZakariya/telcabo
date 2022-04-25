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
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
      endDrawer: EndDrawerFilterWidget(),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {  },
      //   child: Icon(Icons.info),
      //
      // ),
      onEndDrawerChanged: (isOpened) {
        if(!isOpened){
          filterListByMap();
        }
      },
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
                    position: NotificationPosition.bottom
                  );

                  await Tools.readFileTraitementList();

                  final items = await Tools.getDemandes();

                  setState(() {
                    Tools.demandesListSaved = items ;
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
                        child: Row(
                          children: [
                            Text(
                              "Liste demandes (${Tools.demandesListSaved?.demandes?.length ?? 0})",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20.0),
                            ),
                            GestureDetector(
                              onTap: () {

                              },
                              child: Tooltip(
                                message: "Detail",
                                child: Container(
                                  padding: const EdgeInsets.only(top: 3),
                                  width: 35,
                                  height: 35,
                                  decoration: BoxDecoration(
                                      color: Tools.colorPrimary, shape: BoxShape.circle),
                                  child: Center(
                                      child: FaIcon(
                                        FontAwesomeIcons.circleInfo,
                                        color: Colors.white,
                                        size: 20,
                                      )),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      onPressed: () {
                        // Navigator.pop(context);
                        scaffoldKey.currentState!.openDrawer();

                      },
                    ),
                   ElevatedButton.icon(onPressed: () async {

                    scaffoldKey.currentState?.openEndDrawer();


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
                    padding: const EdgeInsets.all(20.0),
                    child:  Column(children: <Widget>[
                      // TextField(
                      //   controller: _searchController,
                      //   decoration: InputDecoration(
                      //     labelText: 'Nom client'.tr().capitalize(),
                      //     prefixIcon: Icon(Icons.person),
                      //   ),
                      //   onChanged: (value) {},
                      //   // valueTransformer: (text) => num.tryParse(text),
                      //
                      //   keyboardType: TextInputType.text,
                      // ),
                      // SizedBox(
                      //   height: 20,
                      // ),
                      // TextButton.icon(
                      //   icon: Icon(Icons.search),
                      //   label: Text('chercher'.tr().capitalize()),
                      //   style: TextButton.styleFrom(
                      //
                      //     minimumSize: Size(500, 50),
                      //     primary: Colors.white,
                      //     backgroundColor: Tools.colorPrimary,
                      //     // shape: const BeveledRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                      //   ),
                      //   onPressed: () {
                      //       print("Search value ==> ${_searchController.value.text}");
                      //
                      //       _filterListByCLient(_searchController.value.text);
                      //   },
                      // ),
                      // Padding(
                      //   padding: const EdgeInsets.only(top: 6),
                      //   child: Text("${Tools.demandesListSaved?.demandes?.length ?? 0} Demandes disponibles" ,
                      //     style: TextStyle(
                      //             fontWeight: FontWeight.w900,
                      //             fontFamily: 'Open Sans',
                      //             letterSpacing: 1.3,
                      //             fontSize: 16),
                      //     ),
                      // ),
                      // Padding(
                      //   padding: const EdgeInsets.only(top: 6),
                      //   child: Text("${Tools.demandesListSaved?.demandes?.where((element) => element.etatId == "1").length } Demandes planifiées" ,
                      //     style: TextStyle(
                      //         fontWeight: FontWeight.w900,
                      //         fontFamily: 'Open Sans',
                      //         letterSpacing: 1.3,
                      //         fontSize: 14),
                      //   ),
                      // ),
                      // Padding(
                      //   padding: const EdgeInsets.only(top: 6),
                      //   child: Text("${Tools.demandesListSaved?.demandes?.where((element) {
                      //     return ( ["6", "9"].contains(element.etatId ) && (element.speed?.isEmpty == true)  && (element.speed?.isEmpty == true) );
                      //   }).length } Demandes en attentes" ,
                      //     style: TextStyle(
                      //         fontWeight: FontWeight.w900,
                      //         fontFamily: 'Open Sans',
                      //         letterSpacing: 1.3,
                      //         fontSize: 14),
                      //   ),
                      // ),

                      // SizedBox(
                      //   height: 20,
                      // ),

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
      Tools.demandesListSaved = items ;
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
          Tools.demandesListSaved = items ;
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
        Tools.demandesListSaved = items ;
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
        Tools.demandesListSaved = items ;
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
      Tools.demandesListSaved = items ;
      demandesList = items;
    });
  }

  Future<void> _refreshList() async {
    final items = await Tools.getListDemandeFromLocalAndINternet();
    setState(() {
      Tools.demandesListSaved = items ;
      demandesList = items;
    });
  }
  Future<void> filterListByCLient(String client) async {
    final items = ResponseGetDemandesList(
      demandes: Tools.demandesListSaved?.demandes?.where((element) {
        print("check ${element.client}");
        return element.client?.toLowerCase().contains(client.toLowerCase()) ?? false;
      }).toList()
    );
    setState(() {
      demandesList = items;
    });
  }
  Future<void> filterListByMap() async {

    String filter_client = Tools.searchFilter?["filter"] ;
    String filter_offre =  Tools.searchFilter?["offre"] ;
    String filter_typeDemande =  Tools.searchFilter?["typeDemande"] ;
    String filter_contactClient =   Tools.searchFilter?["contactClient"] ;

    final items = ResponseGetDemandesList(
      demandes: Tools.demandesListSaved?.demandes?.where((element) {
        print("check ${element.client}");

        bool shouldAdd = true ;

        if(filter_client.isNotNullOrEmpty){
          if( element.client?.toLowerCase().contains(filter_client.toLowerCase()) ?? false){

          }else{
            shouldAdd = false;
          }
        }

        if(filter_offre.isNotNullOrEmpty){
          if( element.offre?.toLowerCase().contains(filter_offre.toLowerCase()) ?? false){

          }else{
            shouldAdd = false;
          }
        }


        if(filter_typeDemande.isNotNullOrEmpty){
          if( element.typeDemande?.toLowerCase().contains(filter_typeDemande.toLowerCase()) ?? false){

          }else{
            shouldAdd = false;
          }
        }


        if(filter_contactClient.isNotNullOrEmpty){
          if( element.contactClient?.toLowerCase().contains(filter_contactClient.toLowerCase()) ?? false){

          }else{
            shouldAdd = false;
          }
        }


        return shouldAdd ;
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
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text("Filter"),
                SearchFieldFormWidget(),
                
              ],
            ),
          ),
        ),
      ),
    );
  }
}



class SearchFIeldsFormBloc extends FormBloc<String, String> {
  final client = TextFieldBloc(
    name: "client"
  );
  final offre = TextFieldBloc(
    name: "offre"
  );
  final typeDemande = TextFieldBloc(
      name: "typeDemande"
  );
  final contactClient = TextFieldBloc(
      name: "contactClient"
  );

  // final boolean1 = BooleanFieldBloc();
  //
  // final boolean2 = BooleanFieldBloc();
  //
  // final select1 = SelectFieldBloc(
  //   items: ['Option 1', 'Option 2'],
  //   validators: [FieldBlocValidators.required],
  // );
  //
  // final select2 = SelectFieldBloc(
  //   items: ['Option 1', 'Option 2'],
  //   validators: [FieldBlocValidators.required],
  // );
  //
  // final multiSelect1 = MultiSelectFieldBloc<String, dynamic>(
  //   items: [
  //     'Option 1',
  //     'Option 2',
  //     'Option 3',
  //     'Option 4',
  //     'Option 5',
  //   ],
  // );
  // final file = InputFieldBloc<File?, String>(initialValue: null);
  //
  // final date1 = InputFieldBloc<DateTime?, Object>(initialValue: null);
  //
  // final dateAndTime1 = InputFieldBloc<DateTime?, Object>(initialValue: null);
  //
  // final time1 = InputFieldBloc<TimeOfDay?, Object>(initialValue: null);
  //
  // final double1 = InputFieldBloc<double, dynamic>(
  //   initialValue: 0.5,
  // );

  SearchFIeldsFormBloc() : super() {
    addFieldBlocs(fieldBlocs: [
      client,
      offre,
      typeDemande,
      contactClient,

    ]);
  }



  @override
  void onSubmitting() async {
    print("onSubmitting async") ;

    try {
      Map<String, dynamic> jsonResult =   state.toJson();
      print("jsonResult ==> ${jsonResult}") ;
      Tools.searchFilter = jsonResult ;
      emitSuccess(canSubmitAgain: true);
    } catch (e) {
      emitFailure();
    }
  }
}

class SearchFieldFormWidget extends StatelessWidget {
  const SearchFieldFormWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SearchFIeldsFormBloc(),
      child: Builder(
        builder: (context) {
          final formBloc = BlocProvider.of<SearchFIeldsFormBloc>(context);

          return FormBlocListener<SearchFIeldsFormBloc, String, String>(
            onSubmitting: (context, state) {
              print(" FormBlocListener onSubmitting") ;

              LoadingDialog.show(context);
            },
            onSuccess: (context, state) {
              print(" FormBlocListener onSuccess") ;

              LoadingDialog.hide(context);


              // Navigator.of(context).pushReplacement(
              //     MaterialPageRoute(builder: (_) => const SuccessScreen()));

              Navigator.of(context).pop();

              // filterListByCLient(_searchController.value.text);

            },
            onFailure: (context, state) {
              print(" FormBlocListener onFailure") ;

              LoadingDialog.hide(context);
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.failureResponse!)));
            },
            onSubmissionFailed: (context, state) {
              print(" FormBlocListener onSubmissionFailed "+ state.toString()) ;

              LoadingDialog.hide(context);
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("onSubmissionFailed")));
            },
            child: ScrollableFormBlocManager(
              formBloc: formBloc,
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: <Widget>[
                    TextFieldBlocBuilder(
                      textFieldBloc: formBloc.client,
                      decoration: const InputDecoration(
                        labelText: 'Client',
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: FaIcon(
                            FontAwesomeIcons.solidUser,
                            size: 18,

                          ),
                        ),
                      ),
                    ),
                    TextFieldBlocBuilder(
                      textFieldBloc: formBloc.offre,
                      decoration: const InputDecoration(
                        labelText: 'Offre',
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: FaIcon(
                            FontAwesomeIcons.certificate,
                            // size: 18,
                          ),
                        ),
                      ),
                    ),
                    TextFieldBlocBuilder(
                      textFieldBloc: formBloc.typeDemande,
                      decoration: const InputDecoration(
                        labelText: 'Type demande ',
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: FaIcon(
                            FontAwesomeIcons.tag,
                            // size: 18,
                          ),
                        ),
                      ),
                    ),
                    TextFieldBlocBuilder(
                      textFieldBloc: formBloc.contactClient,
                      decoration: const InputDecoration(
                        labelText: 'Contact CLient',
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: FaIcon(
                            FontAwesomeIcons.phone,
                            // size: 18,
                          ),
                        ),
                      ),
                    ),
                    // RadioButtonGroupFieldBlocBuilder<String>(
                    //   selectFieldBloc: formBloc.select2,
                    //   decoration: const InputDecoration(
                    //     labelText: 'RadioButtonGroupFieldBlocBuilder',
                    //   ),
                    //   groupStyle: const FlexGroupStyle(),
                    //   itemBuilder: (context, item) => FieldItem(
                    //     child: Text(item),
                    //   ),
                    // ),
                    // CheckboxGroupFieldBlocBuilder<String>(
                    //   multiSelectFieldBloc: formBloc.multiSelect1,
                    //   decoration: const InputDecoration(
                    //     labelText: 'CheckboxGroupFieldBlocBuilder',
                    //   ),
                    //   groupStyle: const ListGroupStyle(
                    //     scrollDirection: Axis.horizontal,
                    //     height: 64,
                    //   ),
                    //   itemBuilder: (context, item) => FieldItem(
                    //     child: Text(item),
                    //   ),
                    // ),
                    // DateTimeFieldBlocBuilder(
                    //   dateTimeFieldBloc: formBloc.date1,
                    //   format: DateFormat('dd-MM-yyyy'),
                    //   initialDate: DateTime.now(),
                    //   firstDate: DateTime(1900),
                    //   lastDate: DateTime(2100),
                    //   decoration: const InputDecoration(
                    //     labelText: 'DateTimeFieldBlocBuilder',
                    //     prefixIcon: Icon(Icons.calendar_today),
                    //     helperText: 'Date',
                    //   ),
                    // ),
                    // DateTimeFieldBlocBuilder(
                    //   dateTimeFieldBloc: formBloc.dateAndTime1,
                    //   canSelectTime: true,
                    //   format: DateFormat('dd-MM-yyyy  hh:mm'),
                    //   initialDate: DateTime.now(),
                    //   firstDate: DateTime(1900),
                    //   lastDate: DateTime(2100),
                    //   decoration: const InputDecoration(
                    //     labelText: 'DateTimeFieldBlocBuilder',
                    //     prefixIcon: Icon(Icons.date_range),
                    //     helperText: 'Date and Time',
                    //   ),
                    // ),
                    // TimeFieldBlocBuilder(
                    //   timeFieldBloc: formBloc.time1,
                    //   format: DateFormat('hh:mm a'),
                    //   initialTime: TimeOfDay.now(),
                    //   decoration: const InputDecoration(
                    //     labelText: 'TimeFieldBlocBuilder',
                    //     prefixIcon: Icon(Icons.access_time),
                    //   ),
                    // ),
                    // SwitchFieldBlocBuilder(
                    //   booleanFieldBloc: formBloc.boolean2,
                    //   body: const Text('SwitchFieldBlocBuilder'),
                    // ),
                    // DropdownFieldBlocBuilder<String>(
                    //   selectFieldBloc: formBloc.select1,
                    //   decoration: const InputDecoration(
                    //     labelText: 'DropdownFieldBlocBuilder',
                    //   ),
                    //   itemBuilder: (context, value) => FieldItem(
                    //     isEnabled: value != 'Option 1',
                    //     child: Text(value),
                    //   ),
                    // ),
                    // Row(
                    //   children: [
                    //     IconButton(
                    //       onPressed: () => formBloc.addFieldBloc(
                    //           fieldBloc: formBloc.select1),
                    //       icon: const Icon(Icons.add),
                    //     ),
                    //     IconButton(
                    //       onPressed: () => formBloc.removeFieldBloc(
                    //           fieldBloc: formBloc.select1),
                    //       icon: const Icon(Icons.delete),
                    //     ),
                    //   ],
                    // ),
                    // CheckboxFieldBlocBuilder(
                    //   booleanFieldBloc: formBloc.boolean1,
                    //   body: const Text('CheckboxFieldBlocBuilder'),
                    // ),
                    // CheckboxFieldBlocBuilder(
                    //   booleanFieldBloc: formBloc.boolean1,
                    //   body: const Text('CheckboxFieldBlocBuilder trailing'),
                    //   controlAffinity:
                    //   FieldBlocBuilderControlAffinity.trailing,
                    // ),
                    // SliderFieldBlocBuilder(
                    //   inputFieldBloc: formBloc.double1,
                    //   divisions: 10,
                    //   labelBuilder: (context, value) =>
                    //       value.toStringAsFixed(2),
                    // ),
                    // SliderFieldBlocBuilder(
                    //   inputFieldBloc: formBloc.double1,
                    //   divisions: 10,
                    //   labelBuilder: (context, value) =>
                    //       value.toStringAsFixed(2),
                    //   activeColor: Colors.red,
                    //   inactiveColor: Colors.green,
                    // ),
                    // SliderFieldBlocBuilder(
                    //   inputFieldBloc: formBloc.double1,
                    //   divisions: 10,
                    //   labelBuilder: (context, value) =>
                    //       value.toStringAsFixed(2),
                    // ),
                    // ChoiceChipFieldBlocBuilder<String>(
                    //   selectFieldBloc: formBloc.select2,
                    //   itemBuilder: (context, value) => ChipFieldItem(
                    //     label: Text(value),
                    //   ),
                    // ),
                    // FilterChipFieldBlocBuilder<String>(
                    //   multiSelectFieldBloc: formBloc.multiSelect1,
                    //   itemBuilder: (context, value) => ChipFieldItem(
                    //     label: Text(value),
                    //   ),
                    // ),
                    // BlocBuilder<InputFieldBloc<File?, String>,
                    //     InputFieldBlocState<File?, String>>(
                    //     bloc: formBloc.file,
                    //     builder: (context, state) {
                    //       return Container();
                    //     })
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: ElevatedButton.icon(
                        icon: Icon(
                          Icons.filter_list,
                          size: 24.0,
                        ),
                        onPressed: () {
                          print("cliick");
                          // formBloc.readJson();
                          // formBloc.fileTraitementList.writeAsStringSync("");

                          formBloc.submit();
                        },
                        label: const Text('Filtrer',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18.0,
                            wordSpacing: 12,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          // shape: CircleBorder(),

                          minimumSize: Size(280, 50),
                          // primary: Tools.colorPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(30.0),
                          ),
                        ),
                      ),
                    ),

                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class LoadingDialog extends StatelessWidget {
  static void show(BuildContext context, {Key? key}) => showDialog<void>(
    context: context,
    useRootNavigator: false,
    barrierDismissible: false,
    builder: (_) => LoadingDialog(key: key),
  ).then((_) => FocusScope.of(context).requestFocus(FocusNode()));

  static void hide(BuildContext context) => Navigator.pop(context);

  const LoadingDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Center(
        child: Card(
          child: Container(
            width: 80,
            height: 80,
            padding: const EdgeInsets.all(12.0),
            child: const CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(Icons.tag_faces, size: 100),
            const SizedBox(height: 10),
            const Text(
              'Success',
              style: TextStyle(fontSize: 54, color: Colors.black),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const SearchFieldFormWidget())),
              icon: const Icon(Icons.replay),
              label: const Text('AGAIN'),
            ),
          ],
        ),
      ),
    );
  }
}