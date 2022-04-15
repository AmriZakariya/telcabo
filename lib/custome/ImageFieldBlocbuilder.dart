import 'dart:io';
import 'dart:typed_data';

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

  @override
  Widget build(BuildContext context) {
    Future<XFile?> _showDialog() async {
      XFile? image;
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
                    image = await _picker.pickImage(source: ImageSource.camera,  imageQuality: 50);

                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Caméra'),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    image =
                        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);

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
      return image;
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
                                ? Image.file(
                                    File(fieldBlocState.value?.path ?? ""),
                                    height: 90,
                                    width: 90,
                                    fit: BoxFit.fill,
                                  )
                                : Container(
                                    height: 90, width: 90, child: widget.iconField),
                          ),
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
                                      final imageResult = await _showDialog();

                                      final File fileResult = File(imageResult?.path ?? "");
                                      if (await fileResult.exists()) {

                                        widget.fileFieldBloc.updateValue(imageResult);

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
                    AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      height: fieldBlocState.canShowError ? 30 : 0,
                      child: SingleChildScrollView(
                        physics: ClampingScrollPhysics(),
                        child: Column(
                          children: <Widget>[
                            SizedBox(height: 8),
                            Text(
                              "Ce champ est obligatoire",
                              // fieldBlocState.error.toString(),
                              style: TextStyle(
                                color: Colors.red,
                              ),
                            ),
                          ],
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

  Future<String> _getAddressFromLatLng() async {

    String coordinateString = "" ;
    Position? position = await _determinePosition();
    try {
      if (position != null) {

        coordinateString =   "( latitude = ${position.latitude}   longitude =  ${position.longitude} )" ;


        List<Placemark> placemarks = await placemarkFromCoordinates(
            position.latitude, position.longitude);
        Placemark place = placemarks[0];
        print(place);

        String fullAddess =  " ${place.locality}, ${place.postalCode}, ${place.country}";

        return coordinateString + " " + fullAddess ;
        // return "${position.}, ${place.postalCode}, ${place.country}"
      }


    } catch (e) {
      print(e);
    }

    return coordinateString  ;
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  Future<File?> compressAndGetFile(File file, String targetPath, [int quality = 80]) async {
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path, targetPath,
      quality: quality,
    );

    print(file.lengthSync());
    print(result?.lengthSync());

    return result;
  }
}
