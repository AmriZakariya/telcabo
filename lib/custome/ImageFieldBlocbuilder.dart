import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image/image.dart' as imagePLugin;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stamp_image/stamp_image.dart';
import 'package:image_watermark/image_watermark.dart';
import 'package:telcabo/Tools.dart';

class ImageFieldBlocBuilder extends StatefulWidget {
  final InputFieldBloc<XFile?, Object> fileFieldBloc;
  final FormBloc formBloc;
  final Widget iconField;
  final String labelText;

  ImageFieldBlocBuilder({
    Key? key,
    required this.fileFieldBloc,
    required this.formBloc,
    required this.iconField,
    required this.labelText,
  })  : assert(fileFieldBloc != null),
        assert(formBloc != null),
        super(key: key);

  @override
  State<ImageFieldBlocBuilder> createState() => _ImageFieldBlocBuilderState();
}

class _ImageFieldBlocBuilderState extends State<ImageFieldBlocBuilder> {
  final ImagePicker _picker = ImagePicker();
  String imageSrc = "camera";

  @override
  Widget build(BuildContext context) {
    Future _showDialog() async {
      // XFile? image;
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            // title: Row(children: [
            //   // Image.asset(
            //   //   'assets/logo.png',
            //   //   width: 50,
            //   //   height: 50,
            //   //   fit: BoxFit.contain,
            //   // ),
            //   SizedBox(
            //     width: 10,
            //   ),
            //   Flexible(child: Text("image")),
            // ]),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Divider(),
                ElevatedButton.icon(
                  onPressed: () async {
                    // image = await _picker.pickImage(
                    //     source: ImageSource.camera, imageQuality: 50);

                    imageSrc = "camera";
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Caméra'),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    // image = await _picker.pickImage(
                    //     source: ImageSource.gallery, imageQuality: 50);

                    imageSrc = "gallery";
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.image_outlined),
                  label: const Text('Galerie'),
                ),
              ],
            ),
            actions: <Widget>[
              ElevatedButton.icon(
                onPressed: () async {
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.cancel),
                label: const Text('Annuler'),
              ),
            ],
          );
        },
      );
    }

    // return CanShowFieldBlocBuilder(
    //   fieldBloc: fileFieldBloc,
    //   // animate: false,
    //   builder: (_, __){
    //
    //   });

    return BlocBuilder<InputFieldBloc<XFile?, Object>,
        InputFieldBlocState<XFile?, Object>>(
      bloc: widget.fileFieldBloc,
      builder: (context, fieldBlocState) {
        return BlocBuilder<FormBloc, FormBlocState>(
          bloc: widget.formBloc,
          builder: (context, formBlocState) {
            return Visibility(
              visible: widget.formBloc.state
                      .fieldBlocs()
                      ?.containsKey(widget.fileFieldBloc.name) ??
                  true,
              child: Container(
                margin: const EdgeInsets.only(top: 20),
                child: Column(
                  children: <Widget>[
                    Text(widget.labelText),
                    SizedBox(
                      height: 10,
                    ),
                    Stack(
                      children: <Widget>[
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(60),
                          ),
                          margin: EdgeInsets.zero,
                          clipBehavior: Clip.antiAlias,
                          elevation: 10,
                          color: fieldBlocState.value != null
                              ? Colors.grey[700]
                              : fieldBlocState.canShowError
                                  ? Colors.red
                                  : Colors.white,
                          child: Opacity(
                              opacity: formBlocState.canSubmit ? 1 : 0.5,
                              child: fieldBlocState.value != null
                                  ? Container(
                                      width: 90,
                                      height: 90,
                                      child: Image.file(
                                        File(fieldBlocState.value?.path ?? ""),
                                        height: 90,
                                        width: 90,
                                        fit: BoxFit.fill,
                                      ),
                                    )
                                  : Container(
                                      width: 90,
                                      height: 90,
                                      child: Image.network(
                                        getImagePickerExistImageUrl(),
                                        width: 90,
                                        height: 90,
                                        fit: BoxFit.cover,
                                        loadingBuilder: (BuildContext context, Widget child,
                                            ImageChunkEvent? loadingProgress) {
                                          if (loadingProgress == null) return child;
                                          return Center(
                                            child: CircularProgressIndicator(
                                              value: loadingProgress.expectedTotalBytes != null
                                                  ? loadingProgress.cumulativeBytesLoaded /
                                                  loadingProgress.expectedTotalBytes!
                                                  : null,
                                            ),
                                          );
                                        },
                                        errorBuilder: (BuildContext context,
                                            Object error,
                                            StackTrace? stackTrace) {
                                          return Center(
                                            child: Container(
                                              child: Icon(Icons
                                                  .image_not_supported_outlined),
                                            ),
                                          );
                                        },
                                      ),
                                    )),
                        ),
                        Positioned.fill(
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              splashColor:
                                  Theme.of(context).accentColor.withAlpha(50),
                              highlightColor:
                                  Theme.of(context).accentColor.withAlpha(50),
                              borderRadius: BorderRadius.circular(60),
                              onTap: formBlocState.canSubmit
                                  ? () async {
                                      // final imageResult = await _showDialog();
                                      await _showDialog();

                                      var imageResult;
                                      if (imageSrc == "camera") {
                                        imageResult = await _picker.pickImage(
                                            source: ImageSource.camera,
                                            imageQuality: 50);
                                      } else {
                                        imageResult = await _picker.pickImage(
                                            source: ImageSource.gallery,
                                            imageQuality: 50);
                                      }

                                      final File fileResult =
                                          File(imageResult?.path ?? "");
                                      if (await fileResult.exists()) {
                                        widget.fileFieldBloc
                                            .updateValue(imageResult);

                                        // String currentAddress =  await _getAddressFromLatLng();
                                        // String currentDate =  DateTime.now().toString();
                                        // String fileName =  DateTime.now().millisecondsSinceEpoch.toString();
                                        //
                                        // print(currentDate);

                                        // var t = await fileResult.readAsBytes();
                                        // var imgBytes = Uint8List.fromList(t);
                                        // var watermarkedImgBytes =
                                        // await image_watermark.addTextWatermark(
                                        //   imgBytes,
                                        //   currentAddress, //watermark text
                                        //   0, //
                                        //   0,
                                        //   color: Colors.black, //default : Colors.white
                                        // );
                                        // await image_watermark.addTextWatermark(
                                        //   imgBytes,
                                        //   currentDate, //watermark text
                                        //   0, //
                                        //   30,
                                        //   color: Colors.black, //default : Colors.white
                                        // );

                                        // getApplicationDocumentsDirectory().then((Directory directory) async {
                                        //
                                        //
                                        //   final image = imagePLugin.decodeImage(fileResult.readAsBytesSync())!;
                                        //   imagePLugin.drawString(image, imagePLugin.arial_24, 0, 0, currentDate);
                                        //   imagePLugin.drawString(image, imagePLugin.arial_24, 0, 32, currentAddress);
                                        //
                                        //   File fileResultWithWatermark = File(directory.path +"/"+ fileName+'.png') ;
                                        //   fileResultWithWatermark.writeAsBytesSync(imagePLugin.encodePng(image));
                                        //
                                        //   // final buffer = imgBytes.buffer;
                                        //   // File fileResultWithWatermark = await File(directory.path +"/"+ currentDate+'.png').writeAsBytes(
                                        //   //     buffer.asUint8List(imgBytes.offsetInBytes, imgBytes.lengthInBytes));
                                        //
                                        //
                                        //   XFile xfileResult = XFile(fileResultWithWatermark.path);
                                        //   widget.fileFieldBloc.updateValue(xfileResult);
                                        //
                                        //
                                        // });

                                        // widget.fileFieldBloc.updateValue(imageResult);

                                        // StampImage.create(
                                        //   context: context,
                                        //   image: fileResult,
                                        //   children: [
                                        //     Positioned(
                                        //       bottom: 0,
                                        //       right: 0,
                                        //       child: Padding(
                                        //         padding:
                                        //             const EdgeInsets.all(10),
                                        //         child: Column(
                                        //           crossAxisAlignment:
                                        //               CrossAxisAlignment.end,
                                        //           children: [
                                        //             Text(
                                        //               DateTime.now().toString(),
                                        //               style: TextStyle(
                                        //                   color: Colors.white,
                                        //                   fontSize: 15),
                                        //             ),
                                        //             SizedBox(height: 5),
                                        //             Text(
                                        //               // await _getAddressFromLatLng(),
                                        //              "ee",
                                        //               maxLines: 2,
                                        //               overflow:
                                        //                   TextOverflow.ellipsis,
                                        //               style: TextStyle(
                                        //                 color: Colors.blue,
                                        //                 fontWeight:
                                        //                     FontWeight.bold,
                                        //                 fontSize: 15,
                                        //               ),
                                        //             ),
                                        //           ],
                                        //         ),
                                        //       ),
                                        //     ),
                                        //     // Positioned(
                                        //     //   top: 0,
                                        //     //   left: 0,
                                        //     //   child: _logoFlutter(),
                                        //     // )
                                        //   ],
                                        //   onSuccess: (fileResultStampImage) {
                                        //     print("StampImage onSuccess");
                                        //     XFile xfileResultStampImage = XFile(fileResultStampImage.path);
                                        //     widget.fileFieldBloc.updateValue(xfileResultStampImage);
                                        //   },
                                        // );

                                      }
                                    }
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Visibility(
                      visible: fieldBlocState.canShowError,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          "Ce champ est obligatoire",
                          textAlign: TextAlign.center,
                          // fieldBlocState.error.toString(),
                          style: TextStyle(
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String getImagePickerExistImageUrl() {
    String imageUrl = "${Tools.baseUrl}/img/demandes/";
    if (widget.fileFieldBloc.name == "p_pbi_avant") {
      imageUrl += Tools.selectedDemande?.pPbiAvant ?? "";
    } else if (widget.fileFieldBloc.name == "p_pbi_apres") {
      imageUrl += Tools.selectedDemande?.pPbiApres ?? "";
    } else if (widget.fileFieldBloc.name == "p_pbo_avant") {
      imageUrl += Tools.selectedDemande?.pPboAvant ?? "";
    } else if (widget.fileFieldBloc.name == "p_pbo_apres") {
      imageUrl += Tools.selectedDemande?.pPboApres ?? "";
    } else if (widget.fileFieldBloc.name == "p_equipement_installe") {
      imageUrl += Tools.selectedDemande?.pEquipementInstalle ?? "";
    } else if (widget.fileFieldBloc.name == "p_test_signal") {
      imageUrl += Tools.selectedDemande?.pTestSignal ?? "";
    } else if (widget.fileFieldBloc.name == "p_etiquetage_indoor") {
      imageUrl += Tools.selectedDemande?.pEtiquetageIndoor ?? "";
    } else if (widget.fileFieldBloc.name == "p_etiquetage_outdoor") {
      imageUrl += Tools.selectedDemande?.pEtiquetageOutdoor ?? "";
    } else if (widget.fileFieldBloc.name == "p_passage_cable") {
      imageUrl += Tools.selectedDemande?.pPassageCable ?? "";
    } else if (widget.fileFieldBloc.name == "p_fiche_instalation") {
      imageUrl += Tools.selectedDemande?.pFicheInstalation ?? "";
    } else if (widget.fileFieldBloc.name == "p_speed_test") {
      imageUrl += Tools.selectedDemande?.pSpeedTest ?? "";
    }

    return imageUrl;
  }
}
