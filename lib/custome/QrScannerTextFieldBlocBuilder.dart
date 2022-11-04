import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:telcabo/Tools.dart';


/*

class QrScannerTextFieldBlocBuilder extends StatelessWidget {
  final TextFieldBloc<dynamic> qrCodeTextFieldBloc;
  final FormBloc formBloc;
  final Widget iconField;
  final String labelText;

  QrScannerTextFieldBlocBuilder({
    Key? key,
    required this.qrCodeTextFieldBloc,
    required this.formBloc,
    required this.iconField,
    required this.labelText,
  })  : assert(qrCodeTextFieldBloc != null),
        assert(formBloc != null),
        super(key: key);


  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');







    @override
    Widget build(BuildContext context) {


      Future<dynamic> _popTime() async {
        Navigator.of(context).pop();
      }


      Future<Barcode?> _showDialog() async {
        late Barcode result ;
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            // return object of type Dialog
            return MobileScanner(
              fit: BoxFit.contain,
              // allowDuplicates: false,
              onDetect: (barcode, args) async {
                result = barcode;
                await _popTime();
              },


            );
          },
        );
        return result;
      }


      return BlocBuilder<TextFieldBloc, TextFieldBlocState>(
        bloc: qrCodeTextFieldBloc,
        builder: (context, state) {
          return Container(
              child: Row(
                children: [
                  Flexible(
                    child: TextFieldBlocBuilder(
                      // isEnabled: false,
                      textFieldBloc: qrCodeTextFieldBloc,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        labelText: labelText,
                        prefixIcon: iconField,
                        disabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                width: 1,
                                // color: Tools.colorPrimary
                            ),
                            borderRadius:
                            BorderRadius.circular(20)),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      // Navigator.of(context).push(MaterialPageRoute(
                      //   builder: (context) => const QRViewExample(),
                      // ));

                      final barCodeResult = await _showDialog();
//                            final image = await ImagePicker.pickImage(
//                              source: ImageSource.gallery,
//                            );

                      if (barCodeResult != null) {

                        String barCodeTxt =  barCodeResult.rawValue ?? "" ;

                        if (qrCodeTextFieldBloc.name == "adresse_mac") {
                          barCodeTxt.replaceAll("-", ":");




                          if(!barCodeTxt.contains(":")){
                            String tmpString =  "" ;

                            int strLength = barCodeTxt.length ;
                            for(int i=0; i<strLength; i++) {
                              var character = barCodeTxt[i];
                              tmpString += character ;
                              if (i != 0 && (i % 2 != 0) && i != (strLength - 1) ) {
                                tmpString += ":";
                              }
                            }

                            // barCodeTxt.runes.forEach((int rune) {
                            //   var character=new String.fromCharCode(rune);
                            //   print(character);
                            //   tmpString += character ;
                            //   if (rune != 0 && (rune % 2 == 0)){
                            //     tmpString += ":";
                            //   }
                            // });

                            barCodeTxt = tmpString ;

                          }
                        }

                       qrCodeTextFieldBloc.updateValue(barCodeTxt);
                      }




                    },
                    style: ElevatedButton.styleFrom(
                      // primary: Tools.colorPrimary,
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(10),
                    ),
                    child: const Icon(Icons.qr_code),
                  ),
                ],
              ));
        },
      );
    }
  }


*/


import 'package:qr_code_scanner/qr_code_scanner.dart';

class QrScannerTextFieldBlocBuilder extends StatelessWidget {
  final TextFieldBloc<dynamic> qrCodeTextFieldBloc;
  final FormBloc formBloc;
  final Widget iconField;
  final String labelText;

  QrScannerTextFieldBlocBuilder({
    Key? key,
    required this.qrCodeTextFieldBloc,
    required this.formBloc,
    required this.iconField,
    required this.labelText,
  })
      : assert(qrCodeTextFieldBloc != null),
        assert(formBloc != null),
        super(key: key);


  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');


