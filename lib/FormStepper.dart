import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:im_stepper/stepper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:path_provider/path_provider.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';
import 'package:telcabo/Tools.dart';
import 'package:telcabo/custome/ConnectivityCheckBlocBuilder.dart';
import 'package:telcabo/custome/ImageFieldBlocbuilder.dart';
import 'package:telcabo/custome/QrScannerTextFieldBlocBuilder.dart';
import 'package:telcabo/models/response_get_demandes.dart';
import 'package:telcabo/models/response_get_liste_etats.dart';
import 'dart:convert';

import 'dart:developer' as developer;

import 'package:flutter/services.dart';
import 'package:telcabo/ui/InterventionHeaderInfoWidget.dart';
import 'package:timelines/timelines.dart';

import 'InterventionFormStep2.dart';
import 'NotificationExample.dart';
// import 'package:http/http.dart' as http;


final GlobalKey<ScaffoldState> formStepperScaffoldKey = new GlobalKey<ScaffoldState>();


class WizardFormBloc extends FormBloc<String, String> {

  late final ResponseGetListEtat responseListEtat;

  Directory dir = Directory("");
  File fileTraitementList = File("");


  /* Form Fields */

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
      // FieldBlocValidators.required,
    ],
  );

  final InputFieldBloc<XFile?, Object> pPbiAvantTextField = InputFieldBloc(
    initialValue: null,
    name: "p_pbi_avant",
    validators: [
      FieldBlocValidators.required,
    ],
    toJson: (value) {
      MultipartFile file = MultipartFile.fromFileSync(value?.path ?? "",
          filename: value?.name ?? "");
      return file;
    },
  );

  final InputFieldBloc<XFile?, Object> pPbiApresTextField = InputFieldBloc(
    initialValue: null,
    name: "p_pbi_apres",
    validators: [
      FieldBlocValidators.required,
    ],
    toJson: (value) {
      MultipartFile file = MultipartFile.fromFileSync(value?.path ?? "",
          filename: value?.name ?? "");
      return file;
    },
  );

  final InputFieldBloc<XFile?, Object> pPboAvantTextField = InputFieldBloc(
    initialValue: null,
    name: "p_pbo_avant",
    toJson: (value) {
      MultipartFile file = MultipartFile.fromFileSync(value?.path ?? "",
          filename: value?.name ?? "");
      return file;
    },
  );

  final InputFieldBloc<XFile?, Object> pPboApresTextField = InputFieldBloc(
    initialValue: null,
    name: "p_pbo_apres",
    toJson: (value) {
      MultipartFile file = MultipartFile.fromFileSync(value?.path ?? "",
          filename: value?.name ?? "");
      return file;
    },
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


  /* Step 2 */

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


  final etatImmo = TextFieldBloc(
    name: 'etat_immo',
    validators: [
      FieldBlocValidators.required,
    ],
  );
  final newLatitude = TextFieldBloc(
    name: 'new_latitude',
    validators: [
      FieldBlocValidators.required,
    ],
  );

  final newLongitude = TextFieldBloc(
    name: 'new_longitude',
    validators: [
      FieldBlocValidators.required,
    ],
  );
  final newAdresse = TextFieldBloc(
    name: 'new_adresse',
    validators: [
      FieldBlocValidators.required,
    ],
  );


  /* Step 3 */


  final InputFieldBloc<XFile?, Object> pEquipementInstalle = InputFieldBloc(
    initialValue: null,
    name: "p_equipement_installe",
    validators: [
      FieldBlocValidators.required,
    ],
    toJson: (value) {
      MultipartFile file = MultipartFile.fromFileSync(value?.path ?? "",
          filename: value?.name ?? "");
      return file;
    },
  );

  final InputFieldBloc<XFile?, Object> pTestSignal = InputFieldBloc(
    initialValue: null,
    name: "p_test_signal",
    validators: [
      FieldBlocValidators.required,
    ],
    toJson: (value) {
      MultipartFile file = MultipartFile.fromFileSync(value?.path ?? "",
          filename: value?.name ?? "");
      return file;
    },
  );

  final InputFieldBloc<XFile?, Object> pEtiquetageIndoor = InputFieldBloc(
    initialValue: null,
    name: "p_etiquetage_indoor",
    validators: [
      FieldBlocValidators.required,
    ],
    toJson: (value) {
      MultipartFile file = MultipartFile.fromFileSync(value?.path ?? "",
          filename: value?.name ?? "");
      return file;
    },
  );

  final InputFieldBloc<XFile?, Object> pEtiquetageOutdoor = InputFieldBloc(
    initialValue: null,
    name: "p_etiquetage_outdoor",
    validators: [
      FieldBlocValidators.required,
    ],
    toJson: (value) {
      MultipartFile file = MultipartFile.fromFileSync(value?.path ?? "",
          filename: value?.name ?? "");
      return file;
    },
  );

  final InputFieldBloc<XFile?, Object> pPassageCable = InputFieldBloc(
    initialValue: null,
    name: "p_passage_cable",
    validators: [
      FieldBlocValidators.required,
    ],
    toJson: (value) {
      MultipartFile file = MultipartFile.fromFileSync(value?.path ?? "",
          filename: value?.name ?? "");
      return file;
    },
  );

  final InputFieldBloc<XFile?, Object> pFicheInstalation = InputFieldBloc(
    initialValue: null,
    name: "p_fiche_instalation",
    validators: [
      FieldBlocValidators.required,
    ],
    toJson: (value) {
      MultipartFile file = MultipartFile.fromFileSync(value?.path ?? "",
          filename: value?.name ?? "");
      return file;
    },
  );

  final InputFieldBloc<XFile?, Object> pSpeedTest = InputFieldBloc(
    initialValue: null,
    name: "p_speed_test",
    validators: [
      FieldBlocValidators.required,
    ],
    toJson: (value) {
      MultipartFile file = MultipartFile.fromFileSync(value?.path ?? "",
          filename: value?.name ?? "");
      return file;
    },
  );

  WizardFormBloc()  : super(isLoading: true) {

    print("Tools.currentStep ==> ${Tools.currentStep }");
    emit(FormBlocLoading(currentStep: Tools.currentStep));


    addFieldBlocs(
      step: 0,
      fieldBlocs: [etatDropDown, commentaireTextField],
    );
    addFieldBlocs(
      step: 1,
      fieldBlocs: [
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
      ],
    );
    addFieldBlocs(
      step: 2,
      fieldBlocs: [
        pEquipementInstalle,
        pTestSignal,
        pEtiquetageIndoor,
        pEtiquetageOutdoor,
        pPassageCable,
        pFicheInstalation,
        pSpeedTest,
        commentaireTextField

      ],
    );

    addFieldBlocs(
      step: 3,
      fieldBlocs: [commentaireTextField],
    );


    etatDropDown.onValueChanges(
      onData: (previous, current) async* {
        // String currentId = current.value?.id ?? "" ;
        // List<SousEtat>? sousEtat = responseListEtat.etat?.firstWhere((element) => element.id == currentId).sousEtat! ?? []

        if(current.value?.id == null){
          return ;
        }
        print("etatDropDown onValueChanges ");
        print("current.value? ==> ${current.value} ");
        print(current.value?.id ?? "...");

        removeFieldBlocs(
            fieldBlocs: [motifDropDown]);

        removeFieldBlocs(
            fieldBlocs: [
              etatImmo,
              newLatitude,
              newLongitude,
              newAdresse,
            ]);

        if (current.value?.id == "1") {
          addFieldBloc(
              fieldBloc: rdvDate);

          removeFieldBlocs(
              fieldBlocs: [
                sousEtatDropDown,
                pPbiAvantTextField,
                pPbiApresTextField,
                pPboAvantTextField,
                pPboApresTextField
              ]);
        } else if (current.value?.id == "3") {
          addFieldBlocs(
              fieldBlocs: [
                pPbiAvantTextField,
                pPbiApresTextField,
                pPboAvantTextField,
                pPboApresTextField
              ]);

          removeFieldBlocs(
              fieldBlocs: [
                rdvDate,
                sousEtatDropDown,
              ]);
        } else {
          removeFieldBlocs(
              fieldBlocs: [
                rdvDate,
                pPbiAvantTextField,
                pPbiApresTextField,
                pPboAvantTextField,
                pPboApresTextField
              ]);

          if (current.value?.sousEtat?.isEmpty == true) {
            removeFieldBloc(
                fieldBloc: sousEtatDropDown);
          } else {
            sousEtatDropDown.updateItems(current.value?.sousEtat ?? []);
            addFieldBloc(
                fieldBloc: sousEtatDropDown);
          }
        }
      },
    );

    sousEtatDropDown.onValueChanges(
      onData: (previous, current) async* {
        // String currentId = current.value?.id ?? "" ;
        // List<SousEtat>? sousEtat = responseListEtat.etat?.firstWhere((element) => element.id == currentId).sousEtat! ?? []

        if(current.value?.id == null){
          return ;
        }

        print("sousEtatDropDown onValueChanges");
        print(current.value?.id ?? "...");
        print(current.value?.motifList ?? "...");

        removeFieldBlocs(
            fieldBlocs: [
              etatImmo,
              newLatitude,
              newLongitude,
              newAdresse,
            ]);

        if (current.value?.motifList?.isEmpty == true) {
          removeFieldBlocs(
              fieldBlocs: [motifDropDown]);
        } else {
          motifDropDown.updateItems(current.value?.motifList ?? []);
          addFieldBloc(
              fieldBloc: motifDropDown);
        }
      },
    );

    motifDropDown.onValueChanges(
      onData: (previous, current) async* {
        // String currentId = current.value?.id ?? "" ;
        // List<SousEtat>? sousEtat = responseListEtat.etat?.firstWhere((element) => element.id == currentId).sousEtat! ?? []

        if(current.value?.id == null){
          return ;
        }

        print("motifDropDown onValueChanges");
        print(current.value?.id ?? "...");

        if (etatDropDown.value?.id == "7" && sousEtatDropDown.value?.id == "8") {
          addFieldBlocs(
              fieldBlocs: [
                etatImmo,
                newLatitude,
                newLongitude,
                newAdresse,
              ]);
        } else {
          removeFieldBlocs(
              fieldBlocs: [
                etatImmo,
                newLatitude,
                newLongitude,
                newAdresse,
              ]);
        }
      },
    );


  }



  void writeToFileTraitementList(Map jsonMapContent) {
    print("Writing to writeToFileTraitementList!");


    try {

      for(var mapKey in jsonMapContent.keys){
        // print('${k}: ${v}');
        // print(k);

        if(mapKey == "p_pbi_avant"){
          jsonMapContent[mapKey] = pPbiAvantTextField.value?.path ;
        }else if(mapKey == "p_pbi_apres"){
          jsonMapContent[mapKey] = pPbiApresTextField.value?.path ;
        }else if(mapKey == "p_pbo_avant"){
          jsonMapContent[mapKey] = pPboAvantTextField.value?.path ;
        }else if(mapKey == "p_pbo_apres"){
          jsonMapContent[mapKey] = pPboApresTextField.value?.path ;
        }
        /*if(mapKey == "p_pbi_avant"
            || mapKey == "p_pbi_apres"
            || mapKey == "p_pbo_avant"
            || mapKey == "p_pbo_apres"
          ){

            jsonMapContent[mapKey] = (jsonMapContent[mapKey] as MultipartFile).filename ;
            // print(v);
          }*/
      }



      String fileContent =  fileTraitementList.readAsStringSync();
      print("file content ==> ${fileContent}");

      if(fileContent.isEmpty){
        print("empty file");

        Map emptyMap = {
          "traitementList" : []
        };

        fileTraitementList.writeAsStringSync(json.encode(emptyMap));

        fileContent =  fileTraitementList.readAsStringSync();

      }


      Map traitementListMap =
      json.decode(fileContent);

      print("file content decode ==> ${traitementListMap}");


      List traitementList =  traitementListMap["traitementList"] ;

      traitementList.add(json.encode(jsonMapContent));

      traitementListMap["traitementList"] = traitementList ;

      fileTraitementList.writeAsStringSync(json.encode(traitementListMap));


    } catch (e) {
      print("exeption -- "+e.toString());
    }

  }


  void fethchFileTraitementList(Map jsonMapContent) {
    print("fethchFileTraitementList!");

    try {

      Map traitementListMap =
      json.decode(fileTraitementList.readAsStringSync());
      print(traitementListMap);


      List traitementList = traitementListMap.values.elementAt(0);

      traitementList.forEach((element) {

      });
      fileTraitementList.writeAsStringSync(json.encode(traitementListMap));


    } catch (e) {
      print("exeption -- "+e.toString());
    }

  }

  @override
  void onLoading() async {
    Tools.initFiles();


    getApplicationDocumentsDirectory().then((Directory directory) {
      dir = directory;
      fileTraitementList = new File(dir.path + "/fileTraitementList.json");

      if(!fileTraitementList.existsSync()){
        fileTraitementList.createSync();
      }

    });

    try {

      responseListEtat = await Tools.getListEtatFromLocalAndINternet() ;

      print(responseListEtat.etat.toString());


      if(Tools.currentStep == 0){
        // responseListEtat.etat = responseListEtat.etat?.take(3).toList();
        etatDropDown.updateItems(responseListEtat.etat?.take(3).toList() ?? []);


      }else{
        // responseListEtat.etat = responseListEtat.etat?.skip(3).toList();
        etatDropDown.updateItems(responseListEtat.etat?.skip(3).toList() ?? []);

      }


      // print(responseListEtat.etat.toString());
      // etatDropDown.updateItems(responseListEtat.etat ?? []);


      emitLoaded();

      // emit(FormBlocLoaded(currentStep: Tools.currentStep));
      // emit(FormBlocLoaded(currentStep: 1));

    } catch (e) {
      print(e);
      emitLoadFailed(failureResponse: e.toString());
    }


  }


  @override
  void updateCurrentStep(int step) {

    print("override updateCurrentStep");
    print("Tools.currentStep ==> ${Tools.currentStep }");

    clearInputs();


    super.updateCurrentStep(step);

  }

  @override
  void previousStep() {
    print("override previousStep");
    print("Tools.currentStep ==> ${Tools.currentStep }");

    clearInputs();




    super.previousStep();

  }



  @override
  void onSubmitting() async {
    if (state.currentStep == 0) {

      print("InterventionStep1FormBloc onSubmitting() ");
      print('onSubmittinga ${state.toJson()}');


      try {

        final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:s');
        final String dateNowFormatted = formatter.format(DateTime.now());



        Map<String, dynamic> formDateValues = await state.toJson();

        formDateValues.addAll({
          "etape" : "1",
          "demande_id" : Tools.selectedDemande?.id ?? "",
          "user_id" : Tools.userId,
          "date" : dateNowFormatted
        });


        print(formDateValues);

        print("dio start");


        var connectivityResult = await (Connectivity().checkConnectivity());
        if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {
          print('YAY! Free cute dog pics!');

          bool checkCallWs = await Tools.callWsAddMobile(formDateValues);

          if(checkCallWs){
            emitSuccess(canSubmitAgain: true);

          }else{
            emitFailure(failureResponse: "WS");

          }

        } else if (connectivityResult == ConnectivityResult.none) {
          print('No internet :( Reason:');
          writeToFileTraitementList(formDateValues);
          emitSuccess();

        }






        // readJson();
      } catch (e) {
        emitFailure();
      }


    } else if (state.currentStep == 1) {
      await Future.delayed(Duration(milliseconds: 500));
      emitSuccess(canSubmitAgain: true, );

    } else if (state.currentStep == 2) {
      await Future.delayed(Duration(milliseconds: 500));
      emitSuccess(canSubmitAgain: true);

    }
  }




  void clearInputs() {
    print("clearInputs()");
    print("Tools.currentStep ==> ${Tools.currentStep }");

    clear();


    if(Tools.currentStep == 0){
      // responseListEtat.etat = responseListEtat.etat?.take(3).toList();
      etatDropDown.updateItems(responseListEtat.etat?.take(3).toList() ?? []);


    }else{
      // responseListEtat.etat = responseListEtat.etat?.skip(3).toList();
      etatDropDown.updateItems(responseListEtat.etat?.skip(3).toList() ?? []);

    }

    removeFieldBlocs(
        fieldBlocs: [
          sousEtatDropDown,
          motifDropDown,
          rdvDate,
          pPbiAvantTextField,
          pPbiApresTextField,
          pPboAvantTextField,
          pPboApresTextField
        ]);

    removeFieldBlocs(
        fieldBlocs: [
          etatImmo,
          newLatitude,
          newLongitude,
          newAdresse,
        ]);


    if(Tools.selectedDemande?.etatId == "5"){
      pSpeedTest.removeValidators([FieldBlocValidators.required,]);
    }else{
      pSpeedTest.addValidators([FieldBlocValidators.required,]);

    }
  }
}

