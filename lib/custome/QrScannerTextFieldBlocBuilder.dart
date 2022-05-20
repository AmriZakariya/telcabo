import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:telcabo/Tools.dart';

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


  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');



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
      var scanArea = (MediaQuery.of(context).size.width < 400 ||
          MediaQuery.of(context).size.height < 400)
          ? 150.0
          : 300.0;
      // To ensure the Scanner view is properly sizes after rotation
      // we need to listen for Flutter SizeChanged notification and update controller

      Future<Barcode?> _showDialog() async {
        late Barcode result ;
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            // return object of type Dialog
            return QRView(
              key: qrKey,
              onQRViewCreated: (controller) {
                controller.scannedDataStream.listen((scanData) async {

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
                  cutOutWidth: MediaQuery.of(context).size.width / 1.2,
                  cutOutHeight: MediaQuery.of(context).size.width / 1.6
                  // cutOutSize: scanArea
              ),
              onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
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
                        qrCodeTextFieldBloc.updateValue(barCodeResult.code ?? "000000");
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