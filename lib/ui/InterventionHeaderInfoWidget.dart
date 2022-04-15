
import 'dart:io';

import 'package:expand_widget/expand_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:telcabo/FormStepper.dart';
import 'package:telcabo/InterventionFormStep2.dart';
import 'package:telcabo/InterventionWidgetStep1.dart';
import 'package:telcabo/Tools.dart';
import 'package:telcabo/models/response_get_demandes.dart';
import 'package:telcabo/models/response_get_liste_etats.dart';


class DemandeListItem extends StatelessWidget {

  final Demandes demande ;

  const DemandeListItem({Key? key, required this.demande}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
          border: Border.all(
            color: Colors.transparent,
            // style: BorderStyle.values
          ),
          boxShadow: [
            BoxShadow(
              color: getColorByEtatId(int.parse(demande.etatId ?? "0")).withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 1,
              offset: Offset(1,0), // changes position of shadow
            ),
          ],

          borderRadius: BorderRadius.circular(20) // use instead of BorderRadius.all(Radius.circular(20))
      ),
      child: Center(
          child:Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: double.infinity,
                height: 65,
                decoration: BoxDecoration(
                    color: getColorByEtatId(int.parse(demande.etatId ?? "0")),
                    border: Border.all(
                      color: Colors.transparent,
                    ),
                    borderRadius: BorderRadius.circular(20) // use instead of BorderRadius.all(Radius.circular(20))
                ),
                child: Row(
                    children: [
                      SizedBox(height: 5.0,),
                      // CircleAvatar(
                      //   radius: 32.0,
                      //   backgroundImage: AssetImage('assets/user.png'),
                      //   backgroundColor: Colors.white,
                      // ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Icon(Icons.person, size: 22,),
                      ),
                      Container(
                        width: 200,
                        child: Text('${demande.client}',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color:Colors.black,
                              fontSize: 16.0,
                            )),
                      ),

                      Spacer(),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [


                          GestureDetector(
                             onTap: () {
                               Tools.selectedDemande = demande ;
                                   print("Tools.selectedDemande => ${Tools.selectedDemande?.toJson()}");

                                   if(demande.etatId == "3"
                                       && demande.pPbiAvant != ""
                                       && demande.pPbiApres != ""){
                                     // Navigator.of(context).push(MaterialPageRoute(
                                     //   builder: (_) => InterventionFormStep2(),
                                     // ));
                                     Tools.currentStep = 1 ;
                                   }else{
                                     // Navigator.of(context).push(MaterialPageRoute(
                                     //   builder: (_) => InterventionFormStep1(),
                                     // ));
                                     Tools.currentStep = 0 ;

                                   }

                                   // FormBlocState.currentStep = Tools.currentStep ;

                                   Navigator.of(context).push(MaterialPageRoute(
                                     builder: (_) => WizardForm(),
                                   ));

                            },
                            child: Tooltip(
                              message: "Intervention",
                              child: Container(

                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                    color: Tools.colorPrimary,
                                    shape: BoxShape.circle
                                ),
                                child: Center(child: FaIcon(FontAwesomeIcons.solidEye, color: Colors.white, size: 15,)),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Tools.selectedDemande = demande ;
                              print("Tools.selectedDemande => ${Tools.selectedDemande?.toJson()}");

                              if(demande.etatId == "3"
                                  && demande.pPbiAvant != ""
                                  && demande.pPbiApres != ""){
                                // Navigator.of(context).push(MaterialPageRoute(
                                //   builder: (_) => InterventionFormStep2(),
                                // ));
                                Tools.currentStep = 1 ;
                              }else{
                                // Navigator.of(context).push(MaterialPageRoute(
                                //   builder: (_) => InterventionFormStep1(),
                                // ));
                                Tools.currentStep = 0 ;

                              }

                              // FormBlocState.currentStep = Tools.currentStep ;

                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => WizardForm(),
                              ));

                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8 ),
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                    color: Tools.colorPrimary,
                                    shape: BoxShape.circle
                                ),
                                child: Center(child: FaIcon(FontAwesomeIcons.screwdriver, color: Colors.white, size: 15,)),
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

                    ]
                ),
              ),
              ExpandChild(
                arrowSize: 25,
                arrowPadding: EdgeInsets.all(0) ,
                child: Container(
                  // color: Colors.white,
                    child: Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Divider(color: Colors.black, height: 2,),
                          // SizedBox(height: 15,),
                          InfoItemWidget(
                            iconData: Icons.phone,
                            title: "Contact CLient :",
                            description: demande.contactClient ?? "",
                          ),
                          SizedBox(height: 20.0,),


                          InfoItemWidget(
                            iconData: Icons.list,
                            title: "Type :",
                            description: demande.typeDemande ?? "",
                          ),
                          SizedBox(height: 20.0,),

                          InfoItemWidget(
                            iconData: Icons.location_city_sharp,
                            title: "Type :",
                            description: demande.ville ?? "",
                          ),
                          SizedBox(height: 20.0,),

                          InfoItemWidget(
                            iconData: Icons.list_alt,
                            title: "PLaque :",
                            description: demande.plaqueName ?? "",
                          ),
                          SizedBox(height: 20.0,),

                          InfoItemWidget(
                            iconData: Icons.list_alt,
                            title: "Login SIP :",
                            description: demande.loginSip ?? "",
                          ),
                          SizedBox(height: 20.0,),

                          InfoItemWidget(
                            iconData: Icons.list_alt,
                            title: "Opportunité :",
                            description: demande.sousTypeOpportunite ?? "",
                          ),
                          SizedBox(height: 20.0,),

                          InfoItemWidget(
                            iconData: Icons.list_alt,
                            title: "Portabilité :",
                            description: demande.loginSip ?? "",
                          ),
                          SizedBox(height: 20.0,),

                          InfoItemWidget(
                            iconData: Icons.edit_attributes_sharp,
                            title: "Etat :",
                            description: demande.etatName ?? "",
                          ),

                          SizedBox(height: 20.0,),
                          Divider(),
                          SizedBox(height: 20.0,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                children: [
                                  ElevatedButton(
                                    child: Icon(Icons.remove_red_eye, size: 20),
                                    onPressed: () {
                                      Tools.selectedDemande = demande ;

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
                                    child: FaIcon(FontAwesomeIcons.screwdriver, size: 20),
                                    onPressed: () {
                                      Tools.selectedDemande = demande ;
                                      print("Tools.selectedDemande => ${Tools.selectedDemande?.toJson()}");

                                      if(demande.etatId == "3"
                                          && demande.pPbiAvant != ""
                                          && demande.pPbiApres != ""){
                                        // Navigator.of(context).push(MaterialPageRoute(
                                        //   builder: (_) => InterventionFormStep2(),
                                        // ));
                                        Tools.currentStep = 1 ;
                                      }else{
                                        // Navigator.of(context).push(MaterialPageRoute(
                                        //   builder: (_) => InterventionFormStep1(),
                                        // ));
                                        Tools.currentStep = 0 ;

                                      }

                                      // FormBlocState.currentStep = Tools.currentStep ;

                                      Navigator.of(context).push(MaterialPageRoute(
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
                    )
                ),
              ),
              SizedBox(height: 5.0,),

            ],
          )
      ),
    );
  }

  getColorByEtatId(int etatId) {
    if(Tools.arr_d.contains(etatId)){
      return Colors.red ;
    }else  if(Tools.arr_s.contains(etatId)){
      return Colors.green ;

    }else if(Tools.arr_w.contains(etatId)){
      return Colors.orange ;
    }

    return Colors.transparent ;

  }


}

