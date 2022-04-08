
import 'dart:io';

import 'package:expand_widget/expand_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
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
      margin: const EdgeInsets.all(0),
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
                height: 120,
                decoration: BoxDecoration(
                    color: getColorByEtatId(int.parse(demande.etatId ?? "0")),
                    border: Border.all(
                      color: Colors.transparent,
                    ),
                    borderRadius: BorderRadius.circular(20) // use instead of BorderRadius.all(Radius.circular(20))
                ),
                child: Column(
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
                      Text('Client : ${demande.client}',
                          style: TextStyle(
                            color:Colors.black,
                            fontSize: 16.0,
                          )),

                    ]
                ),
              ),
              ExpandChild(
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
                            description: demande.plaqueId ?? "",
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
                            description: demande.etatId ?? "",
                          ),


                        ],
                      ),
                    )
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      ElevatedButton(
                          child: Icon(Icons.remove_red_eye, size: 20),
                          onPressed: () {},
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
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => InterventionFormStep1(),
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
                  Column(
                    children: [
                      ElevatedButton(
                          child: Icon(Icons.edit, size: 20),
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                              fixedSize: const Size(10, 10),
                              shape: const CircleBorder(),
                        ),
                      ),
                      Text("Modifier")

                    ],
                  ),
                ],
              ),
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
                    Text('Client : Said hassani',
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
                            description: "20 Méga fibre",
                          ),
                          SizedBox(height: 20.0,),
                          InfoItemWidget(
                            iconData: Icons.phone,
                            title: "Téléphone :",
                            description: "F0650558564",
                          ),

                          SizedBox(height: 20.0,),
                          InfoItemWidget(
                            iconData: Icons.phone_android,
                            title: "Numéro de la personne mandatée :",
                            description: "F0650558564",
                          ),

                          SizedBox(height: 20.0,),
                          InfoItemWidget(
                            iconData: Icons.person_pin_outlined  ,
                            title: "Nom de la personne mandatée :",
                            description: "nada salhi",
                          ),
                          SizedBox(height: 20.0,),
                          InfoItemWidget(
                            iconData: Icons.person_pin_outlined  ,
                            title: "Type logement :",
                            description: "Immeuble",
                          ),
                          SizedBox(height: 20.0,),
                          InfoItemWidget(
                            iconData: Icons.location_on  ,
                            title: "Adresse :",
                            description: "CASABLANCA MOSTAKBAL SIDIMAAROUF 190, Lotissement Mostakbal GH 23, 1er étage Apt 8, Casablanca.",
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
                    Text('Projet : 123test castle it 2022',
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
                            title: "Type demande :",
                            description: "Type-test",
                          ),
                          SizedBox(height: 20.0,),
                          InfoItemWidget(
                            iconData: Icons.phone,
                            title: "Equipements :",
                            description: "Routeur wifi dual bande ZTE 45154",
                          ),

                          SizedBox(height: 20.0,),
                          InfoItemWidget(
                            iconData: Icons.phone_android,
                            title: "Equipements Livré :",
                            description: "Non",
                          ),
                          SizedBox(height: 20.0,),
                          InfoItemWidget(
                            iconData: Icons.phone_android,
                            title: "Plan :",
                            description: "FTTH B2C",
                          ), SizedBox(height: 20.0,),
                          InfoItemWidget(
                            iconData: Icons.phone_android,
                            title: "Login internet :",
                            description: "00006988454",
                          ), SizedBox(height: 20.0,),
                          InfoItemWidget(
                            iconData: Icons.phone_android,
                            title: "Login SIP :",
                            description: "062515231564845",
                          ), SizedBox(height: 20.0,),
                          InfoItemWidget(
                            iconData: Icons.phone_android,
                            title: " Portabilité :",
                            description: "xxxxx",
                          ), SizedBox(height: 20.0,),
                          InfoItemWidget(
                            iconData: Icons.phone_android,
                            title: "  Sous type opportunite :",
                            description: "Nouvelle offre"
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
  }) : super(key: key);

  final IconData iconData;
  final String title;
  final String description;


  @override
  Widget build(BuildContext context) {

    return Container(
        child: Row(
          children: [
            Container(      margin: const EdgeInsets.only(right: 10.0)
                ,child: Icon(iconData)),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                    style: TextStyle(
                      fontSize: 13.0,
                      color: Colors.grey[400],

                    ),),
                  SizedBox(height: 2,),
                  Text(description,
                    // maxLines: 1,
                    // overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15.0,
                    ),)
                ],
              ),
            ),
          ],
        ));



  }
}