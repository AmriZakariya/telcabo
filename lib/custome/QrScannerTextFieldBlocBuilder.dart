import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:telcabo/Tools.dart';

class QrScannerTextFieldBlocBuilder extends StatefulWidget {
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

  @override
  State<QrScannerTextFieldBlocBuilder> createState() =>
      _QrScannerTextFieldBlocBuilderState();
}

class _QrScannerTextFieldBlocBuilderState
    extends State<QrScannerTextFieldBlocBuilder> {
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
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    // print("MediaQuery.of(context).size.width / 4.9");
    // print(MediaQuery.of(context).size.width / 4.9);

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

    QRViewController qrController;

    Future<Barcode?> _showDialog() async {
      late Barcode result;
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return QRView(
            key: qrKey,
            onQRViewCreated: (controller) {
              qrController = controller;
              // if (Platform.isAndroid) { this.controller?.resumeCamera(); }

              qrController.resumeCamera();
              qrController.scannedDataStream.listen((scanData) async {
                qrController.pauseCamera();
                qrController.resumeCamera();

                result = scanData;
                qrController.pauseCamera();
                await _popTime();
              });
            },
            overlay: QrScannerOverlayShape(
              borderColor: Colors.red,
              borderRadius: 10,
              borderLength: 30,
              borderWidth: 10,
              cutOutWidth: MediaQuery.of(context).size.width / 1.2,
              cutOutHeight: 70, //MediaQuery.of(context).size.width / 4.9
              // cutOutSize: scanArea
            ),
            onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
          );
        },
      );
      print("MediaQuery.of(context).size.width / 4.9");
      print(MediaQuery.of(context).size.width / 4.9);
      return result;
    }

    return BlocBuilder<TextFieldBloc, TextFieldBlocState>(
      bloc: widget.qrCodeTextFieldBloc,
      builder: (context, state) {
        return Container(
            child: Row(
          children: [
            Flexible(
              child: TextFieldBlocBuilder(
                // isEnabled: false,
                textFieldBloc: widget.qrCodeTextFieldBloc,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: widget.labelText,
                  prefixIcon: widget.iconField,
                  disabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 1,
                        // color: Tools.colorPrimary
                      ),
                      borderRadius: BorderRadius.circular(20)),
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
                  if (widget.qrCodeTextFieldBloc.name == "adresse_mac") {
                    String result = barCodeResult.code ?? "000000";
                    String formattedMAC = "";
                    for (int i = 0; i < result.length; i++) {
                      var char = result[i];
                      formattedMAC += char;
                      if ((i % 2 != 0) && (i < result.length - 1)) {
                        formattedMAC += "-";
                      }
                    }

                    widget.qrCodeTextFieldBloc.updateValue(formattedMAC);
                  } else {
                    widget.qrCodeTextFieldBloc
                        .updateValue(barCodeResult.code ?? "000000");
                  }
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
