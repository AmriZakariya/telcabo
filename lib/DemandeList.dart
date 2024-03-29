import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:dartx/dartx.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:expand_widget/expand_widget.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:telcabo/DetailIntervention.dart';
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
import 'package:telcabo/ui/LoadingDialog.dart';
import 'package:url_launcher/url_launcher.dart';

final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

class DemandeList extends StatefulWidget {
  @override
  State<DemandeList> createState() => _DemandeListState();
}

class _DemandeListState extends State<DemandeList> with WidgetsBindingObserver {
  final _scrollController = ScrollController();

  // late ResponseGetDemandesList demandesList;
  final _formKey = GlobalKey<FormBuilderState>();

  GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  ResponseGetDemandesList? demandesList;
  Future<void>? _initDemandesData;

  TextEditingController _searchController = TextEditingController();

  late NavigatorState navigator;

  @override
  void didChangeDependencies() {
    navigator = Navigator.of(context);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    // WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }


  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print("didChangeAppLifecycleState state ==> ${state}");
    // if (state == AppLifecycleState.resumed) {
    //   filterListByMap();
    // }
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
        if (!isOpened) {
          filterListByMap();
        }
      },
      onDrawerChanged: (isOpened) {
        if (!isOpened) {
          filterByType();
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
              listenWhen: (previous, current) {
                print("**** buildWhen *** ");
                print("previous ==>  ${previous} ");
                print("current ==>  ${current} ");
                return previous != current;
              },
              listener: (context, state) async {
                if (state is InternetConnected) {
                  print("InternetConnected");
                  showSimpleNotification(
                      Text("status : en ligne , synchronisation en cours "),
                      // subtitle: Text("onlime"),
                      background: Colors.green,
                      duration: Duration(seconds: 5),
                      position: NotificationPosition.bottom);

                  await Tools.readFileTraitementList();

                  final items = await Tools.getDemandes();

                  setState(() {
                    Tools.demandesListSaved = items;
                    demandesList = items;
                  });
                }
                if (state is InternetDisconnected) {
                  // showSimpleNotification(
                  //   Text("Offline"),
                  //   // subtitle: Text("onlime"),
                  //   background: Colors.red,
                  //   duration: Duration(seconds: 5),
                  // );
                }
              },
            ),
          ],
          child: Stack(
            children: [
              SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                controller: _scrollController,
                // <---- Same as the Scrollbar controller

                // padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 50.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
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
                                    Container(
                                      width: MediaQuery.of(context).size.width - 200,
                                      child: Text(
                                        getTitle(),
                                        overflow: TextOverflow.ellipsis,
                                        // default is .clip
                                        maxLines: 2,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20.0),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        CoolAlert.show(
                                          context: context,
                                          type: CoolAlertType.info,
                                          title: "Détail",
                                          widget: Column(
                                            children: [
                                              Divider(
                                                color: Colors.black,
                                                height: 2,
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.only(top: 6),
                                                child: Text(
                                                  "${Tools.demandesListSaved?.demandes?.length ?? 0} Demandes disponibles",
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.w900,
                                                      fontFamily: 'Open Sans',
                                                      letterSpacing: 1.3,
                                                      fontSize: 16),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.only(top: 6),
                                                child: Text(
                                                  "${Tools.demandesListSaved?.demandes?.where((element) => element.etatId == "1").length} Demandes planifiées",
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.w900,
                                                      fontFamily: 'Open Sans',
                                                      letterSpacing: 1.3,
                                                      fontSize: 16),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.only(top: 6),
                                                child: Text(
                                                  "${Tools.demandesListSaved?.demandes?.where((element) {
                                                    return (["6", "9"].contains(
                                                            element.etatId) &&
                                                        (element.speed?.isEmpty ==
                                                            true) &&
                                                        (element.speed?.isEmpty ==
                                                            true));
                                                  }).length} Demandes en attentes",
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.w900,
                                                      fontFamily: 'Open Sans',
                                                      letterSpacing: 1.3,
                                                      fontSize: 16),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                      child: Tooltip(
                                        message: "Detail",
                                        child: Container(
                                          padding: const EdgeInsets.only(top: 3),
                                          width: 35,
                                          height: 35,
                                          decoration: BoxDecoration(
                                              color: Tools.colorPrimary,
                                              shape: BoxShape.circle),
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
                          ],
                        ),
                        ElevatedButton.icon(
                            onPressed: () async {
                              scaffoldKey.currentState?.openEndDrawer();
                            },
                            icon: Icon(Icons.filter_list),
                            label: Text("Filtrer")),
                      ],
                    ),
                    SizedBox(height: 20.0),
                    Container(
                      height: MediaQuery.of(context).size.height - 140.0,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.only(topLeft: Radius.circular(75.0)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(children: <Widget>[
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
                              // decoration: BoxDecoration(
                              //   image: DecorationImage(
                              //     image: AssetImage("assets/bg_home.jpeg"),
                              //     fit: BoxFit.cover,
                              //   ),
                              // ),
                              child: FutureBuilder(
                                future: _initDemandesData,
                                builder: (BuildContext context, snapshot) {
                                  switch (snapshot.connectionState) {
                                    case ConnectionState.none:
                                    case ConnectionState.waiting:
                                    case ConnectionState.active:
                                      {
                                        return LoadingWidget();
                                      }
                                    case ConnectionState.done:
                                      {
                                        return RefreshIndicator(
                                            key: _refreshIndicatorKey,
                                            displacement: 0,
                                            onRefresh: _refreshList,
                                            child: Scrollbar(
                                              child: ListView.builder(
                                                itemCount:
                                                    demandesList?.demandes?.length ??
                                                        0,
                                                itemBuilder:
                                                    (BuildContext context, index) {
                                                  final item =
                                                      demandesList?.demandes?[index];

                                                  final Demandes demande = item! ;
                                                  return Padding(
                                                    padding: const EdgeInsets.only(
                                                        bottom: 8),
                                                    child: Container(
                                                      margin: const EdgeInsets.only(left: 15),
                                                      decoration: BoxDecoration(
                                                          border: Border.all(
                                                            color: Colors.transparent,
                                                            // style: BorderStyle.values
                                                          ),
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: Tools.getColorByEtatId(int.parse(demande.etatId ?? "0"))
                                                                  .withOpacity(0.5),
                                                              spreadRadius: 1,
                                                              blurRadius: 1,
                                                              offset: Offset(0, 0), // changes position of shadow
                                                            ),
                                                          ],
                                                          borderRadius: BorderRadius.circular(
                                                              20) // use instead of BorderRadius.all(Radius.circular(20))
                                                      ),
                                                      child: Center(
                                                          child: Column(
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            children: [
                                                              Container(
                                                                width: double.infinity,
                                                                height: 65,
                                                                decoration: BoxDecoration(
                                                                    color: Tools.getColorByEtatId(int.parse(demande.etatId ?? "0")),
                                                                    border: Border.all(
                                                                      color: Colors.transparent,
                                                                    ),
                                                                    borderRadius: BorderRadius.circular(
                                                                        20) // use instead of BorderRadius.all(Radius.circular(20))
                                                                ),
                                                                child: Row(children: [
                                                                  SizedBox(
                                                                    height: 5.0,
                                                                  ),
                                                                  // CircleAvatar(
                                                                  //   radius: 32.0,
                                                                  //   backgroundImage: AssetImage('assets/user.png'),
                                                                  //   backgroundColor: Colors.white,
                                                                  // ),
                                                                  Padding(
                                                                    padding: const EdgeInsets.only(left: 8),
                                                                    child: Icon(
                                                                      Icons.person,
                                                                      size: 22,
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    width: MediaQuery.of(context).size.width - 175,
                                                                    child: Text('${demande.client}',
                                                                        overflow: TextOverflow.ellipsis,
                                                                        style: TextStyle(
                                                                          color: Colors.black,
                                                                          fontSize: 16.0,
                                                                        )),
                                                                  ),

                                                                  // Spacer(),
                                                                  Row(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                                    children: [
                                                                      GestureDetector(
                                                                        onTap: () {
                                                                          Tools.selectedDemande = demande;
                                                                          Tools.currentStep = (Tools.selectedDemande?.etape ?? 1) -1 ;
                                                                          print("currentStepValueNotifier updateValue => ${Tools.currentStep} ");
                                                                          currentStepValueNotifier.value = Tools.currentStep ;

                                                                          print(
                                                                              "Tools.selectedDemande => ${Tools.selectedDemande?.toJson()}");

                                                                          navigator.push(MaterialPageRoute(
                                                                            builder: (_) => DetailIntervention(),
                                                                          ));
                                                                        },
                                                                        child: Tooltip(
                                                                          message: "Voir",
                                                                          child: Container(
                                                                            width: 30,
                                                                            height: 30,
                                                                            decoration: BoxDecoration(
                                                                                color: Tools.colorPrimary, shape: BoxShape.circle),
                                                                            child: Center(
                                                                                child: FaIcon(
                                                                                  FontAwesomeIcons.solidEye,
                                                                                  color: Colors.white,
                                                                                  size: 15,
                                                                                )),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      GestureDetector(
                                                                        onTap: () {
                                                                          Tools.selectedDemande = demande;
                                                                          Tools.currentStep = (Tools.selectedDemande?.etape ?? 1) -1 ;
                                                                          print("currentStepValueNotifier updateValue => ${Tools.currentStep} ");
                                                                          currentStepValueNotifier.value = Tools.currentStep ;

                                                                          print(
                                                                              "Tools.selectedDemande => ${Tools.selectedDemande?.toJson()}");

                                                                          navigator
                                                                              .push(MaterialPageRoute(
                                                                            builder: (_) => WizardForm(),
                                                                          ))
                                                                              .then((_) {
                                                                            // This method gets callback after your SecondScreen is popped from the stack or finished.
                                                                            filterListByMap() ;
                                                                          });
                                                                        },
                                                                        child: Tooltip(
                                                                          message: "Voir",
                                                                          child: Padding(
                                                                            padding: const EdgeInsets.symmetric(horizontal: 8),
                                                                            child: Container(
                                                                              width: 30,
                                                                              height: 30,
                                                                              decoration: BoxDecoration(
                                                                                  color: Tools.colorPrimary,
                                                                                  shape: BoxShape.circle),
                                                                              child: Center(
                                                                                  child: FaIcon(
                                                                                    FontAwesomeIcons.screwdriver,
                                                                                    color: Colors.white,
                                                                                    size: 15,
                                                                                  )),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      // ElevatedButton(
                                                                      //   child: Icon(Icons.remove_red_eye, size: 20),
                                                                      //   onPressed: () {
                                                                      //     Tools.selectedDemande = demande ;
                                                                      //
                                                                      //   },
                                                                      //   style: ElevatedButton .styleFrom(
                                                                      //     // minimumSize: Size.zero, // Set this
                                                                      //     // padding: EdgeInsets.zero,
                                                                      //     shape: const CircleBorder(),
                                                                      //   ),
                                                                      // ),
                                                                      // ElevatedButton(
                                                                      //   child: FaIcon(FontAwesomeIcons.screwdriver, size: 20),
                                                                      //   onPressed: () {
                                                                      //     Tools.selectedDemande = demande ;
                                                                      //     print("Tools.selectedDemande => ${Tools.selectedDemande?.toJson()}");
                                                                      //
                                                                      //     if(demande.etatId == "3"
                                                                      //         && demande.pPbiAvant != ""
                                                                      //         && demande.pPbiApres != ""){
                                                                      //       // Navigator.of(context).push(MaterialPageRoute(
                                                                      //       //   builder: (_) => InterventionFormStep2(),
                                                                      //       // ));
                                                                      //       Tools.currentStep = 1 ;
                                                                      //     }else{
                                                                      //       // Navigator.of(context).push(MaterialPageRoute(
                                                                      //       //   builder: (_) => InterventionFormStep1(),
                                                                      //       // ));
                                                                      //       Tools.currentStep = 0 ;
                                                                      //
                                                                      //     }
                                                                      //
                                                                      //     // FormBlocState.currentStep = Tools.currentStep ;
                                                                      //
                                                                      //     Navigator.of(context).push(MaterialPageRoute(
                                                                      //       builder: (_) => WizardForm(),
                                                                      //     ));
                                                                      //
                                                                      //   },
                                                                      //   style: ElevatedButton.styleFrom(
                                                                      //     // minimumSize: Size.zero, // Set this
                                                                      //     // padding: EdgeInsets.zero,
                                                                      //     shape: const CircleBorder(),
                                                                      //   ),
                                                                      // ),
                                                                    ],
                                                                  ),
                                                                ]),
                                                              ),
                                                              ExpandChild(
                                                                arrowSize: 25,
                                                                arrowPadding: EdgeInsets.all(0),
                                                                child: Container(
                                                                  // color: Colors.white,
                                                                    child: Padding(
                                                                      padding: EdgeInsets.all(15.0),
                                                                      child: Column(
                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                        children: [
                                                                          // Divider(color: Colors.black, height: 2,),
                                                                          // SizedBox(height: 15,),
                                                                          GestureDetector(
                                                                            onTap: () {
                                                                              launch("tel://${demande.contactClient ?? ""}");
                                                                            },
                                                                            child: InfoItemWidget(
                                                                              iconData: Icons.phone,
                                                                              title: "Contact Client :",
                                                                              description: demande.contactClient ?? "",
                                                                              iconEnd: Padding(
                                                                                padding: const EdgeInsets.only(right: 5),
                                                                                child: FaIcon(
                                                                                  FontAwesomeIcons.phoneVolume,
                                                                                  size: 22,
                                                                                  color: Tools.colorPrimary,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                            height: 20.0,
                                                                          ),

                                                                          InfoItemWidget(
                                                                            iconData: Icons.list,
                                                                            title: "Type :",
                                                                            description: demande.typeDemande ?? "",
                                                                          ),
                                                                          SizedBox(
                                                                            height: 20.0,
                                                                          ),

                                                                          InfoItemWidget(
                                                                            iconData: Icons.location_city_sharp,
                                                                            icon: FaIcon(
                                                                              FontAwesomeIcons.city,
                                                                              size: 18,
                                                                            ),
                                                                            title: "Ville :",
                                                                            description: demande.ville ?? "",
                                                                          ),
                                                                          SizedBox(
                                                                            height: 20.0,
                                                                          ),

                                                                          InfoItemWidget(
                                                                            iconData: Icons.list_alt,
                                                                            icon: FaIcon(
                                                                              FontAwesomeIcons.signHanging,
                                                                              size: 18,
                                                                            ),
                                                                            title: "Plaque :",
                                                                            description: demande.plaqueName ?? "",
                                                                          ),
                                                                          SizedBox(
                                                                            height: 20.0,
                                                                          ),

                                                                          InfoItemWidget(
                                                                            iconData: Icons.list_alt,
                                                                            icon: FaIcon(
                                                                              FontAwesomeIcons.projectDiagram,
                                                                              size: 18,
                                                                            ),
                                                                            title: "Login SIP :",
                                                                            description: demande.loginSip ?? "",
                                                                          ),
                                                                          SizedBox(
                                                                            height: 20.0,
                                                                          ),

                                                                          InfoItemWidget(
                                                                            iconData: Icons.list_alt,
                                                                            icon: FaIcon(
                                                                              FontAwesomeIcons.lightbulb,
                                                                              size: 18,
                                                                            ),
                                                                            title: "Opportunité :",
                                                                            description: demande.sousTypeOpportunite ?? "",
                                                                          ),
                                                                          SizedBox(
                                                                            height: 20.0,
                                                                          ),

                                                                          InfoItemWidget(
                                                                            iconData: Icons.list_alt,
                                                                            icon: FaIcon(
                                                                              FontAwesomeIcons.boxOpen,
                                                                              size: 18,
                                                                            ),
                                                                            title: "Portabilité :",
                                                                            description: demande.loginSip ?? "",
                                                                          ),
                                                                          SizedBox(
                                                                            height: 20.0,
                                                                          ),

                                                                          InfoItemWidget(
                                                                            iconData: Icons.edit_attributes_sharp,
                                                                            title: "Etat :",
                                                                            description: demande.etatName ?? "",
                                                                          ),
                                                                          SizedBox(
                                                                            height: 20.0,
                                                                          ),
                                                                          InfoItemWidget(
                                                                            iconData: Icons.phone_android,
                                                                            icon: FaIcon(
                                                                              FontAwesomeIcons.sitemap,
                                                                              size: 18,
                                                                            ),
                                                                            title: "Login internet :",
                                                                            description: Tools.selectedDemande?.loginInternet ?? "",
                                                                            iconEnd:  GestureDetector(
                                                                              onTap: () async {
                                                                                await Clipboard.setData(ClipboardData(text: Tools.selectedDemande?.loginInternet ?? ""));
                                                                              },
                                                                              child: Padding(
                                                                                padding: const EdgeInsets.only(right: 5),
                                                                                child: FaIcon(
                                                                                  FontAwesomeIcons.copy,
                                                                                  size: 22,
                                                                                  color: Tools.colorPrimary,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                            height: 20.0,
                                                                          ),
                                                                          Divider(),
                                                                          SizedBox(
                                                                            height: 20.0,
                                                                          ),
                                                                          Row(
                                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                                            children: [
                                                                              Column(
                                                                                children: [
                                                                                  ElevatedButton(
                                                                                    child: Icon(Icons.remove_red_eye, size: 20),
                                                                                    onPressed: () {
                                                                                      Tools.selectedDemande = demande;
                                                                                      Tools.currentStep = (Tools.selectedDemande?.etape ?? 1) -1 ;

                                                                                      navigator.push(MaterialPageRoute(
                                                                                        builder: (_) => DetailIntervention(),
                                                                                      ));
                                                                                    },
                                                                                    style: ElevatedButton.styleFrom(
                                                                                      fixedSize: const Size(10, 10),
                                                                                      shape: const CircleBorder(),
                                                                                    ),
                                                                                  ),
                                                                                  Text("Voir")
                                                                                ],
                                                                              ),

                                                                              Column(
                                                                                children: [
                                                                                  ElevatedButton(
                                                                                    child:
                                                                                    FaIcon(FontAwesomeIcons.screwdriver, size: 20),
                                                                                    onPressed: () {
                                                                                      Tools.selectedDemande = demande;
                                                                                      Tools.currentStep = (Tools.selectedDemande?.etape ?? 1) -1 ;
                                                                                      print("currentStepValueNotifier updateValue => ${Tools.currentStep} ");
                                                                                      currentStepValueNotifier.value = Tools.currentStep ;

                                                                                      print(
                                                                                          "Tools.selectedDemande => ${Tools.selectedDemande?.toJson()}");

                                                                                      // if(demande.etatId == "3"
                                                                                      //     && demande.pPbiAvant != ""
                                                                                      //     && demande.pPbiApres != ""){
                                                                                      //   // Navigator.of(context).push(MaterialPageRoute(
                                                                                      //   //   builder: (_) => InterventionFormStep2(),
                                                                                      //   // ));
                                                                                      //   Tools.currentStep = 1 ;
                                                                                      // }else{
                                                                                      //   // Navigator.of(context).push(MaterialPageRoute(
                                                                                      //   //   builder: (_) => InterventionFormStep1(),
                                                                                      //   // ));
                                                                                      //   Tools.currentStep = 0 ;
                                                                                      //
                                                                                      // }

                                                                                      // FormBlocState.currentStep = Tools.currentStep ;

                                                                                      navigator.push(MaterialPageRoute(
                                                                                        builder: (_) => WizardForm(),
                                                                                      ));
                                                                                    },
                                                                                    style: ElevatedButton.styleFrom(
                                                                                      fixedSize: const Size(10, 10),
                                                                                      shape: const CircleBorder(),
                                                                                    ),
                                                                                  ),
                                                                                  Text("Intervention")
                                                                                ],
                                                                              ),
                                                                              // Column(
                                                                              //   children: [
                                                                              //     ElevatedButton(
                                                                              //         child: Icon(Icons.edit, size: 20),
                                                                              //         onPressed: () {
                                                                              //           Tools.selectedDemande = demande ;
                                                                              //
                                                                              //         },
                                                                              //         style: ElevatedButton.styleFrom(
                                                                              //             fixedSize: const Size(10, 10),
                                                                              //             shape: const CircleBorder(),
                                                                              //       ),
                                                                              //     ),
                                                                              //     Text("Modifier")
                                                                              //
                                                                              //   ],
                                                                              // ),
                                                                            ],
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    )),
                                                              ),
                                                              SizedBox(
                                                                height: 5.0,
                                                              ),
                                                            ],
                                                          )),
                                                    )
                                                  );
                                                },
                                              ),
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
              BlocBuilder<InternetCubit, InternetState>(
                buildWhen: (previous, current) {
                  print("**** buildWhen *** ");
                  print("previous ==>  ${previous} ");
                  print("current ==>  ${current} ");
                  return previous != current;
                },
                builder: (context, state) {
                  print("BlocBuilder **** InternetCubit ${state}");
                  if (state is InternetConnected &&
                      state.connectionType == ConnectionType.wifi) {
                    // return Text(
                    //   'Wifi',
                    //   style: TextStyle(color: Colors.green, fontSize: 30),
                    // );
                  } else if (state is InternetConnected &&
                      state.connectionType == ConnectionType.mobile) {
                    // return Text(
                    //   'Mobile',
                    //   style: TextStyle(color: Colors.yellow, fontSize: 30),
                    // );
                  } else if (state is InternetDisconnected) {

                    return Positioned(
                      bottom: 0,
                      child: Center(
                        child: Container(
                          color: Colors.grey.shade400,
                          width: MediaQuery.of(context).size.width,
                          padding: const EdgeInsets.all(0.0),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "Pas d'accès internet",
                                style: TextStyle(
                                    color: Colors.red, fontSize: 20),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                  // return CircularProgressIndicator();
                  return Container();
                },
              ),

            ],
          ),
        ),
      ),
    );
  }

  Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    print("Handling a background message: ${message.messageId}");
    // Tools.getDemandes();
    final items = await Tools.getDemandes();

    setState(() {
      Tools.demandesListSaved = items;
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
          Tools.demandesListSaved = items;
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
        Tools.demandesListSaved = items;
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
        Tools.demandesListSaved = items;
        demandesList = items;
      });
    });
  }

  @override
  void initState() {
    // WidgetsBinding.instance.addObserver(this);
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
      Tools.demandesListSaved = items;
      demandesList = items;
    });
  }

  Future<void> _refreshList() async {
    var items = await Tools.getListDemandeFromLocalAndINternet();
    Tools.demandesListSaved = items;


    if (Tools.showDemandesEnAttentes) {
      items = ResponseGetDemandesList(
          demandes: Tools.demandesListSaved?.demandes?.where((element) {
            return  (["6", "9"].contains(element.etatId) &&
                (element.speed?.isEmpty == true) &&
                (element.speed?.isEmpty == true));
          }).toList());
    }

    // setState(() {
    //   demandesList = items;
    // });

    filterListByMap();

  }

  Future<void> filterListByCLient(String client) async {
    final items = ResponseGetDemandesList(
        demandes: Tools.demandesListSaved?.demandes?.where((element) {
      print("check ${element.client}");
      return element.client?.toLowerCase().contains(client.toLowerCase()) ??
          false;
    }).toList());
    setState(() {
      demandesList = items;
    });
  }

  Future<void> filterListByMap() async {
    print("call function filterListByMap()");
    String filter_client = Tools.searchFilter?["client"] ?? "";
    String filter_offre = Tools.searchFilter?["offre"] ?? "";
    String filter_typeDemande = Tools.searchFilter?["typeDemande"] ?? "";
    String filter_contactClient = Tools.searchFilter?["contactClient"] ?? "";

    final items = ResponseGetDemandesList(
        demandes: Tools.demandesListSaved?.demandes?.where((element) {
      print("check ${element.client}");

      bool shouldAdd = true;

      if (Tools.showDemandesEnAttentes) {
        shouldAdd = (["6", "9"].contains(element.etatId) &&
            (element.speed?.isEmpty == true) &&
            (element.speed?.isEmpty == true));
      }

      if (filter_client.isNotNullOrEmpty) {
        if (element.client
                ?.toLowerCase()
                .contains(filter_client.toLowerCase()) ??
            false) {
        } else {
          shouldAdd = false;
        }
      }

      if (filter_offre.isNotNullOrEmpty) {
        if (element.offre?.toLowerCase().contains(filter_offre.toLowerCase()) ??
            false) {
        } else {
          shouldAdd = false;
        }
      }

      if (filter_typeDemande.isNotNullOrEmpty) {
        if (element.typeDemande
                ?.toLowerCase()
                .contains(filter_typeDemande.toLowerCase()) ??
            false) {
        } else {
          shouldAdd = false;
        }
      }

      if (filter_contactClient.isNotNullOrEmpty) {
        if (element.contactClient
                ?.toLowerCase()
                .contains(filter_contactClient.toLowerCase()) ??
            false) {
        } else {
          shouldAdd = false;
        }
      }

      return shouldAdd;
    }).toList());

    setState(() {
      demandesList = items;
    });
  }

  Future<void> filterByType() async {
    final items = ResponseGetDemandesList(
        demandes: Tools.demandesListSaved?.demandes?.where((element) {
      if (Tools.showDemandesEnAttentes) {
        return (["6", "9"].contains(element.etatId) &&
            (element.speed?.isEmpty == true) &&
            (element.speed?.isEmpty == true));
      } else {
        return true;
      }
    }).toList());

    // setState(() {
    //   demandesList = items;
    // });

    filterListByMap();
  }

  String getTitle() {
    if (Tools.showDemandesEnAttentes) {
      return " Demandes en attentes (${Tools.demandesListSaved?.demandes?.where((element) {
        return (["6", "9"].contains(element.etatId) &&
            (element.speed?.isEmpty == true) &&
            (element.speed?.isEmpty == true));
      }).length})";
    }

    return "Liste demandes (${Tools.demandesListSaved?.demandes?.length ?? 0})";
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
            // image: DecorationImage(
            //   image: AssetImage("assets/bg_home.jpeg"),
            //   fit: BoxFit.cover,
            // ),
            color: Tools.colorBackground
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Text("Filter"),
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
      name: "client", initialValue: Tools.searchFilter?["client"] ?? "");
  final offre = TextFieldBloc(
      name: "offre", initialValue: Tools.searchFilter?["offre"] ?? "");
  final typeDemande = TextFieldBloc(
      name: "typeDemande",
      initialValue: Tools.searchFilter?["typeDemande"] ?? "");
  final contactClient = TextFieldBloc(
      name: "contactClient",
      initialValue: Tools.searchFilter?["contactClient"] ?? "");

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
    print("onSubmitting async");

    try {
      Map<String, dynamic> jsonResult = state.toJson();
      print("jsonResult ==> ${jsonResult}");
      Tools.searchFilter = jsonResult;
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
    return  Theme(
      data: Theme.of(context).copyWith(
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      child: BlocProvider(
        create: (context) => SearchFIeldsFormBloc(),
        child: Builder(
          builder: (context) {
            final formBloc = BlocProvider.of<SearchFIeldsFormBloc>(context);

            return FormBlocListener<SearchFIeldsFormBloc, String, String>(
              onSubmitting: (context, state) {
                print(" SearchFieldFormWidget onSubmitting");

                LoadingDialog.show(context);
              },
              onSuccess: (context, state) {
                print(" SearchFieldFormWidget onSuccess");

                LoadingDialog.hide(context);

                // Navigator.of(context).pushReplacement(
                //     MaterialPageRoute(builder: (_) => const SuccessScreen()));

                Navigator.of(context).pop();

                // filterListByCLient(_searchController.value.text);
              },
              onFailure: (context, state) {
                print(" SearchFieldFormWidget onFailure");

                LoadingDialog.hide(context);
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.failureResponse!)));
              },
              onSubmissionFailed: (context, state) {
                print(" SearchFieldFormWidget onSubmissionFailed " + state.toString());

                LoadingDialog.hide(context);
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text("onSubmissionFailed")));
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
                            padding: const EdgeInsets.only(top: 10, left: 12),
                            child: FaIcon(
                              FontAwesomeIcons.solidUser,
                            ),
                          ),
                        ),
                      ),
                      TextFieldBlocBuilder(
                        textFieldBloc: formBloc.offre,
                        decoration: const InputDecoration(
                          labelText: 'Offre',
                          prefixIcon: Padding(
                            padding: const EdgeInsets.only(top: 10, left: 12),
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
                            padding: const EdgeInsets.only(top: 10, left: 12),
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
                            padding: const EdgeInsets.only(top: 10, left: 12),
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
                          label: const Text(
                            'Filtrer',
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
      ),
    );
  }
}
