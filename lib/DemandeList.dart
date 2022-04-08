import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dartx/dartx.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
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
import 'package:telcabo/LoginWidget.dart';
import 'package:telcabo/Tools.dart';
import 'package:telcabo/custome/ConnectivityCheckBlocBuilder.dart';
import 'package:telcabo/custome/ImageFieldBlocbuilder.dart';
import 'package:telcabo/models/response_get_demandes.dart';
import 'package:telcabo/models/response_get_liste_etats.dart';
import 'dart:convert';

import 'dart:developer' as developer;

import 'package:flutter/services.dart';
import 'package:telcabo/ui/InterventionHeaderInfoWidget.dart';



class DemandeList extends StatefulWidget {

  @override
  State<DemandeList> createState() => _DemandeListState();
}

class _DemandeListState extends State<DemandeList> {

  @override
  void initState() {
    Tools.initFiles();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Tools.colorPrimary,
      body: Column(
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
                  Navigator.pop(context);
                },
              ),
             ElevatedButton.icon(onPressed: (){
                
             }, icon: Icon(Icons.logout), label: Text("Se Deconnecter"))
            ],
          ),
          SizedBox(height: 20.0),

          Container(
            height: MediaQuery.of(context).size.height - 185.0,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(75.0)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(children: <Widget>[
                FormBuilderTextField(
                  name: 'fullName',
                  decoration: InputDecoration(
                    labelText: 'Nom client'.tr().capitalize(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  onChanged: (value) {},
                  // valueTransformer: (text) => num.tryParse(text),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(context),
                    // FormBuilderValidators.numeric(context),
                    // FormBuilderValidators.max(context, 70),
                  ]),
                  keyboardType: TextInputType.text,
                ),
                SizedBox(
                  height: 20,
                ),
                TextButton.icon(
                  icon: Icon(Icons.search),
                  label: Text('search'.tr().capitalize()),
                  style: TextButton.styleFrom(

                    minimumSize: Size(500, 50),
                    primary: Colors.white,
                    backgroundColor: Tools.colorPrimary,
                    // shape: const BeveledRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                  ),
                  onPressed: () {

                  },
                ),
                Expanded(
                  child: Container(
                    height: MediaQuery.of(context).size.height,
                    child: FutureBuilder<ResponseGetDemandesList>(
                      future: Tools.getListDemandeFromLocalAndINternet(), // a previously-obtained Future<String> or null
                      builder: (BuildContext context, AsyncSnapshot<ResponseGetDemandesList> snapshot) {
                        List<Widget> children;
                        if (snapshot.hasData) {
                          return ListView.builder(
                            // Let the ListView know how many items it needs to build.
                            itemCount: snapshot.data?.demandes?.length  ?? 0,
                            // Provide a builder function. This is where the magic happens.
                            // Convert each item into a widget based on the type of item it is.
                            itemBuilder: (context, index) {
                              final item = snapshot.data?.demandes?[index];

                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: DemandeListItem(demande: item!,),
                              );
                            },);
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                  size: 60,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 16),
                                  child: Text('Error: ${snapshot.error}'),
                                )
                              ],
                            ),
                          );

                        } else {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 60,
                                  height: 60,
                                  child: CircularProgressIndicator(),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 16),
                                  child: Text('résultat en attente...'),
                                )
                              ],
                            ),
                          );

                        }

                      },
                    ),
                  ),
                ),
              ]),
            ),
          )
        ],
      ),
    );

    return Scaffold(


      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.fromLTRB(0, 50.0, 0, 20.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(15.0),
                  bottomRight: Radius.circular(15.0),
                ),
                color: Tools.colorPrimary,
              ),
              child: TextButton.icon(
                icon:  Icon(
                  Icons.menu,
                  color: Colors.white,
                  size: 25,
                ),
                label: Container(
                  width: double.infinity,
                  child: Text("Liste demandes".tr().capitalize(),
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0
                    ),),
                ),
                onPressed: () {
                  // Navigator.pop ;
                  // Navigator.pop(context);
                },
              ),
            ),

            Container(
              height: MediaQuery.of(context).size.height,
              child: FutureBuilder<ResponseGetDemandesList>(
                future: Tools.getListDemandeFromLocalAndINternet(), // a previously-obtained Future<String> or null
                builder: (BuildContext context, AsyncSnapshot<ResponseGetDemandesList> snapshot) {
                  List<Widget> children;
                  if (snapshot.hasData) {
                    return ListView.builder(
                      // Let the ListView know how many items it needs to build.
                      itemCount: snapshot.data?.demandes?.length  ?? 0,
                      // Provide a builder function. This is where the magic happens.
                      // Convert each item into a widget based on the type of item it is.
                      itemBuilder: (context, index) {
                        final item = snapshot.data?.demandes?[index];

                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: DemandeListItem(demande: item!,),
                        );
                      },);
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 60,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Text('Error: ${snapshot.error}'),
                          )
                        ],
                      ),
                    );

                  } else {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 60,
                            height: 60,
                            child: CircularProgressIndicator(),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 16),
                            child: Text('résultat en attente...'),
                          )
                        ],
                      ),
                    );

                  }

                },
              ),
            ),

          ],
        ),
      ),
    );
  }


}


