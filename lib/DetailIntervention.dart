import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:dio/dio.dart';
import 'package:expand_widget/expand_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:im_stepper/stepper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';
import 'package:telcabo/Tools.dart';
import 'package:telcabo/custome/ConnectivityCheckBlocBuilder.dart';
import 'package:telcabo/custome/ImageFieldBlocbuilder.dart';
import 'package:telcabo/custome/QrScannerTextFieldBlocBuilder.dart';
import 'package:telcabo/custome/SearchableDropDownFieldBlocBuilder.dart';
import 'package:telcabo/models/response_get_demandes.dart';
import 'package:telcabo/models/response_get_liste_etats.dart';
import 'dart:convert';

import 'dart:developer' as developer;

import 'package:flutter/services.dart';
import 'package:telcabo/models/response_get_liste_types.dart';
import 'package:telcabo/ui/InterventionHeaderInfoWidget.dart';
import 'package:timelines/timelines.dart';

import 'InterventionFormStep2.dart';
import 'NotificationExample.dart';
// import 'package:http/http.dart' as http;

import 'package:collection/collection.dart';

class DetailIntervention extends StatefulWidget {
  @override
  State<DetailIntervention> createState() => _DetailInterventionState();
}

class _DetailInterventionState extends State<DetailIntervention> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        title: Text('Detail'),
        actions: <Widget>[

        ],
      ),
      // endDrawer: EndDrawerWidget(),
      body: Scrollbar(
        child: SingleChildScrollView(
          child: Container(
            child: Column(
              children: [
                SizedBox(
                  height: 20,
                ),
                InterventionHeaderInfoClientWidget(),
                SizedBox(
                  height: 20,
                ),
                Divider(
                  color: Colors.black,
                  height: 2,
                ),
                SizedBox(
                  height: 20,
                ),
                InterventionHeaderInfoProjectWidget(),
                SizedBox(
                  height: 20,
                ),

               // Container(
               //      height: 500,
               //      child: Expanded(
               //        child: ExpandChild(
               //          child: PhotoViewGallery.builder(
               //            scrollPhysics: const BouncingScrollPhysics(),
               //            builder: (BuildContext context, int index) {
               //              return PhotoViewGalleryPageOptions(
               //                imageProvider: CachedNetworkImageProvider(
               //                    "https://telcabo.castlit.com/img/demandes/" +
               //                        (Tools.selectedDemande?.pPbiAvant ?? "")),
               //                initialScale:
               //                    PhotoViewComputedScale.contained * 0.8,
               //                heroAttributes:
               //                    PhotoViewHeroAttributes(tag: "pPbiAvant"),
               //              );
               //            },
               //            itemCount: 4,
               //            loadingBuilder: (context, event) => Center(
               //              child: Container(
               //                width: 20.0,
               //                height: 20.0,
               //                child: CircularProgressIndicator(
               //                  value: event == null
               //                      ? 0
               //                      : (event.cumulativeBytesLoaded /
               //                              (event.expectedTotalBytes ?? 1)) ??
               //                          0,
               //                ),
               //              ),
               //            ),
               //            // backgroundDecoration: widget.backgroundDecoration,
               //            // pageController: widget.pageController,
               //            // onPageChanged: onPageChanged,
               //          ),
               //        ),
               //      ))

                InterventionInformationWidget(),
                SizedBox(
                  height: 20,
                ),


                InterventionHeaderImagesWidget(),
                SizedBox(
                  height: 20,
                ),
                MapSample(),
                SizedBox(
                  height: 20,
                ),

                HeaderCommentaireWidget(),
                SizedBox(
                  height: 20,
                ),


              ],
            ),
          ),
        ),
      ),
    );
  }
}
