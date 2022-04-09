import 'dart:io';

import 'package:cool_alert/cool_alert.dart';
import 'package:floating_action_bubble/floating_action_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:im_stepper/stepper.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:telcabo/Tools.dart';
import 'package:telcabo/custome/QrScannerTextFieldBlocBuilder.dart';
import 'package:telcabo/models/response_get_demandes.dart';
import 'package:telcabo/models/response_get_liste_etats.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:telcabo/ui/InterventionHeaderInfoWidget.dart';
import 'package:url_launcher/url_launcher.dart';

class AllFieldsFormBloc extends FormBloc<String, String> {
  late final ResponseGetListEtat responseListEtat;
  late final ResponseGetDemandesList responseGetDemandesList;

  final etatDropDown = SelectFieldBloc<Etat, dynamic>(
    name: "etat_id",
    validators: [
      FieldBlocValidators.required,
    ],
    toJson: (value) => value?.id,
  );

  final sousEtatDropDown = SelectFieldBloc<SousEtat, dynamic>(
    name: "substatut",
    validators: [
      FieldBlocValidators.required,
    ],
    toJson: (value) => value?.id,
  );

  final motifDropDown = SelectFieldBloc<MotifList, dynamic>(
    name: "motif",
    validators: [
      FieldBlocValidators.required,
    ],
    toJson: (value) => value?.id,
  );

  final commentaireTextField = TextFieldBloc(
    name: 'commentaire',
    validators: [
      FieldBlocValidators.required,
    ],
  );

  final rdvDate = InputFieldBloc<DateTime?, Object>(
    initialValue: null,
    name: "date_rdv",
    validators: [
      FieldBlocValidators.required,
    ],
    toJson: (value) {
      final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:s');
      final String formatted = formatter.format(value ?? DateTime.now());
      return formatted;
    },
  );

  final traitementConsommationCableTextField = TextFieldBloc(
    name: 'consommation_cable',
    validators: [
      FieldBlocValidators.required,
    ],
  );

  final speedTextField = TextFieldBloc(
    name: 'speed',
    validators: [
      FieldBlocValidators.required,
    ],
  );

  final debitTextField = TextFieldBloc(
    name: 'debit',
    validators: [
      FieldBlocValidators.required,
    ],
  );

  final latitudeTextField = TextFieldBloc(
    name: 'latitude',
    validators: [
      FieldBlocValidators.required,
    ],
  );

  final longintudeTextField = TextFieldBloc(
    name: 'longitude',
    validators: [
      FieldBlocValidators.required,
    ],
  );
  final adresseMacTextField = TextFieldBloc(
    name: 'adresse_mac',
    validators: [
      FieldBlocValidators.required,
    ],
  );

  final dnsTextField = TextFieldBloc(
    name: 'dnsn',
    validators: [
      FieldBlocValidators.required,
    ],
  );
  final snTelTextField = TextFieldBloc(
    name: 'sn_tel',
    validators: [
      FieldBlocValidators.required,
    ],
  );
  final snGpomTextField = TextFieldBloc(
    name: 'sn_routeur',
    validators: [
      FieldBlocValidators.required,
    ],
  );

  AllFieldsFormBloc() : super(isLoading: true) {
    addFieldBlocs(fieldBlocs: [
      etatDropDown,
      commentaireTextField,
      traitementConsommationCableTextField,
      speedTextField,
      debitTextField,
      latitudeTextField,
      longintudeTextField,
      adresseMacTextField,
      dnsTextField,
      snTelTextField,
      snGpomTextField
    ]);

    etatDropDown.onValueChanges(
      onData: (previous, current) async* {
        // String currentId = current.value?.id ?? "" ;
        // List<SousEtat>? sousEtat = responseListEtat.etat?.firstWhere((element) => element.id == currentId).sousEtat! ?? []

        print("etatDropDown onValueChanges");
        print(current.value?.id ?? "...");

        removeFieldBlocs(fieldBlocs: [motifDropDown]);

        if (current.value?.id == "1") {
          addFieldBloc(fieldBloc: rdvDate);

          removeFieldBlocs(fieldBlocs: [sousEtatDropDown]);
        } else {
          removeFieldBlocs(fieldBlocs: [rdvDate]);

          if (current.value?.sousEtat?.isEmpty == true) {
            removeFieldBlocs(fieldBlocs: [sousEtatDropDown]);
          } else {
            sousEtatDropDown.updateItems(current.value?.sousEtat ?? []);
            addFieldBloc(fieldBloc: sousEtatDropDown);
          }
        }
      },
    );

    sousEtatDropDown.onValueChanges(
      onData: (previous, current) async* {
        // String currentId = current.value?.id ?? "" ;
        // List<SousEtat>? sousEtat = responseListEtat.etat?.firstWhere((element) => element.id == currentId).sousEtat! ?? []

        print("sousEtatDropDown onValueChanges");
        print(current.value?.id ?? "...");
        print(current.value?.motifList ?? "...");

        if (current.value?.motifList?.isEmpty == true) {
          removeFieldBlocs(fieldBlocs: [motifDropDown]);
        } else {
          motifDropDown.updateItems(current.value?.motifList ?? []);
          addFieldBloc(fieldBloc: motifDropDown);
        }
      },
    );
  }

