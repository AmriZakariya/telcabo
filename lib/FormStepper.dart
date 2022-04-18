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

final GlobalKey<ScaffoldState> formStepperScaffoldKey =
    new GlobalKey<ScaffoldState>();

class WizardFormBloc extends FormBloc<String, String> {
  late final ResponseGetListEtat responseListEtat;
  late final ResponseGetListType responseGetListType;

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

  final etatImmeubleDropDown = SelectFieldBloc<Etatimmeubles, dynamic>(
    name: "Etat_immo",
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

  final dateRdvInputFieldBLoc = InputFieldBloc<DateTime?, Object>(
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


  final listTypeInstallationDropDown = SelectFieldBloc<Types, dynamic>(
    name: "type_installation_id",
    validators: [
      FieldBlocValidators.required,
    ],
    toJson: (value) => value?.id,

  );

  final motiflistTypeInstallationDropDown = SelectFieldBloc<Motifs, dynamic>(
    name: "motif_typeinstallation_id",
    validators: [
      FieldBlocValidators.required,
    ],
    toJson: (value) => value?.id,
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

  final dnsnTextField = TextFieldBloc(
    name: 'dnsn',
    validators: [
      FieldBlocValidators.required,
    ],
  );
  final snTelTextField = TextFieldBloc(
    name: 'sn_tel',
    validators: [
      // FieldBlocValidators.required,
    ],
  );
  final snGpomTextField = TextFieldBloc(
    name: 'sn_routeur',
    validators: [
      FieldBlocValidators.required,
    ],
  );

  // final etatImmo = TextFieldBloc(
  //   name: 'etat_immo',
  //   validators: [
  //     FieldBlocValidators.required,
  //   ],
  // );
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


  final ptoTextField = TextFieldBloc(
    name: 'pto',
    validators: [
      FieldBlocValidators.required,
    ],
  );

  final jarretieresTextField = TextFieldBloc(
    name: 'jarretieres',
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

  WizardFormBloc() : super(isLoading: true) {
    Tools.currentStep = (Tools.selectedDemande?.etape ?? 1) - 1;

    print("Tools.currentStep ==> ${Tools.currentStep}");
    emit(FormBlocLoading(currentStep: Tools.currentStep));

    addFieldBlocs(
      step: 0,
      fieldBlocs: [etatDropDown, commentaireTextField],
    );
    addFieldBlocs(
      step: 1,
      fieldBlocs: [
        etatDropDown,
        listTypeInstallationDropDown,
        commentaireTextField,
        traitementConsommationCableTextField,
        speedTextField,
        debitTextField,
        latitudeTextField,
        longintudeTextField,
        adresseMacTextField,
        dnsnTextField,
        snTelTextField,
        snGpomTextField,
        ptoTextField,
        jarretieresTextField
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

    // addFieldBlocs(
    //   step: 3,
    //   fieldBlocs: [commentaireTextField],
    // );

    etatDropDown.onValueChanges(
      onData: (previous, current) async* {
        // String currentId = current.value?.id ?? "" ;
        // List<SousEtat>? sousEtat = responseListEtat.etat?.firstWhere((element) => element.id == currentId).sousEtat! ?? []

        if (current.value?.id == null) {
          return;
        }

        print("etatDropDown onValueChanges ");
        print("current.value? ==> ${current.value} ");
        print(current.value?.id ?? "...");

        removeFieldBlocs(fieldBlocs: [motifDropDown, etatImmeubleDropDown]);

        removeFieldBlocs(fieldBlocs: [
          // etatImmo,
          etatImmeubleDropDown,
          newLatitude,
          newLongitude,
          newAdresse,
        ]);

        if (current.value?.id == "1") {}
        if (current.value?.id == "1") {

          /* check current RDV date */
          String? selectedRdvDate = Tools.selectedDemande?.dateRdv ;
          if(selectedRdvDate?.isNotEmpty == true){
            print("selected rdvDate ==> ${selectedRdvDate}");

            var parsedDate = DateTime.parse(selectedRdvDate!);

            dateRdvInputFieldBLoc.updateValue(parsedDate);

          }else{
            dateRdvInputFieldBLoc.updateValue(null);

          }


          addFieldBloc(fieldBloc: dateRdvInputFieldBLoc);

          removeFieldBlocs(fieldBlocs: [
            sousEtatDropDown,
            pPbiAvantTextField,
            pPbiApresTextField,
            pPboAvantTextField,
            pPboApresTextField
          ]);
        } else if (current.value?.id == "3") {
          addFieldBlocs(fieldBlocs: [
            pPbiAvantTextField,
            pPbiApresTextField,
            pPboAvantTextField,
            pPboApresTextField
          ]);

          removeFieldBlocs(fieldBlocs: [
            dateRdvInputFieldBLoc,
            sousEtatDropDown,
          ]);
        } else {
          removeFieldBlocs(fieldBlocs: [
            dateRdvInputFieldBLoc,
            pPbiAvantTextField,
            pPbiApresTextField,
            pPboAvantTextField,
            pPboApresTextField
          ]);

          if (current.value?.sousEtat?.isEmpty == true) {
            removeFieldBloc(fieldBloc: sousEtatDropDown);
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

        if (current.value?.id == null) {
          return;
        }

        print("sousEtatDropDown onValueChanges");
        print(current.value?.id ?? "...");
        print(current.value?.motifList ?? "...");

        removeFieldBlocs(fieldBlocs: [
          // etatImmo,
          etatImmeubleDropDown,
          newLatitude,
          newLongitude,
          newAdresse,
        ]);

        if (current.value?.motifList?.isEmpty == true) {
          removeFieldBlocs(fieldBlocs: [motifDropDown, etatImmeubleDropDown]);
        } else {
          motifDropDown.updateItems(current.value?.motifList ?? []);
          addFieldBloc(fieldBloc: motifDropDown);
        }
      },
    );

    motifDropDown.onValueChanges(
      onData: (previous, current) async* {
        // String currentId = current.value?.id ?? "" ;
        // List<SousEtat>? sousEtat = responseListEtat.etat?.firstWhere((element) => element.id == currentId).sousEtat! ?? []

        if (current.value?.id == null) {
          return;
        }

        print("motifDropDown onValueChanges");
        print(current.value?.id ?? "...");

        if (etatDropDown.value?.id == "7" &&
            sousEtatDropDown.value?.id == "8") {
          addFieldBlocs(fieldBlocs: [
            // etatImmo,
            etatImmeubleDropDown,
            newLatitude,
            newLongitude,
            newAdresse,
          ]);
        } else {
          removeFieldBlocs(fieldBlocs: [
            etatImmeubleDropDown,
            newLatitude,
            newLongitude,
            newAdresse,
          ]);
        }

        print("++++");

        if (current.value?.etatimmeubles?.isEmpty == true) {
          removeFieldBloc(fieldBloc: etatImmeubleDropDown);

        } else {

          etatImmeubleDropDown.updateItems(current.value?.etatimmeubles ?? []);
          // addFieldBloc(fieldBloc: motifDropDown);
        }


      },
    );




    /* Manage listTypeInstallationDropDown */


    listTypeInstallationDropDown.onValueChanges(
      onData: (previous, current) async* {
        // String currentId = current.value?.id ?? "" ;
        // List<SousEtat>? sousEtat = responseListEtat.etat?.firstWhere((element) => element.id == currentId).sousEtat! ?? []

        if (current.value?.id == null) {
          return;
        }

        print("listTypeInstallationDropDown onValueChanges ");
        print("current.value? ==> ${current.value} ");
        print(current.value?.id ?? "...");


        if (current.value?.motifs?.isEmpty == true) {
          removeFieldBloc(fieldBloc: motiflistTypeInstallationDropDown);
        } else {
          motiflistTypeInstallationDropDown.updateItems(current.value?.motifs ?? []);
          addFieldBloc(fieldBloc: motiflistTypeInstallationDropDown);
        }


      },
    );



  }

  void writeToFileTraitementList(Map jsonMapContent) {
    print("Writing to writeToFileTraitementList!");

    try {
      for (var mapKey in jsonMapContent.keys) {
        // print('${k}: ${v}');
        // print(k);

        if (mapKey == "p_pbi_avant") {
          jsonMapContent[mapKey] = pPbiAvantTextField.value?.path;
        } else if (mapKey == "p_pbi_apres") {
          jsonMapContent[mapKey] = pPbiApresTextField.value?.path;
        } else if (mapKey == "p_pbo_avant") {
          jsonMapContent[mapKey] = pPboAvantTextField.value?.path;
        } else if (mapKey == "p_pbo_apres") {
          jsonMapContent[mapKey] = pPboApresTextField.value?.path;
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

      String fileContent = fileTraitementList.readAsStringSync();
      print("file content ==> ${fileContent}");

      if (fileContent.isEmpty) {
        print("empty file");

        Map emptyMap = {"traitementList": []};

        fileTraitementList.writeAsStringSync(json.encode(emptyMap));

        fileContent = fileTraitementList.readAsStringSync();
      }

      Map traitementListMap = json.decode(fileContent);

      print("file content decode ==> ${traitementListMap}");

      List traitementList = traitementListMap["traitementList"];

      traitementList.add(json.encode(jsonMapContent));

      traitementListMap["traitementList"] = traitementList;

      fileTraitementList.writeAsStringSync(json.encode(traitementListMap));
    } catch (e) {
      print("exeption -- " + e.toString());
    }
  }

  void fethchFileTraitementList(Map jsonMapContent) {
    print("fethchFileTraitementList!");

    try {
      Map traitementListMap =
          json.decode(fileTraitementList.readAsStringSync());
      print(traitementListMap);

      List traitementList = traitementListMap.values.elementAt(0);

      traitementList.forEach((element) {});
      fileTraitementList.writeAsStringSync(json.encode(traitementListMap));
    } catch (e) {
      print("exeption -- " + e.toString());
    }
  }

  @override
  void onLoading() async {
    Tools.initFiles();

    getApplicationDocumentsDirectory().then((Directory directory) {
      dir = directory;
      fileTraitementList = new File(dir.path + "/fileTraitementList.json");

      if (!fileTraitementList.existsSync()) {
        fileTraitementList.createSync();
      }
    });

    try {
      responseListEtat = await Tools.getListEtatFromLocalAndINternet();
      responseGetListType = await Tools.getTypeListFromLocalAndINternet();

      print(responseListEtat.etat.toString());

      if (Tools.currentStep == 0) {
        // responseListEtat.etat = responseListEtat.etat?.take(3).toList();
        etatDropDown.updateItems(responseListEtat.etat?.take(3).toList() ?? []);
      } else {
        // responseListEtat.etat = responseListEtat.etat?.skip(3).toList();
        etatDropDown.updateItems(responseListEtat.etat?.skip(3).toList() ?? []);
      }


      listTypeInstallationDropDown.updateItems(responseGetListType.types ?? []);

      // print(responseListEtat.etat.toString());
      // etatDropDown.updateItems(responseListEtat.etat ?? []);

      updateInputsFromDemande();

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
    print("Tools.currentStep ==> ${Tools.currentStep}");

    clearInputs();

    super.updateCurrentStep(step);
  }

  @override
  void previousStep() {
    print("override previousStep");
    print("Tools.currentStep ==> ${Tools.currentStep}");

    clearInputs();

    super.previousStep();
  }

  @override
  void onSubmitting() async {
    print("FormStepper onSubmitting() ");
    print("Tools.currentStep ==> ${Tools.currentStep}");
    print('onSubmittinga ${state.toJson()}');

    try {
      final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:s');
      final String dateNowFormatted = formatter.format(DateTime.now());

      Map<String, dynamic> formDateValues = await state.toJson();

      formDateValues.addAll({
        "etape": Tools.currentStep + 1,
        "demande_id": Tools.selectedDemande?.id ?? "",
        "user_id": Tools.userId,
        "date": dateNowFormatted
      });

      print(formDateValues);

      print("dio start");

      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.mobile ||
          connectivityResult == ConnectivityResult.wifi) {
        print('YAY! Free cute dog pics!');

        bool checkCallWs = await Tools.callWsAddMobile(formDateValues);

        if (checkCallWs) {

          if(await Tools.refreshSelectedDemande()){

            print("refreshed refreshSelectedDemande");
            print("Tools.selectedDemande ==> ${Tools.selectedDemande?.etape}");
            print("state.currentStep ==> ${state.currentStep}");

            if(((Tools.selectedDemande?.etape ?? 1 ) - 1) <= state.currentStep ){
              commentaireTextField.updateValue("");
              emitFailure(failureResponse: "sameStep");

            }else{
              commentaireTextField.updateValue("");
              emitSuccess(canSubmitAgain: true);
            }

          }
        } else {
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

    if (state.currentStep == 0) {
    } else if (state.currentStep == 1) {
    } else if (state.currentStep == 2) {}
  }

  void clearInputs() {
    print("clearInputs()");
    print("Tools.currentStep ==> ${Tools.currentStep}");

    clear();

    if (Tools.currentStep == 0) {
      // responseListEtat.etat = responseListEtat.etat?.take(3).toList();
      etatDropDown.updateItems(responseListEtat.etat?.take(3).toList() ?? []);
    } else {
      // responseListEtat.etat = responseListEtat.etat?.skip(3).toList();
      etatDropDown.updateItems(responseListEtat.etat?.skip(3).toList() ?? []);
    }

    removeFieldBlocs(fieldBlocs: [
      sousEtatDropDown,
      motifDropDown,
      dateRdvInputFieldBLoc,
      pPbiAvantTextField,
      pPbiApresTextField,
      pPboAvantTextField,
      pPboApresTextField
    ]);

    removeFieldBlocs(fieldBlocs: [
      // etatImmo,
      etatImmeubleDropDown,
      newLatitude,
      newLongitude,
      newAdresse,
    ]);

    if (Tools.selectedDemande?.etatId == "5") {
      pSpeedTest.removeValidators([
        FieldBlocValidators.required,
      ]);
    } else {
      pSpeedTest.addValidators([
        FieldBlocValidators.required,
      ]);
    }


    updateInputsFromDemande();
  }

  void updateInputsFromDemande() {
    var selectedEtat = responseListEtat.etat?.firstWhereOrNull((element) {
      return element.id == Tools.selectedDemande?.etatId;
    });
    print("selectedEtat ==> ${selectedEtat}");

    if (selectedEtat != null) {
      if (etatDropDown.state.items.contains(selectedEtat)) {
        etatDropDown.updateValue(selectedEtat);
      } else {
        etatDropDown.addItem(selectedEtat);
        etatDropDown.updateValue(selectedEtat);
      }
    }

    var selectedSousEtat = etatDropDown.value?.sousEtat?.firstWhereOrNull((element) {
      return element.id == Tools.selectedDemande?.subStatutId;
    });
    print("selectedSousEtat ==> ${selectedSousEtat}");

    if (selectedSousEtat != null) {
      if (sousEtatDropDown.state.items.contains(selectedSousEtat)) {
        sousEtatDropDown.updateValue(selectedSousEtat);
      } else {
        sousEtatDropDown.addItem(selectedSousEtat);
        sousEtatDropDown.updateValue(selectedSousEtat);
      }
    }



    var selectedMotif = sousEtatDropDown.value?.motifList?.firstWhereOrNull((element) {
      return element.id == Tools.selectedDemande?.motifEtatId;
    });

    print("selectedMotif ==> ${selectedMotif}");

    if (selectedMotif != null) {
      if (motifDropDown.state.items.contains(selectedMotif)) {
        motifDropDown.updateValue(selectedMotif);
      } else {
        motifDropDown.addItem(selectedMotif);
        motifDropDown.updateValue(selectedMotif);
      }
    }

    traitementConsommationCableTextField.updateValue(Tools.selectedDemande?.consommationCable ?? "");
    speedTextField.updateValue(Tools.selectedDemande?.speed ?? "");
    debitTextField.updateValue(Tools.selectedDemande?.debit ?? "");
    latitudeTextField.updateValue(Tools.selectedDemande?.latitude ?? "");
    longintudeTextField.updateValue(Tools.selectedDemande?.longitude ?? "");
    adresseMacTextField.updateValue(Tools.selectedDemande?.adresseMac ?? "");
    dnsnTextField.updateValue(Tools.selectedDemande?.dnsn ?? "");
    snTelTextField.updateValue(Tools.selectedDemande?.snTel ?? "");
    snGpomTextField.updateValue(Tools.selectedDemande?.snRouteur ?? "");
    // snTelTextField.updateValue(Tools.selectedDemande?.snTel ?? "");

    ptoTextField.updateValue(Tools.selectedDemande?.pto ?? "");
    jarretieresTextField.updateValue(Tools.selectedDemande?.jarretieres ?? "");

    listTypeInstallationDropDown.updateValue(
      listTypeInstallationDropDown.state.items.firstWhereOrNull((element) {
        return element.id == Tools.selectedDemande?.typeInstallationId;
      })
    );

    motiflistTypeInstallationDropDown.updateValue(
        motiflistTypeInstallationDropDown.state.items.firstWhereOrNull((element) {
          return element.id == Tools.selectedDemande?.motifTypeinstallationId;
        })
    );


    String? selectedRdvDate = Tools.selectedDemande?.dateRdv ;
    if(selectedRdvDate?.isNotEmpty == true){
      print("selected rdvDate ==> ${selectedRdvDate}");

      var parsedDate = DateTime.parse(selectedRdvDate!);

      dateRdvInputFieldBLoc.updateValue(parsedDate);

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

  ValueNotifier<int> commentaireCuuntValueNotifer =ValueNotifier(Tools.selectedDemande?.commentaires?.length ?? 0);


  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<WizardFormBloc>(
          create: (BuildContext context) => WizardFormBloc(),
        ),
        BlocProvider<InternetCubit>(
          create: (BuildContext context) => InternetCubit(connectivity: Connectivity()),
        ),
      ],
      // c
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
                    final ModalRoute<Object?>? parentRoute =
                        ModalRoute.of(context);
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
                      onTap: _toggleType),
                  ValueListenableBuilder(
                    valueListenable: commentaireCuuntValueNotifer,
                    builder: (BuildContext context, int commentaireCount, Widget? child){
                      return NamedIcon(
                        text: '',
                        iconData: Icons.comment,
                        notificationCount: commentaireCount,
                        onTap: () {
                          formStepperScaffoldKey.currentState?.openEndDrawer();
                        },
                      );
                    },
                  )

                ],
              ),
              endDrawer: EndDrawerWidget(),
              body: SafeArea(
                child: FormBlocListener<WizardFormBloc, String, String>(
                  onSubmitting: (context, state) {
                    print("FormBlocListener onSubmitting");
                    LoadingDialog.show(context);
                  },
                  onSuccess: (context, state) {
                    print("FormBlocListener onSuccess");
                    LoadingDialog.hide(context);


                    commentaireCuuntValueNotifer.value = Tools.selectedDemande?.commentaires?.length ?? 0;
                    CoolAlert.show(
                      context: context,
                      type: CoolAlertType.success,
                      text: "Enregistré avec succès",
                      // autoCloseDuration: Duration(seconds: 2),
                      title: "Succès",
                    );





                    Tools.currentStep = state.currentStep;
                    context.read<WizardFormBloc>().clearInputs();


                    if (state.stepCompleted == state.lastStep) {
                      Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => SuccessScreen()));
                    }
                  },
                  onFailure: (context, state) {
                    print("FormBlocListener onFailure");
                    LoadingDialog.hide(context);

                    if(state.failureResponse == "sameStep"){
                      commentaireCuuntValueNotifer.value = Tools.selectedDemande?.commentaires?.length ?? 0;

                      CoolAlert.show(
                        context: context,
                        type: CoolAlertType.success,
                        text: "Enregistré avec succès",
                        // autoCloseDuration: Duration(seconds: 2),
                        title: "Succès",
                      );
                    }
                  },
                  onSubmissionFailed: (context, state) {
                    print("FormBlocListener onSubmissionFailed");
                    LoadingDialog.hide(context);
                  },
                  child: Stack(
                    children: [
                      StepperFormBlocBuilder<WizardFormBloc>(
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
                                      // padding: const  EdgeInsets.only(top: 8,left: 8,right: 8, bottom: 20),

                                      child: ElevatedButton(
                                        onPressed: () {
                                          print("cliick");
                                          // formBloc.readJson();
                                          // formBloc.fileTraitementList.writeAsStringSync("");

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
                                            borderRadius:
                                                new BorderRadius.circular(30.0),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (!formBloc.state.isFirstStep &&
                                      !formBloc.state.isLastStep)
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
                        onStepTapped: (FormBloc? formBloc, int step) {
                          print("onStepTapped");
                          if (step > (Tools.selectedDemande?.etape ?? 1 ) -1) {
                              return ;
                          }
                          Tools.currentStep = step;
                          print(formBloc);
                          formBloc?.updateCurrentStep(step);
                          // formBloc?.emit(FormBlocLoaded(currentStep: Tools.currentStep));
                        },
                      ),
                      BlocBuilder<InternetCubit, InternetState>(
                        builder: (context, state) {
                          if (state is InternetConnected &&
                              state.connectionType == ConnectionType.wifi) {
                            // return Text(
                            //   'Wifi',
                            //   style: TextStyle(color: Colors.green, fontSize: 30),
                            // );
                          } else if (state is InternetConnected &&
                              state.connectionType == ConnectionType.mobile) {
                            // return Text(
                            //   'Mobile',
                            //   style: TextStyle(color: Colors.yellow, fontSize: 30),
                            // );
                          } else if (state is InternetDisconnected) {
                            return Positioned(
                              bottom: 0,
                              child: Center(
                                child: Container(
                                  color: Colors.grey.shade400,
                                  width: MediaQuery.of(context).size.width,
                                  padding: const EdgeInsets.all(0.0),
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        "Pas d'accès internet",
                                        style: TextStyle(color: Colors.red, fontSize: 20),

                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );


                          }
                          // return CircularProgressIndicator();
                          return Container(

                          );
                        },
                      ),
                    ],
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
            // isEnabled: Tools.selectedDemande?.etape == 1,
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
            dateTimeFieldBloc: wizardFormBloc.dateRdvInputFieldBLoc,
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
            dateTimeFieldBloc: formBloc.dateRdvInputFieldBLoc,
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
          DropdownFieldBlocBuilder<Etatimmeubles>(
            selectFieldBloc: formBloc.etatImmeubleDropDown,
            decoration: const InputDecoration(
              labelText: 'Etat immeuble',
              prefixIcon: Icon(Icons.list),
            ),
            itemBuilder: (context, value) => FieldItem(
              child: Text(value.name ?? ""),
            ),
          ),

          // Divider(
          //   color: Colors.black,
          // ),
          // TextFieldBlocBuilder(
          //   textFieldBloc: formBloc.etatImmo,
          //   keyboardType: TextInputType.text,
          //   decoration: InputDecoration(
          //     labelText: "Etat immeble ",
          //     prefixIcon: Icon(Icons.gps_fixed),
          //   ),
          // ),
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
                            textFieldBloc: formBloc.newLatitude,
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
                                  borderRadius: BorderRadius.circular(20)),
                            ),
                          ),
                          TextFieldBlocBuilder(
                            readOnly: true,
                            textFieldBloc: formBloc.newLongitude,
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
                                  borderRadius: BorderRadius.circular(20)),
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
                        Position? position = await Tools.determinePosition();
                        if (position != null) {
                          formBloc.newLatitude.updateValue(
                              position.latitude.toStringAsFixed(4));
                          formBloc.newLongitude.updateValue(
                              position.longitude.toStringAsFixed(4));
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
            textFieldBloc: formBloc.newAdresse,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              labelText: "Nouvelle adresse ",
              prefixIcon: Icon(Icons.gps_fixed),
            ),
          ),

          // Divider(
          //   color: Colors.black,
          // ),

          DropdownFieldBlocBuilder<Types>(
            selectFieldBloc: formBloc.listTypeInstallationDropDown,
            decoration: const InputDecoration(
              labelText: 'Type installation',
              prefixIcon: Icon(Icons.list),
            ),
            itemBuilder: (context, value) => FieldItem(
              child: Text(value.name ?? ""),
            ),
          ),

          DropdownFieldBlocBuilder<Motifs>(
            selectFieldBloc: formBloc.motiflistTypeInstallationDropDown,
            decoration: const InputDecoration(
              labelText: 'Motif type installation',
              prefixIcon: Icon(Icons.list),
              helperMaxLines: 10
            ),
            itemBuilder: (context, value) => FieldItem(
              child: Text(value.name ?? ""),
            ),


          ),

//           SearchableDropDownFieldBlocBuilder<Motifs>(
//             selectFieldBloc: formBloc.motiflistTypeInstallationDropDown,
//             itemBuilder: (context, value) => value.name,
// //                            onChanged: (String value) => value.value,
//             hint: 'Motif type installation',
//             searchHint: 'Motif type installation',
// //                            items: [],
//           ),


          TextFieldBlocBuilder(
            textFieldBloc: formBloc.traitementConsommationCableTextField,
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
                        textFieldBloc: formBloc.latitudeTextField,
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
                              borderRadius: BorderRadius.circular(20)),
                        ),
                      ),
                      TextFieldBlocBuilder(
                        readOnly: true,
                        textFieldBloc: formBloc.longintudeTextField,
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
                              borderRadius: BorderRadius.circular(20)),
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
                    Position? position = await Tools.determinePosition();
                    if (position != null) {
                      formBloc.latitudeTextField
                          .updateValue(position.latitude.toStringAsFixed(4));
                      formBloc.longintudeTextField
                          .updateValue(position.longitude.toStringAsFixed(4));
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
            qrCodeTextFieldBloc: formBloc.dnsnTextField,
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

          TextFieldBlocBuilder(
            textFieldBloc: formBloc.ptoTextField,
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ], // Only numbers can be entered
            decoration: InputDecoration(
              labelText: "Pto ",
              prefixIcon: Icon(Icons.height),
            ),
          ),

          TextFieldBlocBuilder(
            textFieldBloc: formBloc.jarretieresTextField,
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
            decoration: InputDecoration(
              labelText: "Jarretieres ",
              prefixIcon: Icon(Icons.height),
            ),
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
                        child: Text(Tools.selectedDemande?.commentaires?[index]
                                .commentaire ??
                            ""),
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
            if (notificationCount > 0)
              Positioned(
                top: 10,
                right: 30,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration:
                      BoxDecoration(shape: BoxShape.circle, color: Colors.red),
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