  bool isPLay = true ;

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    // log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    Future<dynamic> _popTime() async {
      Navigator.of(context).pop();
    }

    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery
        .of(context)
        .size
        .width < 400 ||
        MediaQuery
            .of(context)
            .size
            .height < 400)
        ? 150.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller

    Future<Barcode?> _showDialog() async {
      late Barcode result;
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          var width = MediaQuery
              .of(context)
              .size
              .width > 280 ? 280 : MediaQuery
              .of(context)
              .size
              .width - 20;
          return Stack(
            children: [
              QRView(

                key: qrKey,
                onQRViewCreated: (controller) {
                  this.controller = controller ;
                  controller.resumeCamera();

                  controller.scannedDataStream.listen((scanData) async {
                    controller. /**/resumeCamera();

                    result = scanData;
                    controller.pauseCamera();
                    await _popTime();
                  });
                },
                overlay: QrScannerOverlayShape(
                    borderColor: Colors.red,
                    borderRadius: 10,
                    borderLength: 30,
                    borderWidth: 10,
                    cutOutWidth: width.toDouble(),
                    cutOutHeight: width / 2
                  // cutOutSize: scanArea
                ),
                onPermissionSet: (ctrl, p) =>
                    _onPermissionSet(context, ctrl, p),
              ),
              // Positioned(
              //   bottom: 0,
              //   child: Padding(
              //     padding: const EdgeInsets.only(top: 20),
              //     child: ElevatedButton.icon(
              //       icon: Icon(
              //         isPLay ? Icons.pause_circle :  Icons.play_circle ,
              //         size: 24.0,
              //       ),
              //       onPressed: () {
              //         isPLay ? controller?.pauseCamera() : controller?.pauseCamera() ;
              //         isPLay = !isPLay ;
              //       },
              //       label: Text(
              //         isPLay ? 'PAUSE' : 'PLAY' ,
              //         textAlign: TextAlign.center,
              //         style: TextStyle(
              //           fontSize: 18.0,
              //           wordSpacing: 12,
              //         ),
              //       ),
              //       style: ElevatedButton.styleFrom(
              //         // minimumSize: Size(280, 50),
              //         primary: isPLay ? Colors.grey : Colors.green,
              //         shape: RoundedRectangleBorder(
              //           borderRadius: new BorderRadius.circular(30.0),
              //         ),
              //
              //       ),
              //     ),
              //   ),
              // ),

            ],
          );
        },
      );
      return result;
    }


    return BlocBuilder<TextFieldBloc, TextFieldBlocState>(
      bloc: qrCodeTextFieldBloc,
      builder: (context, state) {
        return Container(
            child: Row(
              children: [
                Flexible(
                  child: TextFieldBlocBuilder(
                    // isEnabled: false,
                    textFieldBloc: qrCodeTextFieldBloc,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      labelText: labelText,
                      prefixIcon: iconField,
                      disabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            width: 1,
                            // color: Tools.colorPrimary
                          ),
                          borderRadius:
                          BorderRadius.circular(20)),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // Navigator.of(context).push(MaterialPageRoute(
                    //   builder: (context) => const QRViewExample(),
                    // ));

                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => QrScannerCameraWidget(),
                      ),
                    );

                    return ;

                    final barCodeResult = await _showDialog();
//                            final image = await ImagePicker.pickImage(
//                              source: ImageSource.gallery,
//                            );

                    if (barCodeResult != null) {
                      String barCodeTxt = barCodeResult.code ?? "";

                      if (qrCodeTextFieldBloc.name == "adresse_mac") {
                        barCodeTxt.replaceAll("-", ":");


                        if (!barCodeTxt.contains(":")) {
                          String tmpString = "";

                          int strLength = barCodeTxt.length;
                          for (int i = 0; i < strLength; i++) {
                            var character = barCodeTxt[i];
                            tmpString += character;
                            if (i != 0 && (i % 2 != 0) && i != (strLength -
                                1)) {
                              tmpString += ":";
                            }
                          }

                          // barCodeTxt.runes.forEach((int rune) {
                          //   var character=new String.fromCharCode(rune);
                          //   print(character);
                          //   tmpString += character ;
                          //   if (rune != 0 && (rune % 2 == 0)){
                          //     tmpString += ":";
                          //   }
                          // });

                          barCodeTxt = tmpString;
                        }
                      }

                      qrCodeTextFieldBloc.updateValue(barCodeTxt);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    // primary: Tools.colorPrimary,
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(10),
                  ),
                  child: const Icon(Icons.qr_code),
                ),
              ],
            ));
      },
    );
  }
}



class QrScannerCameraWidget extends StatefulWidget{

  @override
  State<QrScannerCameraWidget> createState() => _QrScannerCameraWidgetState();
}

class _QrScannerCameraWidgetState extends State<QrScannerCameraWidget> {
  QRViewController? controller;

  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  bool isPLay = true ;

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    // log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery
        .of(context)
        .size
        .width > 280 ? 280 : MediaQuery
        .of(context)
        .size
        .width - 20;
    return Stack(
      children: [
        QRView(

          key: qrKey,
          onQRViewCreated: (controller) {
            this.controller = controller ;
            controller.resumeCamera();

            controller.scannedDataStream.listen((scanData) async {
              controller.resumeCamera();
              controller.pauseCamera();
            });
          },
          overlay: QrScannerOverlayShape(
              borderColor: Colors.red,
              borderRadius: 10,
              borderLength: 30,
              borderWidth: 10,
              cutOutWidth: width.toDouble(),
              cutOutHeight: width / 2
            // cutOutSize: scanArea
          ),
          onPermissionSet: (ctrl, p) =>
              _onPermissionSet(context, ctrl, p),
        ),
        // Positioned(
        //   bottom: 0,
        //   child: Padding(
        //     padding: const EdgeInsets.only(top: 20),
        //     child: ElevatedButton.icon(
        //       icon: Icon(
        //         isPLay ? Icons.pause_circle :  Icons.play_circle ,
        //         size: 24.0,
        //       ),
        //       onPressed: () {
        //         setState(() {
        //           isPLay ? controller?.pauseCamera() : controller?.pauseCamera() ;
        //           isPLay = !isPLay ;
        //         });
        //       },
        //       label: Text(
        //         isPLay ? 'PAUSE' : 'PLAY' ,
        //         textAlign: TextAlign.center,
        //         style: TextStyle(
        //           fontSize: 18.0,
        //           wordSpacing: 12,
        //         ),
        //       ),
        //       style: ElevatedButton.styleFrom(
        //         // minimumSize: Size(280, 50),
        //         primary: isPLay ? Colors.grey : Colors.green,
        //         shape: RoundedRectangleBorder(
        //           borderRadius: new BorderRadius.circular(30.0),
        //         ),
        //
        //       ),
        //     ),
        //   ),
        // ),

      ],
    );
  }
}