class InterventionHeaderInfoClientWidget extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 20.0, right: 20.0),
      decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black,
          ),
          borderRadius: BorderRadius.circular(20) // use instead of BorderRadius.all(Radius.circular(20))
      ),
      child: Center(
          child:Column(
            children: [
              Column(
                  children: [
                    SizedBox(height: 15.0,),
                    // CircleAvatar(
                    //   radius: 32.0,
                    //   backgroundImage: AssetImage('assets/user.png'),
                    //   backgroundColor: Colors.white,
                    // ),
                    ElevatedButton(
                      onPressed: () async {
                      },
                      style: ElevatedButton.styleFrom(
                        // primary: Tools.colorPrimary,
                        shape: CircleBorder(),
                        padding: EdgeInsets.all(10),
                      ),
                      child: const Icon(Icons.person, size: 40,),
                    ),
                    SizedBox(height: 12,),
                    Text('Client : ${Tools.selectedDemande?.client}',
                        style: TextStyle(
                          color:Colors.black,
                          fontSize: 16.0,
                        )),

                  ]
              ),
              ExpandChild(
                child: Container(
                  // color: Colors.white,
                    child: Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Divider(color: Colors.black, height: 2,),
                          SizedBox(height: 15,),
                          InfoItemWidget(
                            iconData: Icons.circle,
                            title: "Offre :",
                            description: Tools.selectedDemande?.offre ?? "",
                          ),
                          SizedBox(height: 20.0,),
                          InfoItemWidget(
                            iconData: Icons.phone,
                            title: "Téléphone :",
                            description: Tools.selectedDemande?.contactClient ?? "",
                          ),

                          SizedBox(height: 20.0,),
                          InfoItemWidget(
                            iconData: Icons.phone_android,
                            title: "Numéro de la personne mandatée :",
                            description: Tools.selectedDemande?.numPersMandatee ?? "",
                          ),

                          SizedBox(height: 20.0,),
                          InfoItemWidget(
                            iconData: Icons.person_pin_outlined  ,
                            title: "Nom de la personne mandatée :",
                            description: Tools.selectedDemande?.nomPerMandatee ?? "",
                          ),
                          SizedBox(height: 20.0,),
                          InfoItemWidget(
                            iconData: Icons.person_pin_outlined  ,
                            title: "Type logement :",
                            description: Tools.selectedDemande?.typeLogement ?? "",
                          ),
                          SizedBox(height: 20.0,),
                          InfoItemWidget(
                            iconData: Icons.location_on  ,
                            title: "Adresse :",
                            description: Tools.selectedDemande?.adresseInstallation ?? "",
                          ),
                          SizedBox(height: 20.0,),

                        ],
                      ),
                    )
                ),
              ),
            ],
          )
      ),
    );
  }


}