class WizardForm extends StatefulWidget {
  @override
  _WizardFormState createState() => _WizardFormState();
}

class _WizardFormState extends State<WizardForm> {
  var _type = StepperType.horizontal;

  void _toggleType() {
    setState(() {
      if (_type == StepperType.horizontal) {
        _type = StepperType.vertical;
      } else {
        _type = StepperType.horizontal;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WizardFormBloc(),
      child: Builder(
        builder: (context) {
          return Theme(
            data: Theme.of(context).copyWith(
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            child: Scaffold(
              key: formStepperScaffoldKey,
              resizeToAvoidBottomInset: true,
              appBar: AppBar(
                leading: Builder(
                  builder: (BuildContext context) {
                    final ScaffoldState? scaffold = Scaffold.maybeOf(context);
                    final ModalRoute<Object?>? parentRoute = ModalRoute.of(context);
                    final bool hasEndDrawer = scaffold?.hasEndDrawer ?? false;
                    final bool canPop = parentRoute?.canPop ?? false;

                    if (hasEndDrawer && canPop) {
                      return BackButton();
                    } else {
                      return SizedBox.shrink();
                    }
                  },
                ),

                title: Text('Intervention'),
                actions: <Widget>[

                  NamedIcon(
                    text: '',
                    iconData: _type == StepperType.horizontal
                        ? Icons.swap_vert
                        : Icons.swap_horiz,
                    onTap: _toggleType
                  ),
                  NamedIcon(
                    text: '',
                    iconData: Icons.comment,
                    notificationCount: Tools.selectedDemande?.commentaires?.length ?? 0,
                    onTap: () {
                      formStepperScaffoldKey.currentState?.openEndDrawer();
                    },
                  ),

                ],
              ),
              endDrawer: EndDrawerWidget(),

              body: SafeArea(
                child: FormBlocListener<WizardFormBloc, String, String>(
                  onSubmitting: (context, state) {
                    LoadingDialog.show(context);
                  },
                  onSuccess: (context, state) {
                    LoadingDialog.hide(context);


                    Tools.currentStep = state.currentStep ;
                    context.read<WizardFormBloc>().clearInputs();


                    if (state.stepCompleted == state.lastStep) {
                      Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => SuccessScreen()));
                    }
                  },
                  onFailure: (context, state) {
                    LoadingDialog.hide(context);
                  },
                  onSubmissionFailed: (context, state) {
                    LoadingDialog.hide(context);
                  },
                  child: StepperFormBlocBuilder<WizardFormBloc>(
                    formBloc: context.read<WizardFormBloc>(),
                    type: _type,
                    physics: ClampingScrollPhysics(),
                    // onStepCancel: (formBloc) {
                    //   print("Cancel clicked");
                    //
                    //
                    //
                    // },
                    controlsBuilder: (
                        BuildContext context,
                        VoidCallback? onStepContinue,
                        VoidCallback? onStepCancel,
                        int step,
                        FormBloc formBloc,
                        ) {
                      return Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              SizedBox(
                                height: 50,
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      print("cliick");
                                      // formBloc.readJson();
                                      // formBloc.fileTraitementList.writeAsStringSync("");


                                      formBloc.submit();
                                    },
                                    child: const Text('Enregistrer',
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
                                ),
                              ),
                              if (!formBloc.state.isFirstStep
                                  &&  !formBloc.state.isLastStep
                              )
                                // Expanded(
                                //   child: ElevatedButton(
                                //     onPressed: () {
                                //       print("cliick");
                                //       // formBloc.readJson();
                                //       // formBloc.fileTraitementList.writeAsStringSync("");
                                //
                                //       // context.read<WizardFormBloc>().clear();
                                //
                                //
                                //
                                //       onStepCancel!() ;
                                //     },
                                //     child: const Text('Annuler',
                                //       textAlign: TextAlign.center,
                                //       style: TextStyle(
                                //         fontSize: 18.0,
                                //         wordSpacing: 12,
                                //       ),
                                //     ),
                                //     style: ElevatedButton.styleFrom(
                                //       primary: Colors.grey,
                                //       // shape: CircleBorder(),
                                //       minimumSize: Size(200, 50),
                                //       // primary: Tools.colorPrimary,
                                //       shape: RoundedRectangleBorder(
                                //         borderRadius: new BorderRadius.circular(30.0),
                                //       ),
                                //
                                //     ),
                                //   ),
                                // ),
                              SizedBox(
                                height: 50,
                              ),
//                              Text(Translations.of(context).confidential)
                            ],
                          ),

                        ],
                      );
                    },
                    stepsBuilder: (formBloc) {
                      return [
                        _step1(formBloc!),
                        _step2(formBloc),
                        _step3(formBloc),
                      ];
                    },
                    onStepTapped: (FormBloc? formBloc, int step){
                      print("onStepTapped");
                      if(step > 0){
                        if(
                        !(Tools.selectedDemande?.etatId == "3"
                            && Tools.selectedDemande?.pPbiAvant != ""
                            && Tools.selectedDemande?.pPbiApres != "")

                        ){
                          // Navigator.of(context).push(MaterialPageRoute(
                          //   builder: (_) => InterventionFormStep2(),
                          // ));
                          return ;
                        }
                      }
                      Tools.currentStep = step ;
                      print(formBloc);
                      formBloc?.updateCurrentStep(step);
                      // formBloc?.emit(FormBlocLoaded(currentStep: Tools.currentStep));
                    },
                  ),

                ),
              ),
            ),
          );
        },
      ),
    );
  }

  FormBlocStep _step1(WizardFormBloc wizardFormBloc) {
    return FormBlocStep(
      title: Text('Etape 1'),
      content:  Column(
        children: <Widget>[
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
            selectFieldBloc: wizardFormBloc.etatDropDown,
            decoration: const InputDecoration(
              labelText: 'Etat',
              prefixIcon: Icon(Icons.list),
            ),
            itemBuilder: (context, value) => FieldItem(
              child: Text(value.name ?? ""),
            ),
          ),
          DateTimeFieldBlocBuilder(
            dateTimeFieldBloc: wizardFormBloc.rdvDate,
            format: DateFormat('yyyy-MM-dd HH:mm'),
            //  Y-m-d H:i:s
            initialDate: DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime(2100),
            canSelectTime: true,
            decoration: const InputDecoration(
              labelText: 'Rendez-vous',
              prefixIcon: Icon(Icons.date_range),
            ),
          ),
          DropdownFieldBlocBuilder<SousEtat>(
            selectFieldBloc: wizardFormBloc.sousEtatDropDown,
            decoration: const InputDecoration(
              labelText: 'Sous Etat',
            ),
            itemBuilder: (context, value) => FieldItem(
              child: Text(value.name ?? ""),
            ),
          ),
          DropdownFieldBlocBuilder<MotifList>(
            selectFieldBloc: wizardFormBloc.motifDropDown,
            decoration: const InputDecoration(
              labelText: 'Morif',
            ),
            itemBuilder: (context, value) => FieldItem(
              child: Text(value.name ?? ""),
            ),
          ),
          Container(
            // margin: const EdgeInsets.only(top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                //Center Row contents horizontally,
                crossAxisAlignment: CrossAxisAlignment.center,
                //Center Row contents vertically,
                children: [
                  Flexible(
                    child: ImageFieldBlocBuilder(
                      formBloc: wizardFormBloc,
                      fileFieldBloc: wizardFormBloc.pPbiAvantTextField,
                      labelText: "PBI avant ",
                      iconField: Icon(Icons.image_not_supported),
                    ),
                  ),
                  Flexible(
                    // flex: 2,
                    child: ImageFieldBlocBuilder(
                      formBloc: wizardFormBloc,
                      fileFieldBloc: wizardFormBloc.pPbiApresTextField,
                      labelText: "PBI apres ",
                      iconField: Icon(Icons.image_not_supported),
                    ),
                  ),
                ],
              )),
          Container(
            // margin: const EdgeInsets.only(top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                //Center Row contents horizontally,
                crossAxisAlignment: CrossAxisAlignment.center,
                //Center Row contents vertically,
                children: [
                  Flexible(
                    child: ImageFieldBlocBuilder(
                      formBloc: wizardFormBloc,
                      fileFieldBloc: wizardFormBloc.pPboAvantTextField,
                      labelText: "PBO avant ",
                      iconField: Icon(Icons.image_not_supported),
                    ),
                  ),
                  Flexible(
                    // flex: 2,
                    child: ImageFieldBlocBuilder(
                      formBloc: wizardFormBloc,
                      fileFieldBloc: wizardFormBloc.pPboApresTextField,
                      labelText: "PBO apres ",
                      iconField: Icon(Icons.image_not_supported),
                    ),
                  ),
                ],
              )),

          TextFieldBlocBuilder(
            textFieldBloc: wizardFormBloc.commentaireTextField,
            keyboardType: TextInputType.text,
            minLines: 6,
            maxLines: 20,
            decoration: InputDecoration(
              labelText: "Commentaire",
              prefixIcon: Icon(Icons.comment),

            ),
          ),


        ],
      ),
    );
  }

  FormBlocStep _step2(WizardFormBloc formBloc) {
    return FormBlocStep(
      title: Text('Etape 2'),
      content: Column(
        children: <Widget>[
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

          // Divider(
          //   color: Colors.black,
          // ),
          TextFieldBlocBuilder(
            textFieldBloc:
            formBloc.etatImmo,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              labelText: "Etat immeble ",
              prefixIcon: Icon(Icons.gps_fixed),
            ),
          ),
          CanShowFieldBlocBuilder(
            fieldBloc: formBloc.newLongitude,
            builder: (BuildContext context, bool canShow) {
              return Container(
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
                                formBloc.newLatitude,
                                clearTextIcon: Icon(Icons.cancel),
                                suffixButton: SuffixButton.clearText,
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                  labelText: "Nouvelle latitude ",
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
                                formBloc.newLongitude,
                                keyboardType: TextInputType.text,
                                clearTextIcon: Icon(Icons.cancel),
                                suffixButton: SuffixButton.clearText,
                                decoration: InputDecoration(
                                  labelText: "Nouvelle Longitude ",
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
                            await Tools.determinePosition();
                            if (position != null) {
                              formBloc.newLatitude.updateValue(
                                  position.latitude
                                      .toStringAsFixed(4));
                              formBloc.newLongitude
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
                  ));
            },
          ),
          TextFieldBlocBuilder(
            textFieldBloc:
            formBloc.newAdresse,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              labelText: "Nouvelle adresse ",
              prefixIcon: Icon(Icons.gps_fixed),
            ),
          ),

          // Divider(
          //   color: Colors.black,
          // ),

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
                              labelText: "Latitude ",
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
                              labelText: "Longitude ",
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
                        await Tools.determinePosition();
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


        ],
      ),
    );
  }

  FormBlocStep _step3(WizardFormBloc wizardFormBloc) {
    return FormBlocStep(
      title: Text('Etape 3'),
      content: Column(
        children: <Widget>[
          Container(
            // margin: const EdgeInsets.only(top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                //Center Row contents horizontally,
                crossAxisAlignment: CrossAxisAlignment.center,
                //Center Row contents vertically,
                children: [
                  Flexible(
                    child: ImageFieldBlocBuilder(
                      formBloc: wizardFormBloc,
                      fileFieldBloc: wizardFormBloc.pEquipementInstalle,
                      labelText: "Equipement installé ",
                      iconField: Icon(Icons.image_not_supported),
                    ),
                  ),
                  Flexible(
                    // flex: 2,
                    child: ImageFieldBlocBuilder(
                      formBloc: wizardFormBloc,
                      fileFieldBloc: wizardFormBloc.pTestSignal,
                      labelText: "Test signal ",
                      iconField: Icon(Icons.image_not_supported),
                    ),
                  ),
                ],
              )),
          Container(
            // margin: const EdgeInsets.only(top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                //Center Row contents horizontally,
                crossAxisAlignment: CrossAxisAlignment.center,
                //Center Row contents vertically,
                children: [
                  Flexible(
                    child: ImageFieldBlocBuilder(
                      formBloc: wizardFormBloc,
                      fileFieldBloc: wizardFormBloc.pEtiquetageIndoor,
                      labelText: "Etiquetage indoor ",
                      iconField: Icon(Icons.image_not_supported),
                    ),
                  ),
                  Flexible(
                    // flex: 2,
                    child: ImageFieldBlocBuilder(
                      formBloc: wizardFormBloc,
                      fileFieldBloc: wizardFormBloc.pEtiquetageOutdoor,
                      labelText: "Etiquetage outdoor ",
                      iconField: Icon(Icons.image_not_supported),
                    ),
                  ),
                ],
              )),
          Container(
            // margin: const EdgeInsets.only(top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                //Center Row contents horizontally,
                crossAxisAlignment: CrossAxisAlignment.center,
                //Center Row contents vertically,
                children: [
                  Flexible(
                    child: ImageFieldBlocBuilder(
                      formBloc: wizardFormBloc,
                      fileFieldBloc: wizardFormBloc.pPassageCable,
                      labelText: "Passage cable ",
                      iconField: Icon(Icons.image_not_supported),
                    ),
                  ),
                  Flexible(
                    // flex: 2,
                    child: ImageFieldBlocBuilder(
                      formBloc: wizardFormBloc,
                      fileFieldBloc: wizardFormBloc.pFicheInstalation,
                      labelText: "Fiche instalation ",
                      iconField: Icon(Icons.image_not_supported),
                    ),
                  ),
                ],
              )),
              Center(
                child: ImageFieldBlocBuilder(
                  formBloc: wizardFormBloc,
                  fileFieldBloc: wizardFormBloc.pSpeedTest,
                  labelText: "Speed test ",
                  iconField: Icon(Icons.image_not_supported),
                ),
              ),
        ],
      ),
    );
  }
}