  void addErrors() {
    // text1.addFieldError('Awesome Error!');
    // boolean1.addFieldError('Awesome Error!');
    // boolean2.addFieldError('Awesome Error!');
    // select1.addFieldError('Awesome Error!');
    // select2.addFieldError('Awesome Error!');
    // multiSelect1.addFieldError('Awesome Error!');
    // date1.addFieldError('Awesome Error!');
    // dateAndTime1.addFieldError('Awesome Error!');
    // time1.addFieldError('Awesome Error!');
  }

  @override
  void onSubmitting() async {
    try {
      // await Future<void>.delayed(const Duration(milliseconds: 500));

      emitSuccess(canSubmitAgain: true);
    } catch (e) {
      emitFailure();
    }
  }

  @override
  void onLoading() async {
    try {
      responseListEtat = await getEtats();
      responseGetDemandesList = await getListDemandes();

      etatDropDown.updateItems(responseListEtat.etat ?? []);

      emitLoaded();
    } catch (e) {
      print(e);
      emitLoadFailed(failureResponse: e.toString());
    }
  }

  Future<ResponseGetListEtat> getEtats() async {
    var url = Uri.parse('http://telcabo.castlit.com/etats/liste_etats');
    var response = await http.get(url);
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      var responseApiHome = jsonDecode(response.body);
      ResponseGetListEtat etats = ResponseGetListEtat.fromJson(responseApiHome);
      print(etats);

      return etats;
    } else {
      throw Exception('error fetching liste_etats');
    }
  }

  Future<ResponseGetDemandesList> getListDemandes() async {
    var url = Uri.parse('http://telcabo.castlit.com/demandes/get_demandes');
    var response = await http.get(url);
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      var responseApiHome = jsonDecode(response.body);
      ResponseGetDemandesList listDemandes =
          ResponseGetDemandesList.fromJson(responseApiHome);
      print(
          "listDemandes response http://telcabo.castlit.com/demandes/get_demandes'");
      print(listDemandes);

      return listDemandes;
    } else {
      throw Exception('error fetching get_demandes');
    }
  }
}

class InterventionFormStep2 extends StatefulWidget {
  const InterventionFormStep2({Key? key}) : super(key: key);

  @override
  State<InterventionFormStep2> createState() => _InterventionFormStep2State();
}