class InterventionHeaderInfoProjectWidget extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 20.0, right: 20.0),
      decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black,
          ),
          borderRadius: BorderRadius.circular(20) // use instead of BorderRadius.all(Radius.circular(20))
      ),
      child: Center(
          child:Column(
            children: [
              Column(
                  children: [
                    SizedBox(height: 15.0,),
                    // CircleAvatar(
                    //   radius: 32.0,
                    //   backgroundImage: AssetImage('assets/user.png'),
                    //   backgroundColor: Colors.white,
                    // ),
                    ElevatedButton(
                      onPressed: () async {
                      },
                      style: ElevatedButton.styleFrom(
                        // primary: Tools.colorPrimary,
                        shape: CircleBorder(),
                        padding: EdgeInsets.all(10),
                      ),
                      child: const Icon(Icons.receipt, size: 40,),
                    ),
                    SizedBox(height: 12,),
                    Center(
                      child: Text('Projet : ${Tools.selectedDemande?.projet}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color:Colors.black,
                            fontSize: 16.0,

                          )),
                    ),

                  ]
              ),
              ExpandChild(
                child: Container(
                  // color: Colors.white,
                    child: Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Divider(color: Colors.black, height: 2,),
                          SizedBox(height: 15,),
                          InfoItemWidget(
                            iconData: Icons.circle,
                            title: "Type demande :",
                            description: Tools.selectedDemande?.typeDemande ?? "",
                          ),
                          SizedBox(height: 20.0,),
                          InfoItemWidget(
                            iconData: Icons.phone,
                            icon: FaIcon(FontAwesomeIcons.server, size: 18,),
                            title: "Equipements :",
                            description: Tools.selectedDemande?.equipements ?? "",
                          ),

                          SizedBox(height: 20.0,),
                          InfoItemWidget(
                            iconData: Icons.phone_android,
                            icon: FaIcon(FontAwesomeIcons.handHolding, size: 18,),
                            title: "Equipements Livré :",
                            description: Tools.selectedDemande?.equipementLivre ?? "",
                          ),
                          SizedBox(height: 20.0,),
                          InfoItemWidget(
                            iconData: Icons.phone_android,
                            icon: FaIcon(FontAwesomeIcons.inbox, size: 18,),
                            title: "Plan :",
                            description: Tools.selectedDemande?.plan ?? "",
                          ), SizedBox(height: 20.0,),
                          InfoItemWidget(
                            iconData: Icons.phone_android,
                            icon: FaIcon(FontAwesomeIcons.sitemap, size: 18,),
                            title: "Login internet :",
                            description: Tools.selectedDemande?.loginInternet ?? "",
                          ), SizedBox(height: 20.0,),
                          InfoItemWidget(
                            iconData: Icons.phone_android,
                            icon: FaIcon(FontAwesomeIcons.diagramProject, size: 18,),
                            title: "Login SIP :",
                            description: Tools.selectedDemande?.loginSip ?? "",
                          ), SizedBox(height: 20.0,),
                          InfoItemWidget(
                            iconData: Icons.phone_android,
                            icon: FaIcon(FontAwesomeIcons.boxOpen, size: 18,),
                            title: " Portabilité :",
                            description: Tools.selectedDemande?.portabilite ?? "",
                          ), SizedBox(height: 20.0,),
                          InfoItemWidget(
                            iconData: Icons.phone_android,
                            icon: FaIcon(FontAwesomeIcons.timeline, size: 18,),
                            title: "Sous type opportunite :",
                            description: Tools.selectedDemande?.sousTypeOpportunite ?? "",
                          ),
                        ],
                      ),
                    )
                ),
              ),
            ],
          )
      ),
    );
  }


}

class InfoItemWidget extends StatelessWidget {

  const InfoItemWidget({
    Key? key,
    required this.iconData,
    required this.title,
    required this.description,
    this.icon,
  }) : super(key: key);

  final IconData iconData;
  final String title;
  final String description;
  final Widget? icon;


  @override
  Widget build(BuildContext context) {

    return Container(
        child: Row(
          children: [
            Container(      margin: const EdgeInsets.only(right: 10.0)
                ,child: icon ?? Icon(iconData)),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                    style: TextStyle(
                      fontSize: 15.0,
                      color: Tools.colorPrimary,

                    ),),
                  SizedBox(height: 2,),
                  Text(description,
                    // maxLines: 1,
                    // overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16.0,
                    ),)
                ],
              ),
            ),
          ],
        ));



  }
}