class EndDrawerWidget extends StatelessWidget {
  const EndDrawerWidget({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/bg_home.jpg"),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: [
              Text("Commentaires"),
              Expanded(
                child: Timeline.tileBuilder(
                  builder: TimelineTileBuilder.fromStyle(
                    contentsBuilder: (context, index) => Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(Tools.selectedDemande?.commentaires?[0].commentaire ?? ""),
                      ),
                    ),
                    // oppositeContentsBuilder: (context, index) => Padding(
                    //   padding: const EdgeInsets.all(8.0),
                    //   child: Text('opposite\ncontents'),
                    // ),
                    contentsAlign: ContentsAlign.alternating,
                    indicatorStyle: IndicatorStyle.outlined,
                    connectorStyle: ConnectorStyle.dashedLine,
                    itemCount: Tools.selectedDemande?.commentaires?.length ?? 0,
                  ),
                ),
              ),
            ],
          ),

        ),
      ),
    );
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

  LoadingDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Center(
        child: Card(
          child: Container(
            width: 80,
            height: 80,
            padding: EdgeInsets.all(12.0),
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}

class SuccessScreen extends StatelessWidget {
  SuccessScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.tag_faces, size: 100),
            SizedBox(height: 10),
            Text(
              'Success',
              style: TextStyle(fontSize: 54, color: Colors.black),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => WizardForm())),
              icon: Icon(Icons.replay),
              label: Text('AGAIN'),
            ),
          ],
        ),
      ),
    );
  }
}

class NamedIcon extends StatelessWidget {
  final IconData iconData;
  final String text;
  final VoidCallback? onTap;
  final int notificationCount;

  const NamedIcon({
    Key? key,
    this.onTap,
    required this.text,
    required this.iconData,
    this.notificationCount = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 50,
        padding: const EdgeInsets.only(top: 15),

        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(iconData),
                Text(text, overflow: TextOverflow.ellipsis),
              ],
            ),
            if(notificationCount > 0)
            Positioned(
              top: 10,
              right: 30,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.red),
                alignment: Alignment.center,
                child: Text('$notificationCount'),
              ),
            )
          ],
        ),
      ),
    );
  }
}