class _InterventionFormStep2State extends State<InterventionFormStep2>
    with SingleTickerProviderStateMixin {
  late Animation<double> _animation;
  late AnimationController _animationController;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 260),
    );

    final curvedAnimation =
        CurvedAnimation(curve: Curves.easeInOut, parent: _animationController);
    _animation = Tween<double>(begin: 0, end: 1).animate(curvedAnimation);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AllFieldsFormBloc(),
      child: Builder(
        builder: (context) {
          final formBloc = BlocProvider.of<AllFieldsFormBloc>(context);

          return Theme(
            data: Theme.of(context).copyWith(
              primaryColor: Tools.colorPrimary,
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            child: Scaffold(
              appBar: AppBar(
                title: const Text('Intervention'),
                // backgroundColor: Tools.colorPrimary,
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.miniStartFloat,

              //Init Floating Action Bubble
              floatingActionButton: FloatingActionBubble(
                // Menu items
                items: <Bubble>[
                  // Floating action menu item
                  Bubble(
                    title: "WhatssApp",
                    iconColor: Colors.white,
                    bubbleColor: Colors.blue,
                    icon: Icons.whatsapp,
                    titleStyle: TextStyle(fontSize: 16, color: Colors.white),
                    onPress: () async {
                      print("share wtsp");
                      var whatsapp = "+212619993849";
                      var whatsappURl_android =
                          "whatsapp://send?phone=" + whatsapp + "&text=hello";
                      var whatappURL_ios =
                          "https://wa.me/$whatsapp?text=${Uri.parse("hello")}";
                      if (Platform.isIOS) {
                        // for iOS phone only
                        if (await canLaunch(whatappURL_ios)) {
                          await launch(whatappURL_ios, forceSafariVC: false);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: new Text("whatsapp no installed")));
                        }
                      } else {
                        // android , web
                        if (await canLaunch(whatsappURl_android)) {
                          await launch(whatsappURl_android);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: new Text("whatsapp no installed")));
                        }
                      }
                      _animationController.reverse();
                    },
                  ),
                  // Floating action menu item
                  Bubble(
                    title: "Mail",
                    iconColor: Colors.white,
                    bubbleColor: Colors.blue,
                    icon: Icons.mail_outline,
                    titleStyle: TextStyle(fontSize: 16, color: Colors.white),
                    onPress: () async {
                      bool success = await Tools.callWSSendMail();
                      if(success){
                        CoolAlert.show(
                            context: context,
                            type: CoolAlertType.success,
                            text: "Email Envoyé avec succès",
                            autoCloseDuration: Duration(seconds: 5),
                            title: "Succès"

                        );
                      }
                      _animationController.reverse();
                    },
                  ),
                  //Floating action menu item
                ],

                // animation controller
                animation: _animation,

                // On pressed change animation state
                onPress: () => _animationController.isCompleted
                    ? _animationController.reverse()
                    : _animationController.forward(),

                // Floating Action button Icon color
                iconColor: Tools.colorSecondary,

                // Flaoting Action button Icon
                iconData: Icons.whatsapp,
                backGroundColor: Colors.white,
              ),
              // floatingActionButton: Column(
              //   mainAxisSize: MainAxisSize.min,
              //   children: <Widget>[
              //     FloatingActionButton.extended(
              //       heroTag: null,
              //       onPressed: formBloc.addErrors,
              //       icon: const Icon(Icons.whatsapp),
              //       label: const Text(''),
              //     ),
              //     const SizedBox(height: 12),
              //     FloatingActionButton.extended(
              //       heroTag: null,
              //       onPressed: formBloc.submit,
              //       icon: const Icon(Icons.mail),
              //       label: const Text(''),
              //     ),
              //   ],
              // ),
              body: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/bg_home.jpg"),
                    fit: BoxFit.cover,
                  ),
                ),
                child: FormBlocListener<AllFieldsFormBloc, String, String>(
                  onSubmitting: (context, state) {
                    // LoadingDialog.show(context);
                  },
                  onSuccess: (context, state) {
                    LoadingDialog.hide(context);

                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (_) => const SuccessScreen()));
                  },
                  onFailure: (context, state) {
                    LoadingDialog.hide(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.failureResponse!)));
                  },
                  child: ScrollableFormBlocManager(
                    formBloc: formBloc,
                    child: RawScrollbar(
                      isAlwaysShown: true,
                      thickness: 6,
                      thumbColor: Colors.black,
                      child: SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 34),
                        child: Column(
                          children: <Widget>[
                            NumberStepper(
                              numbers:[
                                1,
                                2,
                                3,
                              ],
                              activeStep: 1,
                              activeStepColor: Tools.colorPrimary,
                              // stepColor: Colors.white,
                              // lineColor: Colors.white,
                              enableNextPreviousButtons: false,
                              enableStepTapping: false,
                              activeStepBorderColor: Tools.colorSecondary,

                            ),
                            SizedBox(
                              height: 20,
                              // child: Divider(
                              //   height: 3,
                              //   color: Colors.black,
                              // ),
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
                            DropdownFieldBlocBuilder<Etat>(
                              selectFieldBloc: formBloc.etatDropDown,
                              decoration: const InputDecoration(
                                labelText: 'Etat',
                                prefixIcon: Icon(Icons.list),
                              ),
                              itemBuilder: (context, value) => FieldItem(
                                child: Text(value.name ?? ""),
                              ),
                            ),
                            DateTimeFieldBlocBuilder(
                              dateTimeFieldBloc: formBloc.rdvDate,
                              format: DateFormat('dd-MM-yyyy'),
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2100),
                              decoration: const InputDecoration(
                                labelText: 'Rendez-vous',
                                prefixIcon: Icon(Icons.date_range),
                              ),
                            ),
                            DropdownFieldBlocBuilder<SousEtat>(
                              selectFieldBloc: formBloc.sousEtatDropDown,
                              decoration: const InputDecoration(
                                labelText: 'Sous Etat',
                                prefixIcon: Icon(Icons.list),
                              ),
                              itemBuilder: (context, value) => FieldItem(
                                child: Text(value.name ?? ""),
                              ),
                            ),
                            DropdownFieldBlocBuilder<MotifList>(
                              selectFieldBloc: formBloc.motifDropDown,
                              decoration: const InputDecoration(
                                labelText: 'Morif',
                                prefixIcon: Icon(Icons.list),
                              ),
                              itemBuilder: (context, value) => FieldItem(
                                child: Text(value.name ?? ""),
                              ),
                            ),
                            Divider(
                              color: Colors.black,
                            ),

                            TextFieldBlocBuilder(
                              textFieldBloc:
                                  formBloc.traitementConsommationCableTextField,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                labelText: "Consomation cable ",
                                prefixIcon: Icon(Icons.drag_indicator),
                              ),
                            ),
                            TextFieldBlocBuilder(
                              textFieldBloc: formBloc.speedTextField,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                labelText: "Speed",
                                prefixIcon: Icon(Icons.speed),
                              ),
                            ),
                            TextFieldBlocBuilder(
                              textFieldBloc: formBloc.debitTextField,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                labelText: "Debit",
                                prefixIcon: Icon(Icons.speed),
                              ),
                            ),
                            Divider(
                              color: Colors.black,
                            ),
                            Container(
                                child: Row(
                              children: [
                                Flexible(
                                  flex: 5,
                                  child: Container(
                                    child: Column(
                                      children: [
                                        TextFieldBlocBuilder(
                                          readOnly: true,
                                          textFieldBloc:
                                              formBloc.latitudeTextField,
                                          clearTextIcon: Icon(Icons.cancel),
                                          suffixButton: SuffixButton.clearText,
                                          keyboardType: TextInputType.text,
                                          decoration: InputDecoration(
                                            labelText: "Latitude :",
                                            prefixIcon: Icon(Icons.location_on),
                                            disabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  width: 1,
                                                  // color: Tools.colorPrimary
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(20)),
                                          ),
                                        ),
                                        TextFieldBlocBuilder(
                                          readOnly: true,
                                          textFieldBloc:
                                              formBloc.longintudeTextField,
                                          keyboardType: TextInputType.text,
                                          clearTextIcon: Icon(Icons.cancel),
                                          suffixButton: SuffixButton.clearText,
                                          decoration: InputDecoration(
                                            labelText: "Longitude :",
                                            prefixIcon: Icon(Icons.location_on),
                                            disabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  width: 1,
                                                  // color: Tools.colorPrimary
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(20)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Flexible(
                                  // flex: 2,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      Position? position =
                                          await _determinePosition();
                                      if (position != null) {
                                        formBloc.latitudeTextField.updateValue(
                                            position.latitude
                                                .toStringAsFixed(4));
                                        formBloc.longintudeTextField
                                            .updateValue(position.longitude
                                                .toStringAsFixed(4));
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      // primary: Tools.colorPrimary,
                                      shape: CircleBorder(),
                                      padding: EdgeInsets.all(10),
                                    ),
                                    child: const Icon(Icons.my_location),
                                  ),
                                ),
                              ],
                            )),
                            Divider(
                              color: Colors.black,
                            ),

                            QrScannerTextFieldBlocBuilder(
                              formBloc: formBloc,
                              iconField: Icon(Icons.text_snippet),
                              labelText: "Adresse Mac ",
                              qrCodeTextFieldBloc: formBloc.adresseMacTextField,
                            ),

                            QrScannerTextFieldBlocBuilder(
                              formBloc: formBloc,
                              iconField: Icon(Icons.text_snippet),
                              labelText: "DNSN ",
                              qrCodeTextFieldBloc: formBloc.dnsTextField,
                            ),

                            QrScannerTextFieldBlocBuilder(
                              formBloc: formBloc,
                              iconField: Icon(Icons.text_snippet),
                              labelText: "SN Tel ",
                              qrCodeTextFieldBloc: formBloc.snTelTextField,
                            ),

                            QrScannerTextFieldBlocBuilder(
                              formBloc: formBloc,
                              iconField: Icon(Icons.text_snippet),
                              labelText: "SSN GPON ",
                              qrCodeTextFieldBloc: formBloc.snGpomTextField,
                            ),

                            Divider(
                              color: Colors.black,
                            ),

                            TextFieldBlocBuilder(
                              textFieldBloc: formBloc.commentaireTextField,
                              keyboardType: TextInputType.text,
                              minLines: 6,
                              maxLines: 20,
                              decoration: InputDecoration(
                                labelText: "Commentaire",
                                prefixIcon: Icon(Icons.comment),
                              ),
                            ),

                            // TextFieldBlocBuilder(
                            //   textFieldBloc: formBloc.text1,
                            //   suffixButton: SuffixButton.obscureText,
                            //   decoration: const InputDecoration(
                            //     labelText: 'TextFieldBlocBuilder',
                            //     prefixIcon: Icon(Icons.text_fields),
                            //   ),
                            // ),
                            // RadioButtonGroupFieldBlocBuilder<String>(
                            //   selectFieldBloc: formBloc.select2,
                            //   decoration: const InputDecoration(
                            //     labelText: 'RadioButtonGroupFieldBlocBuilder',
                            //   ),
                            //   groupStyle: const FlexGroupStyle(),
                            //   itemBuilder: (context, item) => FieldItem(
                            //     child: Text(item),
                            //   ),
                            // ),
                            // CheckboxGroupFieldBlocBuilder<String>(
                            //   multiSelectFieldBloc: formBloc.multiSelect1,
                            //   decoration: const InputDecoration(
                            //     labelText: 'CheckboxGroupFieldBlocBuilder',
                            //   ),
                            //   groupStyle: const ListGroupStyle(
                            //     scrollDirection: Axis.horizontal,
                            //     height: 64,
                            //   ),
                            //   itemBuilder: (context, item) => FieldItem(
                            //     child: Text(item),
                            //   ),
                            // ),
                            // DateTimeFieldBlocBuilder(
                            //   dateTimeFieldBloc: formBloc.date1,
                            //   format: DateFormat('dd-MM-yyyy'),
                            //   initialDate: DateTime.now(),
                            //   firstDate: DateTime(1900),
                            //   lastDate: DateTime(2100),
                            //   decoration: const InputDecoration(
                            //     labelText: 'DateTimeFieldBlocBuilder',
                            //     prefixIcon: Icon(Icons.calendar_today),
                            //     helperText: 'Date',
                            //   ),
                            // ),
                            // DateTimeFieldBlocBuilder(
                            //   dateTimeFieldBloc: formBloc.dateAndTime1,
                            //   canSelectTime: true,
                            //   format: DateFormat('dd-MM-yyyy  hh:mm'),
                            //   initialDate: DateTime.now(),
                            //   firstDate: DateTime(1900),
                            //   lastDate: DateTime(2100),
                            //   decoration: const InputDecoration(
                            //     labelText: 'DateTimeFieldBlocBuilder',
                            //     prefixIcon: Icon(Icons.date_range),
                            //     helperText: 'Date and Time',
                            //   ),
                            // ),
                            // TimeFieldBlocBuilder(
                            //   timeFieldBloc: formBloc.time1,
                            //   format: DateFormat('hh:mm a'),
                            //   initialTime: TimeOfDay.now(),
                            //   decoration: const InputDecoration(
                            //     labelText: 'TimeFieldBlocBuilder',
                            //     prefixIcon: Icon(Icons.access_time),
                            //   ),
                            // ),
                            // SwitchFieldBlocBuilder(
                            //   booleanFieldBloc: formBloc.boolean2,
                            //   body: const Text('SwitchFieldBlocBuilder'),
                            // ),
                            // DropdownFieldBlocBuilder<String>(
                            //   selectFieldBloc: formBloc.select1,
                            //   decoration: const InputDecoration(
                            //     labelText: 'DropdownFieldBlocBuilder',
                            //   ),
                            //   itemBuilder: (context, value) => FieldItem(
                            //     isEnabled: value != 'Option 1',
                            //     child: Text(value),
                            //   ),
                            // ),
                            // Row(
                            //   children: [
                            //     IconButton(
                            //       onPressed: () => formBloc.addFieldBloc(
                            //           fieldBloc: formBloc.select1),
                            //       icon: const Icon(Icons.add),
                            //     ),
                            //     IconButton(
                            //       onPressed: () => formBloc.removeFieldBloc(
                            //           fieldBloc: formBloc.select1),
                            //       icon: const Icon(Icons.delete),
                            //     ),
                            //   ],
                            // ),
                            // CheckboxFieldBlocBuilder(
                            //   booleanFieldBloc: formBloc.boolean1,
                            //   body: const Text('CheckboxFieldBlocBuilder'),
                            // ),
                            // CheckboxFieldBlocBuilder(
                            //   booleanFieldBloc: formBloc.boolean1,
                            //   body: const Text('CheckboxFieldBlocBuilder trailing'),
                            //   controlAffinity:
                            //   FieldBlocBuilderControlAffinity.trailing,
                            // ),
                            // SliderFieldBlocBuilder(
                            //   inputFieldBloc: formBloc.double1,
                            //   divisions: 10,
                            //   labelBuilder: (context, value) =>
                            //       value.toStringAsFixed(2),
                            // ),
                            // SliderFieldBlocBuilder(
                            //   inputFieldBloc: formBloc.double1,
                            //   divisions: 10,
                            //   labelBuilder: (context, value) =>
                            //       value.toStringAsFixed(2),
                            //   activeColor: Colors.red,
                            //   inactiveColor: Colors.green,
                            // ),
                            // SliderFieldBlocBuilder(
                            //   inputFieldBloc: formBloc.double1,
                            //   divisions: 10,
                            //   labelBuilder: (context, value) =>
                            //       value.toStringAsFixed(2),
                            // ),
                            // ChoiceChipFieldBlocBuilder<String>(
                            //   selectFieldBloc: formBloc.select2,
                            //   itemBuilder: (context, value) => ChipFieldItem(
                            //     label: Text(value),
                            //   ),
                            // ),
                            // FilterChipFieldBlocBuilder<String>(
                            //   multiSelectFieldBloc: formBloc.multiSelect1,
                            //   itemBuilder: (context, value) => ChipFieldItem(
                            //     label: Text(value),
                            //   ),
                            // ),
                            // BlocBuilder<InputFieldBloc<File?, String>,
                            //     InputFieldBlocState<File?, String>>(
                            //     bloc: formBloc.file,
                            //     builder: (context, state) {
                            //       return Container();
                            //     })
                            SizedBox(
                              height: 20,
                            ),
                            ElevatedButton(
                              onPressed: () {
                                formBloc.submit();
                              },
                              child: const Text(
                                'Enregistrer',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18.0,
                                  wordSpacing: 12,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                // shape: CircleBorder(),
                                minimumSize: Size(280, 50),
                                // primary: Tools.colorPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(30.0),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
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
}

class LoadingDialog extends StatelessWidget {
  static void show(BuildContext context, {Key? key}) => showDialog<void>(
        context: context,
        useRootNavigator: false,
        barrierDismissible: false,
        builder: (_) => LoadingDialog(key: key),
      ).then((_) => FocusScope.of(context).requestFocus(FocusNode()));

  static void hide(BuildContext context) => Navigator.pop(context);

  const LoadingDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Center(
        child: Card(
          child: Container(
            width: 80,
            height: 80,
            padding: const EdgeInsets.all(12.0),
            child: const CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        disabledColor: Colors.black,
        inputDecorationTheme: InputDecorationTheme(
          disabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                width: 1,
                // color: Tools.colorPrimary
              ),
              borderRadius: BorderRadius.circular(20)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(Icons.tag_faces, size: 100),
              const SizedBox(height: 10),
              const Text(
                'Success',
                style: TextStyle(fontSize: 54, color: Colors.black),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                        builder: (_) => const InterventionFormStep2())),
                icon: const Icon(Icons.replay),
                label: const Text('AGAIN'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
