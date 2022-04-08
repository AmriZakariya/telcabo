import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:image_picker/image_picker.dart';

class ImageFieldBlocBuilder extends StatelessWidget {
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
                    image = await _picker.pickImage(source: ImageSource.camera);

                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Camera'),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    image = await _picker.pickImage(source: ImageSource.gallery);

                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.image_outlined),
                  label: const Text('Gallery'),
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
      bloc: fileFieldBloc,
      builder: (context, fieldBlocState) {
        return BlocBuilder<FormBloc, FormBlocState>(
          bloc: formBloc,
          builder: (context, formBlocState) {
            return Visibility(
              visible: formBloc.state.fieldBlocs()?.containsKey(fileFieldBloc.name) ?? true,
              child: Column(
                children: <Widget>[
                  Text(
                      labelText
                  ),
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
                            : fieldBlocState.canShowError ? Colors.red : Colors.white,
                        child: Opacity(
                          opacity: formBlocState.canSubmit ? 1 : 0.5,
                          child: fieldBlocState.value != null
                              ? Image.file(
                            File(fieldBlocState.value?.path ?? "") ,
                            height: 90,
                            width: 90,
                            fit: BoxFit.fill,
                          )
                              : Container(
                              height: 90, width: 90, child: iconField),
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
                              final image = await _showDialog();

                              final File file = File(image?.path ?? "");
                              if (await file.exists()) {
                                fileFieldBloc.updateValue(image);
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
            );
          },
        );
      },
    );

  }
}
