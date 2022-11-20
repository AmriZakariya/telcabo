import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:dio/dio.dart';
import 'package:dio_logger/dio_logger.dart';
import 'package:floating_action_bubble/floating_action_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:path_provider/path_provider.dart';
import 'package:telcabo/Tools.dart';
import 'package:telcabo/ToolsExtra.dart';
import 'package:telcabo/custome/ConnectivityCheckBlocBuilder.dart';
import 'package:telcabo/custome/ImageFieldBlocbuilder.dart';
import 'package:telcabo/custome/QrScannerTextFieldBlocBuilder.dart';
import 'package:telcabo/models/response_get_demandes.dart';
import 'package:telcabo/models/response_get_liste_etats.dart';
import 'dart:convert';

import 'dart:developer' as developer;

import 'package:flutter/services.dart';
import 'package:telcabo/models/response_get_liste_types.dart';
import 'package:telcabo/ui/InterventionHeaderInfoWidget.dart';
import 'package:telcabo/ui/LoadingDialog.dart';
import 'package:timelines/timelines.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:image/image.dart' as imagePLugin;

import 'NotificationExample.dart';
// import 'package:http/http.dart' as http;

import 'package:collection/collection.dart';

import 'package:flutter_share_me/flutter_share_me.dart';

final GlobalKey<ScaffoldState> formStepperScaffoldKey =
    new GlobalKey<ScaffoldState>();

ValueNotifier<int> currentStepValueNotifier = ValueNotifier(Tools.currentStep);

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

  final InputFieldBloc<XFile?, Object> photoBlocage1InputFieldBloc =
      InputFieldBloc(
    initialValue: null,
    name: "photo_blocage1",
    validators: [
      FieldBlocValidators.required,
    ],
    toJson: (value) {
      MultipartFile file = MultipartFile.fromFileSync(value?.path ?? "",
          filename: value?.name ?? "");
      return file;
    },
  );

  final InputFieldBloc<XFile?, Object> photoBlocage2InputFieldBloc =
      InputFieldBloc(
    initialValue: null,
    name: "photo_blocage2",
    validators: [
      FieldBlocValidators.required,
    ],
    toJson: (value) {
      MultipartFile file = MultipartFile.fromFileSync(value?.path ?? "",
          filename: value?.name ?? "");
      return file;
    },
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

  final debitTextField = TextFieldBloc(
    name: 'debit',
    validators: [FieldBlocValidators.required, _debitMinMaxValue],
  );

  static String? _debitMinMaxValue(String? debit) {
    double doubleValue;

    try {
      doubleValue = double.parse(debit ?? "");
    } catch (e) {
      return null;
    }

    if (doubleValue <= -26) {
      return "entre -26 et -15";
    } else if (doubleValue > -15) {
      return "entre -26 et -15";
    }

    return null;
  }

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
  final routeurTextField = TextFieldBloc(
    name: 'routeur',
    validators: [
      // FieldBlocValidators.required,
    ],
  );

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
  final InputFieldBloc<XFile?, Object> pDosRouteur = InputFieldBloc(
    initialValue: null,
    name: "p_dos_routeur",
    validators: [
      FieldBlocValidators.required,
    ],
    toJson: (value) {
      MultipartFile file = MultipartFile.fromFileSync(value?.path ?? "",
          filename: value?.name ?? "");
      return file;
    },
  );

  /* Step 3 */

  final speedTextField = TextFieldBloc(
    name: 'speed',
    validators: [
      FieldBlocValidators.required,
    ],
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

    // Tools.selectedDemande?.etatId = "9" ;
    // Tools.selectedDemande?.etatName = "demooo" ;

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
        debitTextField,
        latitudeTextField,
        longintudeTextField,
        adresseMacTextField,
        dnsnTextField,
        snTelTextField,
        snGpomTextField,
        ptoTextField,
        jarretieresTextField,
        routeurTextField,
        pEquipementInstalle,
        pTestSignal,
        pEtiquetageIndoor,
        pEtiquetageOutdoor,
        pPassageCable,
        pFicheInstalation,
        pDosRouteur,
      ],
    );
    addFieldBlocs(
      step: 2,
      fieldBlocs: [commentaireTextField],
    );

    if (Tools.currentStep == 2) {
      if (Tools.selectedDemande?.etatId == "9" ||
          Tools.selectedDemande?.etatId == "6") {
        addFieldBlocs(fieldBlocs: [
          speedTextField,
          pSpeedTest,
        ]);
      } else {
        removeFieldBlocs(fieldBlocs: [
          speedTextField,
          pSpeedTest,
        ]);
      }
    }

    addFieldBlocs(
      step: 3,
      fieldBlocs: [commentaireTextField],
    );

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

        removeFieldBlocs(fieldBlocs: [motifDropDown]);

        removeFieldBlocs(fieldBlocs: [
          // etatImmo,
          etatImmeubleDropDown,
          newLatitude,
          newLongitude,
          newAdresse,

          photoBlocage2InputFieldBloc,
          photoBlocage2InputFieldBloc,
        ]);

        if (current.value?.id == "5") {
          // disable soutetat when en attent dactivation

          if (Tools.selectedDemande?.subStatutId?.isNotEmpty == true) {
            bool shouldShowSousEtat = false;

            current.value?.sousEtat?.forEach((element) {
              if (element.id == Tools.selectedDemande?.subStatutId) {
                shouldShowSousEtat = true;
                return;
              }
            });
            if (shouldShowSousEtat) {
              var selectedSousEtat =
                  etatDropDown.value?.sousEtat?.firstWhereOrNull((element) {
                return element.id == Tools.selectedDemande?.subStatutId;
              });
              print("selectedSousEtat ==> ${selectedSousEtat}");

              sousEtatDropDown.updateItems([]);
              addFieldBloc(fieldBloc: sousEtatDropDown);

              if (selectedSousEtat != null) {
                if (sousEtatDropDown.state.items.contains(selectedSousEtat)) {
                  sousEtatDropDown.updateValue(selectedSousEtat);
                } else {
                  sousEtatDropDown.addItem(selectedSousEtat);
                  sousEtatDropDown.updateValue(selectedSousEtat);
                }
              }
            }
          }
          return;
        }

        if (current.value?.id == "1") {
          /* check current RDV date */
          String? selectedRdvDate = Tools.selectedDemande?.dateRdv;
          if (selectedRdvDate?.isNotEmpty == true) {
            print("selected rdvDate ==> ${selectedRdvDate}");

            var parsedDate = DateTime.parse(selectedRdvDate!);

            dateRdvInputFieldBLoc.updateValue(parsedDate);
          } else {
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

          photoBlocage2InputFieldBloc,
          photoBlocage2InputFieldBloc,
        ]);



        if (current.value?.motifList?.isEmpty == true) {
          removeFieldBlocs(fieldBlocs: [motifDropDown]);
        } else {
          motifDropDown.updateItems(current.value?.motifList ?? []);
          addFieldBloc(fieldBloc: motifDropDown);



        }

        if (etatDropDown.value?.id == "7") if (sousEtatDropDown.value?.id ==
            "14" //"Blocage syndicat",
            ||
            sousEtatDropDown.value?.id == "18" //"Blocage voisin",
            ||
            sousEtatDropDown.value?.id ==
                "17" //"Problème raccordement client",

        ) {
          addFieldBlocs(fieldBlocs: [
            // etatImmo,
            photoBlocage1InputFieldBloc,
            photoBlocage2InputFieldBloc,
          ]);
        } else {
          removeFieldBlocs(fieldBlocs: [
            photoBlocage1InputFieldBloc,
            photoBlocage2InputFieldBloc,
          ]);
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



        if (sousEtatDropDown.value?.id == "8") {
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
          motiflistTypeInstallationDropDown
              .updateItems(current.value?.motifs ?? []);
          addFieldBloc(fieldBloc: motiflistTypeInstallationDropDown);
        }
      },
    );
  }

  bool writeToFileTraitementList(Map jsonMapContent) {
    print("Writing to writeToFileTraitementList!");

    // fileTraitementList.writeAsStringSync("");
    // return true;
    try {
      for (var mapKey in jsonMapContent.keys) {
        // print('${k}: ${v}');
        // print(k);

        if (mapKey == "p_pbi_avant") {
          jsonMapContent[mapKey] =
              "${pPbiAvantTextField.value?.path};;${pPbiAvantTextField.value?.name}";
        } else if (mapKey == "p_pbi_apres") {
          // jsonMapContent[mapKey] = pPbiApresTextField.value?.path;
          jsonMapContent[mapKey] =
              "${pPbiApresTextField.value?.path};;${pPbiApresTextField.value?.name}";
        } else if (mapKey == "p_pbo_avant") {
          // jsonMapContent[mapKey] = pPboAvantTextField.value?.path;
          jsonMapContent[mapKey] =
              "${pPboAvantTextField.value?.path};;${pPboAvantTextField.value?.name}";
        } else if (mapKey == "p_pbo_apres") {
          // jsonMapContent[mapKey] = pPboApresTextField.value?.path;
          jsonMapContent[mapKey] =
              "${pPboApresTextField.value?.path};;${pPboApresTextField.value?.name}";
        } else if (mapKey == "p_equipement_installe") {
          // jsonMapContent[mapKey] = pEquipementInstalle.value?.path;
          jsonMapContent[mapKey] =
              "${pEquipementInstalle.value?.path};;${pEquipementInstalle.value?.name}";
        } else if (mapKey == "p_test_signal") {
          // jsonMapContent[mapKey] = pTestSignal.value?.path;
          jsonMapContent[mapKey] =
              "${pTestSignal.value?.path};;${pTestSignal.value?.name}";
        } else if (mapKey == "p_etiquetage_indoor") {
          // jsonMapContent[mapKey] = pEtiquetageIndoor.value?.path;
          jsonMapContent[mapKey] =
              "${pEtiquetageIndoor.value?.path};;${pEtiquetageIndoor.value?.name}";
        } else if (mapKey == "p_etiquetage_outdoor") {
          // jsonMapContent[mapKey] = pEtiquetageOutdoor.value?.path;
          jsonMapContent[mapKey] =
              "${pEtiquetageOutdoor.value?.path};;${pEtiquetageOutdoor.value?.name}";
        } else if (mapKey == "p_passage_cable") {
          // jsonMapContent[mapKey] = pPassageCable.value?.path;
          jsonMapContent[mapKey] =
              "${pPassageCable.value?.path};;${pPassageCable.value?.name}";
        } else if (mapKey == "p_fiche_instalation") {
          // jsonMapContent[mapKey] = pFicheInstalation.value?.path;
          jsonMapContent[mapKey] =
              "${pFicheInstalation.value?.path};;${pFicheInstalation.value?.name}";
        } else if (mapKey == "p_dos_routeur") {
          // jsonMapContent[mapKey] = pFicheInstalation.value?.path;
          jsonMapContent[mapKey] =
              "${pDosRouteur.value?.path};;${pDosRouteur.value?.name}";
        } else if (mapKey == "p_speed_test") {
          // jsonMapContent[mapKey] = pSpeedTest.value?.path;
          jsonMapContent[mapKey] =
              "${pSpeedTest.value?.path};;${pSpeedTest.value?.name}";
        }else if (mapKey == "photo_blocage1") {
          // jsonMapContent[mapKey] = pSpeedTest.value?.path;
          jsonMapContent[mapKey] =
          "${photoBlocage1InputFieldBloc.value?.path};;${photoBlocage1InputFieldBloc.value?.name}";
        }else if (mapKey == "photo_blocage2") {
          // jsonMapContent[mapKey] = pSpeedTest.value?.path;
          jsonMapContent[mapKey] =
          "${photoBlocage2InputFieldBloc.value?.path};;${photoBlocage2InputFieldBloc.value?.name}";
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

      return true;
    } catch (e) {
      print("exeption -- " + e.toString());
    }

    return false;
  }

  @override
  void onLoading() async {
    emitFailure(failureResponse: "loadingTest");
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
      print("OnLOading ** responseListEtat ==> ${responseListEtat.toJson()}");
      responseGetListType = await Tools.getTypeListFromLocalAndINternet();

      print(responseListEtat.etat.toString());

      if (Tools.currentStep == 0) {
        // responseListEtat.etat = responseListEtat.etat?.take(3).toList();
        List<Etat> etatTmp = responseListEtat.etat?.where((element) {
              return element.id == "1" ||
                  element.id == "2" ||
                  element.id == "3" ||
                  element.id == "7" ||
                  element.id == "8";
            }).toList() ??
            [];
        etatDropDown.updateItems(etatTmp);
      } else if (Tools.currentStep == 1) {
        // responseListEtat.etat = responseListEtat.etat?.skip(3).toList();
        // etatDropDown.updateItems(responseListEtat.etat?.skip(3).toList() ?? []);

        List<Etat> etatTmp = responseListEtat.etat?.skip(3).toList() ?? [];
        etatTmp
            .removeWhere((element) => (element.id == "5" || element.id == "9"));
        etatTmp
            .removeWhere((element) => (element.id == "7" || element.id == "8"));

        etatDropDown.updateItems(etatTmp);
      } else if (Tools.currentStep == 2) {
        // responseListEtat.etat = responseListEtat.etat?.skip(3).toList();

        List<Etat> etatTmp = responseListEtat.etat?.where((element) {
              return element.id == "4" ||
                  element.id == "5" ||
                  (Tools.selectedDemande?.etatId == "9" && element.id == "6");
            }).toList() ??
            [];
        etatDropDown.updateItems(etatTmp);
      }
      listTypeInstallationDropDown.updateItems(responseGetListType.types ?? []);

      // print(responseListEtat.etat.toString());
      // etatDropDown.updateItems(responseListEtat.etat ?? []);

      updateInputsFromDemande();

      emitLoaded();
      emitFailure(failureResponse: "loadingTestFinish");

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

    currentStepValueNotifier.value = Tools.currentStep;

    super.updateCurrentStep(step);
  }

  @override
  void previousStep() {
    print("override previousStep");
    print("Tools.currentStep ==> ${Tools.currentStep}");

    currentStepValueNotifier.value = Tools.currentStep;

    clearInputs();

    super.previousStep();
  }

  Future<String> callWsAddMobile(Map<String, dynamic> formDateValues) async {
    print("****** callWsAddMobile ***");

    String currentAddress = formDateValues["currentAddress"];
    String currentDate = formDateValues["date"];
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();

    if (Tools.localWatermark == true) {
      print("Local watermark start ");
      for (var mapKey in formDateValues.keys) {
        print("mapKey ==> $mapKey");
        if (mapKey == "p_pbi_avant" ||
            mapKey == "p_pbi_apres" ||
            mapKey == "p_pbo_avant" ||
            mapKey == "p_pbo_apres" ||
            mapKey == "p_equipement_installe" ||
            mapKey == "p_test_signal" ||
            mapKey == "p_etiquetage_indoor" ||
            mapKey == "p_etiquetage_outdoor" ||
            mapKey == "p_passage_cable" ||
            mapKey == "p_fiche_instalation" ||
            mapKey == "p_dos_routeur" ||
            mapKey == "p_speed_test" ||
            mapKey == "photo_blocage1" ||
            mapKey == "photo_blocage2") {
          try {
            if (formDateValues[mapKey] != null) {
              var xfileSrc;

              if (mapKey == "p_pbi_avant") {
                xfileSrc = pPbiAvantTextField.value;
              } else if (mapKey == "p_pbi_apres") {
                xfileSrc = pPbiApresTextField.value;
              } else if (mapKey == "p_pbo_avant") {
                xfileSrc = pPboAvantTextField.value;
              } else if (mapKey == "p_pbo_apres") {
                xfileSrc = pPboApresTextField.value;
              } else if (mapKey == "p_equipement_installe") {
                xfileSrc = pEquipementInstalle.value;
              } else if (mapKey == "p_test_signal") {
                xfileSrc = pTestSignal.value;
              } else if (mapKey == "p_etiquetage_indoor") {
                xfileSrc = pEtiquetageIndoor.value;
              } else if (mapKey == "p_etiquetage_outdoor") {
                xfileSrc = pEtiquetageOutdoor.value;
              } else if (mapKey == "p_passage_cable") {
                xfileSrc = pPassageCable.value;
              } else if (mapKey == "p_fiche_instalation") {
                xfileSrc = pFicheInstalation.value;
              } else if (mapKey == "p_dos_routeur") {
                xfileSrc = pDosRouteur.value;
              } else if (mapKey == "p_speed_test") {
                xfileSrc = pSpeedTest.value;
              }else if (mapKey == "photo_blocage1") {
                xfileSrc = photoBlocage1InputFieldBloc.value;
              }else if (mapKey == "photo_blocage2") {
                xfileSrc = photoBlocage2InputFieldBloc.value;
              }

              final File fileResult = File(xfileSrc?.path ?? "");

              final image =
                  imagePLugin.decodeImage(fileResult.readAsBytesSync())!;

              // imagePLugin.Image image = imagePLugin.copyResize(thumbnail, width: 960) ;

              imagePLugin.drawString(
                  image, imagePLugin.arial_24, 0, 0, currentDate);
              imagePLugin.drawString(
                  image, imagePLugin.arial_24, 0, 32, currentAddress);

              File fileResultWithWatermark =
                  File(dir.path + "/" + fileName + '.png');
              fileResultWithWatermark
                  .writeAsBytesSync(imagePLugin.encodePng(image));

              XFile xfileResult = XFile(fileResultWithWatermark.path);

              formDateValues[mapKey] = MultipartFile.fromFileSync(
                  xfileResult.path,
                  filename: xfileResult.name);

              print("watermark success");
            }
          } catch (e) {
            print("+++ exception ++++ mapKey ==> $mapKey");
            print(e);
            formDateValues[mapKey] = null;
          }
        }
      }
    }

    FormData formData = FormData.fromMap(formDateValues);
    print(formData);

    Response apiRespon;
    try {
      print("**************doPOST***********");
      Dio dio = new Dio();
      dio.interceptors.add(dioLoggerInterceptor);

      apiRespon = await dio.post("${Tools.baseUrl}/traitements/add_mobile",
          data: formData,
          options: Options(
            method: "POST",
            headers: {
              'Content-Type': 'multipart/form-data;charset=UTF-8',
              'Charset': 'utf-8'
            },
          ));

      print("Image Upload ${apiRespon}");

      print(apiRespon);

      if (apiRespon.data == "000") {
        return "000";
      }

      // if (apiRespon.statusCode == 201) {
      //   apiRespon.statusCode == 201;
      //
      //   return true ;
      // } else {
      //   print('errr');
      // }

    } on DioError catch (e) {
      print("**************DioError***********");
      print(e);
      // The request was made and the server responded with a status code
      // that falls out of the range of 2xx and is also not 304.
      if (e.response != null) {
        print(e.response);
        // print(e.response.headers);
        // print(e.response.);
        //           print("**->REQUEST ${e.response?.re.uri}#${Transformer.urlEncodeMap(e.response?.request.data)} ");
        // throw (e.response?.statusMessage ?? "");

      } else {
        // Something happened in setting up or sending the request that triggered an Error
        //        print(e.request);
        print(e.message);
      }
    } catch (e) {
      // throw ('API ERROR');
      print("API ERROR ${e}");
      return "Erreur de connexion au serveur";
    }

    return "Erreur de connexion au serveur";
  }

  @override
  void onSubmitting() async {
    print("FormStepper onSubmitting() ");
    print("Tools.currentStep ==> ${Tools.currentStep}");
    print('onSubmittinga ${state.toJson()}');

    try {
      final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:s');
      final String dateNowFormatted = formatter.format(DateTime.now());
      String currentAddress = "";

      if ((Tools.currentStep == 0 &&
              (etatDropDown.value?.id == "3" &&
                  (pPbiAvantTextField.value != null ||
                      pPbiApresTextField.value != null ||
                      pPboAvantTextField.value != null ||
                      pPboApresTextField.value != null))) ||
          Tools.currentStep == 1 ||
          true ||
          Tools.currentStep == 2) {
        bool isLocationServiceOK = await ToolsExtra.checkLocationService();
        if (isLocationServiceOK == false) {
          emitFailure(
              failureResponse: "Les services de localisation sont désactivés.");
          return;
        }

        try {
          currentAddress = await Tools.getAddressFromLatLng();
        } catch (e) {
          emitFailure(failureResponse: e.toString());
          return;
        }
      }

      Map<String, dynamic> formDateValues = await state.toJson();

      formDateValues.addAll({
        "etape": Tools.currentStep + 1,
        "demande_id": Tools.selectedDemande?.id ?? "",
        "user_id": Tools.userId,
        "date": dateNowFormatted,
        "currentAddress": currentAddress
      });

      print(formDateValues);

      print("dio start");

      if (await Tools.tryConnection()) {
        print('YAY! Free cute dog pics!');

        String checkCallWs = await callWsAddMobile(formDateValues);

        if (checkCallWs == "000") {
          // if (await Tools.refreshSelectedDemande()) {
          await Tools.refreshSelectedDemande();
          print("refreshed refreshSelectedDemande");
          print("Tools.selectedDemande ==> ${Tools.selectedDemande?.etape}");
          print("state.currentStep ==> ${state.currentStep}");



          Tools.currentStep = (Tools.selectedDemande?.etape ?? 1) -1 ;
          currentStepValueNotifier.value = Tools.currentStep;

          if (((Tools.selectedDemande?.etape ?? 1) - 1) <= state.currentStep) {
            commentaireTextField.updateValue("");
            emitFailure(failureResponse: "sameStep");
          } else {
            commentaireTextField.updateValue("");
            emitSuccess(canSubmitAgain: true);
          }
          // }else {
          //   emitFailure(failureResponse: "WS");
          // }
        } else {
          // writeToFileTraitementList(formDateValues);

          emitFailure(failureResponse: checkCallWs);
        }
      } else {
        print('No internet :( Reason:');
        writeToFileTraitementList(formDateValues);
        commentaireTextField.updateValue("");
        emitFailure(failureResponse: "sameStep");
        // emitSuccess();
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
      // etatDropDown.updateItems(responseListEtat.etat?.take(3).toList() ?? []);

      List<Etat> etatTmp = responseListEtat.etat?.where((element) {
            return element.id == "1" ||
                element.id == "2" ||
                element.id == "3" ||
                element.id == "7" ||
                element.id == "8";
          }).toList() ??
          [];
      etatDropDown.updateItems(etatTmp);
    } else if (Tools.currentStep == 1) {
      // responseListEtat.etat = responseListEtat.etat?.skip(3).toList();

      List<Etat> etatTmp = responseListEtat.etat?.skip(3).toList() ?? [];
      etatTmp
          .removeWhere((element) => (element.id == "5" || element.id == "9"));
      etatTmp
          .removeWhere((element) => (element.id == "7" || element.id == "8"));

      etatDropDown.updateItems(etatTmp);
    } else if (Tools.currentStep == 2) {
      // responseListEtat.etat = responseListEtat.etat?.skip(3).toList();

      List<Etat> etatTmp = responseListEtat.etat?.where((element) {
            return element.id == "4" ||
                element.id == "5" ||
                (Tools.selectedDemande?.etatId == "9" && element.id == "6");
          }).toList() ??
          [];
      etatDropDown.updateItems(etatTmp);
    }

    removeFieldBlocs(fieldBlocs: [
      sousEtatDropDown,
      motifDropDown,
      dateRdvInputFieldBLoc,
      pPbiAvantTextField,
      pPbiApresTextField,
      pPboAvantTextField,
      pPboApresTextField,
      etatImmeubleDropDown,
      motiflistTypeInstallationDropDown,
      newLatitude,
      newLongitude,
      newAdresse,

      photoBlocage1InputFieldBloc,
      photoBlocage2InputFieldBloc,
    ]);

    if (Tools.currentStep == 2) {
      if (Tools.selectedDemande?.etatId == "9" ||
          Tools.selectedDemande?.etatId == "6") {
        addFieldBlocs(fieldBlocs: [
          speedTextField,
          pSpeedTest,
        ]);
      } else {
        removeFieldBlocs(fieldBlocs: [
          speedTextField,
          pSpeedTest,
        ]);
      }
    }
    updateInputsFromDemande();
  }

  void updateInputsFromDemande() {
    updateValidatorFromDemande();

    print("responseListEtat ==> ${responseListEtat}");
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

    var selectedSousEtat =
        etatDropDown.value?.sousEtat?.firstWhereOrNull((element) {
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

    var selectedMotif =
        sousEtatDropDown.value?.motifList?.firstWhereOrNull((element) {
      return element.id == Tools.selectedDemande?.motifSubstatutId;
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

    traitementConsommationCableTextField
        .updateValue(Tools.selectedDemande?.consommationCable ?? "");
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
    routeurTextField.updateValue(Tools.selectedDemande?.routeur ?? "");

    if (Tools.currentStep == 1) {
      listTypeInstallationDropDown.updateValue(
          listTypeInstallationDropDown.state.items.firstWhereOrNull((element) {
        return element.id == Tools.selectedDemande?.typeInstallationId;
      }));
    }

    motiflistTypeInstallationDropDown.updateValue(
        motiflistTypeInstallationDropDown.state.items
            .firstWhereOrNull((element) {
      return element.id == Tools.selectedDemande?.motifTypeinstallationId;
    }));

    String? selectedRdvDate = Tools.selectedDemande?.dateRdv;
    if (selectedRdvDate?.isNotEmpty == true) {
      print("selected rdvDate ==> ${selectedRdvDate}");

      var parsedDate = DateTime.parse(selectedRdvDate!);

      dateRdvInputFieldBLoc.updateValue(parsedDate);
    }
  }

  void updateValidatorFromDemande() {
    // if (Tools.selectedDemande?.etatId == "5") {
    //   pSpeedTest.removeValidators([
    //     FieldBlocValidators.required,
    //   ]);
    // } else {
    //   pSpeedTest.addValidators([
    //     FieldBlocValidators.required,
    //   ]);
    // }

    if (Tools.selectedDemande?.pPbiAvant?.isNotEmpty == true) {
      print("removeValidators pPbiAvantTextField");
      pPbiAvantTextField.removeValidators([
        FieldBlocValidators.required,
      ]);
    } else {
      print("addValidators pPbiAvantTextField");

      pPbiAvantTextField.addValidators([
        FieldBlocValidators.required,
      ]);
    }

    if (Tools.selectedDemande?.pPbiApres?.isNotEmpty == true) {
      pPbiApresTextField.removeValidators([
        FieldBlocValidators.required,
      ]);
    } else {
      pPbiApresTextField.addValidators([
        FieldBlocValidators.required,
      ]);
    }

    /*
    if (Tools.selectedDemande?.pPboAvant?.isNotEmpty == true) {
      pPboAvantTextField.removeValidators([
        FieldBlocValidators.required,
      ]);
    } else {
      pPboAvantTextField.addValidators([
        FieldBlocValidators.required,
      ]);
    }


    if (Tools.selectedDemande?.pPboApres?.isNotEmpty == true) {
      pPboApresTextField.removeValidators([
        FieldBlocValidators.required,
      ]);
    } else {
      pPboApresTextField.addValidators([
        FieldBlocValidators.required,
      ]);
    }
  */

    if (Tools.selectedDemande?.pEquipementInstalle?.isNotEmpty == true) {
      pEquipementInstalle.removeValidators([
        FieldBlocValidators.required,
      ]);
    } else {
      pEquipementInstalle.addValidators([
        FieldBlocValidators.required,
      ]);
    }

    if (Tools.selectedDemande?.pTestSignal?.isNotEmpty == true) {
      pTestSignal.removeValidators([
        FieldBlocValidators.required,
      ]);
    } else {
      pTestSignal.addValidators([
        FieldBlocValidators.required,
      ]);
    }

    if (Tools.selectedDemande?.pEtiquetageIndoor?.isNotEmpty == true) {
      pEtiquetageIndoor.removeValidators([
        FieldBlocValidators.required,
      ]);
    } else {
      pEtiquetageIndoor.addValidators([
        FieldBlocValidators.required,
      ]);
    }
    if (Tools.selectedDemande?.pEtiquetageOutdoor?.isNotEmpty == true) {
      pEtiquetageOutdoor.removeValidators([
        FieldBlocValidators.required,
      ]);
    } else {
      pEtiquetageOutdoor.addValidators([
        FieldBlocValidators.required,
      ]);
    }

    if (Tools.selectedDemande?.pPassageCable?.isNotEmpty == true) {
      pPassageCable.removeValidators([
        FieldBlocValidators.required,
      ]);
    } else {
      pPassageCable.addValidators([
        FieldBlocValidators.required,
      ]);
    }

    if (Tools.selectedDemande?.pFicheInstalation?.isNotEmpty == true) {
      pFicheInstalation.removeValidators([
        FieldBlocValidators.required,
      ]);
    } else {
      pFicheInstalation.addValidators([
        FieldBlocValidators.required,
      ]);
    }

    if (Tools.selectedDemande?.pDosRouteur?.isNotEmpty == true) {
      pDosRouteur.removeValidators([
        FieldBlocValidators.required,
      ]);
    } else {
      pDosRouteur.addValidators([
        FieldBlocValidators.required,
      ]);
    }

    if (Tools.selectedDemande?.pSpeedTest?.isNotEmpty == true) {
      pSpeedTest.removeValidators([
        FieldBlocValidators.required,
      ]);
    } else {
      pSpeedTest.addValidators([
        FieldBlocValidators.required,
      ]);
    }
  }
}

class WizardForm extends StatefulWidget {
  @override
  _WizardFormState createState() => _WizardFormState();
}

class _WizardFormState extends State<WizardForm>
    with SingleTickerProviderStateMixin {
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

  ValueNotifier<int> commentaireCuuntValueNotifer =
      ValueNotifier(Tools.selectedDemande?.commentaires?.length ?? 0);

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
    return MultiBlocProvider(
      providers: [
        BlocProvider<WizardFormBloc>(
          create: (BuildContext context) => WizardFormBloc(),
        ),
        BlocProvider<InternetCubit>(
          create: (BuildContext context) =>
              InternetCubit(connectivity: Connectivity()),
        ),
      ],
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
            child: MultiBlocListener(
              listeners: [
                BlocListener<InternetCubit, InternetState>(
                  listener: (context, state) {
                    if (state is InternetConnected) {
                      // showSimpleNotification(
                      //   Text("status : en ligne"),
                      //   // subtitle: Text("onlime"),
                      //   background: Colors.green,
                      //   duration: Duration(seconds: 5),
                      // );
                    }
                    if (state is InternetDisconnected) {
                      // showSimpleNotification(
                      //   Text("Offline"),
                      //   // subtitle: Text("onlime"),
                      //   background: Colors.red,
                      //   duration: Duration(seconds: 5),
                      // );
                    }
                  },
                ),
              ],
              child: Scaffold(
                key: formStepperScaffoldKey,
                resizeToAvoidBottomInset: true,
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.miniStartFloat,

                //Init Floating Action Bubble
                floatingActionButton: ValueListenableBuilder(
                    valueListenable: currentStepValueNotifier,
                    builder: (BuildContext context, int currentStepNotifier,
                        Widget? child) {
                      print(
                          "ValueListenableBuilder ==> ${currentStepNotifier}");
                      return Visibility(
                          visible: currentStepNotifier != 1,
                          child: FloatingActionBubble(
                            // Menu items
                            items: <Bubble>[
                              // Floating action menu item
                              Bubble(
                                title: "WhatssApp",
                                iconColor: Colors.white,
                                bubbleColor: Colors.blue,
                                icon: Icons.whatsapp,
                                titleStyle: TextStyle(
                                    fontSize: 16, color: Colors.white),
                                onPress: () async {
                                  print("share wtsp");

                                  String msgShare =
                                      getMsgShare(currentStepNotifier);

                                  print("msgShare ==> ${msgShare}");

                                  // shareToWhatsApp({String msg,String imagePath})
                                  final FlutterShareMe flutterShareMe =
                                      FlutterShareMe();
                                  String? response = await flutterShareMe
                                      .shareToWhatsApp(msg: msgShare);

                                  /*
                          var whatsapp = "+212619993849";
                          var whatsappURl_android =
                              "whatsapp://send?phone=" + whatsapp + "&text=${Uri.parse(msgShare)}";
                          var whatappURL_ios =
                              "https://wa.me/$whatsapp?text=${Uri.parse(msgShare)}";
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

                           */
                                  _animationController.reverse();
                                },
                              ),
                              // Floating action menu item
                              Bubble(
                                title: "Mail",
                                iconColor: Colors.white,
                                bubbleColor: Colors.blue,
                                icon: Icons.mail_outline,
                                titleStyle: TextStyle(
                                    fontSize: 16, color: Colors.white),
                                onPress: () async {
                                  LoadingDialog.show(context);
                                  bool success = await Tools.callWSSendMail();
                                  LoadingDialog.hide(context);

                                  if (success) {
                                    CoolAlert.show(
                                        context: context,
                                        type: CoolAlertType.success,
                                        text: "Email Envoyé avec succès",
                                        autoCloseDuration: Duration(seconds: 5),
                                        title: "Succès");
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
                          ));
                    }),

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
                    // NamedIcon(
                    //     text: '',
                    //     iconData: _type == StepperType.horizontal
                    //         ? Icons.swap_vert
                    //         : Icons.swap_horiz,
                    //     onTap: _toggleType),
                    ValueListenableBuilder(
                      valueListenable: commentaireCuuntValueNotifer,
                      builder: (BuildContext context, int commentaireCount,
                          Widget? child) {
                        return NamedIcon(
                          text: '',
                          iconData: Icons.comment,
                          notificationCount: commentaireCount,
                          onTap: () {
                            formStepperScaffoldKey.currentState
                                ?.openEndDrawer();
                          },
                        );
                      },
                    )
                  ],
                ),
                endDrawer: EndDrawerWidget(),
                body: SafeArea(
                  child: FormBlocListener<WizardFormBloc, String, String>(
                    // onLoading: (context, state) {
                    //   print("FormBlocListener onLoading");
                    //   LoadingDialog.show(context);
                    // },
                    // onLoaded: (context, state) {
                    //   print("FormBlocListener onLoaded");
                    //   LoadingDialog.hide(context);
                    // },
                    // onLoadFailed: (context, state) {
                    //   print("FormBlocListener onLoadFailed");
                    //   LoadingDialog.hide(context);
                    // },
                    // onSubmissionCancelled: (context, state) {
                    //   print("FormBlocListener onSubmissionCancelled");
                    //   LoadingDialog.hide(context);
                    // },
                    onSubmitting: (context, state) {
                      print("FormBlocListener onSubmitting");
                      LoadingDialog.show(context);
                    },
                    onSuccess: (context, state) {
                      print("FormBlocListener onSuccess");
                      LoadingDialog.hide(context);

                      commentaireCuuntValueNotifer.value =
                          Tools.selectedDemande?.commentaires?.length ?? 0;
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

                      if (state.failureResponse == "loadingTest") {
                        LoadingDialog.show(context);
                        return;
                      }

                      if (state.failureResponse == "loadingTestFinish") {
                        LoadingDialog.hide(context);
                        return;
                      }

                      LoadingDialog.hide(context);

                      if (state.failureResponse == "sameStep") {
                        commentaireCuuntValueNotifer.value =
                            Tools.selectedDemande?.commentaires?.length ?? 0;

                        CoolAlert.show(
                          context: context,
                          type: CoolAlertType.success,
                          text: "Enregistré avec succès",
                          // autoCloseDuration: Duration(seconds: 2),
                          title: "Succès",
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(state.failureResponse!)));
                      }
                    },
                    onSubmissionFailed: (context, state) {
                      print("FormBlocListener onSubmissionFailed ${state}");
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
                                          onPressed: () async {
                                            print("cliick");
                                            // formBloc.readJson();
                                            // formBloc.fileTraitementList.writeAsStringSync("");

                                            // bool isLocationServiceOK = await ToolsExtra.checkLocationService();
                                            // if(isLocationServiceOK == false){
                                            //   return;
                                            // }

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
                                                  new BorderRadius.circular(
                                                      30.0),
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
                                      //       // context.read<formBloc>().clear();
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
                            if (step >
                                (Tools.selectedDemande?.etape ?? 1) - 1) {
                              return;
                            }
                            Tools.currentStep = step;
                            print(formBloc);
                            formBloc?.updateCurrentStep(step);

                            // formBloc?.emit(FormBlocLoaded(currentStep: Tools.currentStep));
                          },
                        ),
                        BlocBuilder<InternetCubit, InternetState>(
                          builder: (context, state) {
                            print("BlocBuilder **** InternetCubit ${state}");
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
                                          style: TextStyle(
                                              color: Colors.red, fontSize: 20),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }
                            // return CircularProgressIndicator();
                            return Container();
                          },
                        ),
                      ],
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

  FormBlocStep _step1(WizardFormBloc formBloc) {
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
          if (Tools.selectedDemande?.etatId == "9")
            Container(
              padding: const EdgeInsets.only(bottom: 30),
              child: Text(
                Tools.selectedDemande?.etatName ?? "",
                style: TextStyle(fontSize: 20),
              ),
            ),
          // if (Tools.selectedDemande?.etatId != "9")
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
            selectFieldBloc: formBloc.sousEtatDropDown,
            decoration: const InputDecoration(
              labelText: 'Sous Etat',
              prefixIcon: Padding(
                padding: const EdgeInsets.only(top: 10, left: 12),
                child: FaIcon(
                  FontAwesomeIcons.scribd,
                ),
              ),
            ),
            itemBuilder: (context, value) => FieldItem(
              child: Text(value.name ?? ""),
            ),
          ),
          DropdownFieldBlocBuilder<MotifList>(
            selectFieldBloc: formBloc.motifDropDown,
            decoration: const InputDecoration(
              labelText: 'Motif',
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
                        // await checkLocationService();
                        print("heeeeeee 1 ");

                        bool isLocationServiceOK =
                            await ToolsExtra.checkLocationService();

                        if (isLocationServiceOK == false) {
                          CoolAlert.show(
                              context: context,
                              type: CoolAlertType.error,
                              text:
                                  "Les services de localisation sont désactivés.",
                              autoCloseDuration: Duration(seconds: 5),
                              title: "Erreur");
                          return;
                        }

                        print("heeeeeee 2 ");

                        try {
                          Position? position = await Tools.determinePosition();
                          if (position != null) {
                            formBloc.newLatitude.updateValue(
                                position.latitude.toStringAsFixed(4));
                            formBloc.newLongitude.updateValue(
                                position.longitude.toStringAsFixed(4));
                          }
                        } catch (e) {
                          print(e);
                          // showSimpleNotification(
                          //   Text("Erreur"),
                          //   subtitle: Text(e.toString()),
                          //   background: Colors.green,
                          //   duration: Duration(seconds: 5),
                          // );

                          CoolAlert.show(
                              context: context,
                              type: CoolAlertType.error,
                              text: e.toString(),
                              autoCloseDuration: Duration(seconds: 5),
                              title: "Erreur");
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
                  formBloc: formBloc,
                  fileFieldBloc: formBloc.pPbiAvantTextField,
                  labelText: "PBI avant ",
                  iconField: Icon(Icons.image_not_supported),
                ),
              ),
              Flexible(
                // flex: 2,
                child: ImageFieldBlocBuilder(
                  formBloc: formBloc,
                  fileFieldBloc: formBloc.pPbiApresTextField,
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
                  formBloc: formBloc,
                  fileFieldBloc: formBloc.pPboAvantTextField,
                  labelText: "PBO avant ",
                  iconField: Icon(Icons.image_not_supported),
                ),
              ),
              Flexible(
                // flex: 2,
                child: ImageFieldBlocBuilder(
                  formBloc: formBloc,
                  fileFieldBloc: formBloc.pPboApresTextField,
                  labelText: "PBO apres ",
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
                      formBloc: formBloc,
                      fileFieldBloc: formBloc.photoBlocage1InputFieldBloc,
                      labelText: "Photo Blockage 1 ",
                      iconField: Icon(Icons.image_not_supported),
                    ),
                  ),
                  Flexible(
                    // flex: 2,
                    child: ImageFieldBlocBuilder(
                      formBloc: formBloc,
                      fileFieldBloc: formBloc.photoBlocage2InputFieldBloc,
                      labelText: "Photo Blockage 2 ",
                      iconField: Icon(Icons.image_not_supported),
                    ),
                  ),
                ],
              )),
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
          if (Tools.selectedDemande?.etatId == "9")
            Container(
              padding: const EdgeInsets.only(bottom: 30),
              child: Text(
                Tools.selectedDemande?.etatName ?? "",
                style: TextStyle(fontSize: 20),
              ),
            ),
          // if (Tools.selectedDemande?.etatId != "9")
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
              labelText: 'Motif',
              prefixIcon: Icon(Icons.list),
            ),
            itemBuilder: (context, value) => FieldItem(
              child: Text(value.name ?? ""),
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
            maxLines: 5,
            isExpanded: true,
            textOverflow: TextOverflow.visible,
            decoration: const InputDecoration(
                labelText: 'Motif type installation',
                prefixIcon: Icon(Icons.list),
                helperMaxLines: 10),
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
              // prefixIcon: Icon(Icons.drag_indicator),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(top: 10, left: 12),
                child: FaIcon(
                  FontAwesomeIcons.scribd,
                ),
              ),
            ),
          ),

          TextFieldBlocBuilder(
            textFieldBloc: formBloc.debitTextField,
            keyboardType:
                TextInputType.numberWithOptions(decimal: true, signed: true),
            inputFormatters: <TextInputFormatter>[
              // FilteringTextInputFormatter.doub,
              // CustomRangeTextInputFormatter(),
              // NumericalRangeFormatter(min: -26, max: -15),
            ],
            decoration: InputDecoration(
              labelText: "Test signal",
              // prefixIcon: Icon(Icons.speed),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(top: 10, left: 12),
                child: FaIcon(
                  FontAwesomeIcons.houseSignal,
                ),
              ),
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
                    try {
                      bool isLocationServiceOK =
                          await ToolsExtra.checkLocationService();
                      if (isLocationServiceOK == false) {
                        CoolAlert.show(
                            context: context,
                            type: CoolAlertType.error,
                            text:
                                "Les services de localisation sont désactivés.",
                            autoCloseDuration: Duration(seconds: 5),
                            title: "Erreur");

                        return;
                      }

                      Position? position = await Tools.determinePosition();

                      if (position != null) {
                        formBloc.latitudeTextField
                            .updateValue(position.latitude.toStringAsFixed(4));
                        formBloc.longintudeTextField
                            .updateValue(position.longitude.toStringAsFixed(4));

                        print("heeeeeee 3 ${position}");
                      }
                    } catch (e) {
                      print(e);
                      // showSimpleNotification(
                      //   Text("Erreur"),
                      //   subtitle: Text(e.toString()),
                      //   background: Colors.green,
                      //   duration: Duration(seconds: 5),
                      // );

                      CoolAlert.show(
                          context: context,
                          type: CoolAlertType.error,
                          text: e.toString(),
                          autoCloseDuration: Duration(seconds: 5),
                          title: "Erreur");
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
            // iconField: Icon(Icons.text_snippet),
            iconField: Padding(
              padding: const EdgeInsets.only(top: 10, left: 12),
              child: FaIcon(
                FontAwesomeIcons.terminal,
              ),
            ),
            labelText: "Adresse Mac ",
            qrCodeTextFieldBloc: formBloc.adresseMacTextField,
          ),

          QrScannerTextFieldBlocBuilder(
            formBloc: formBloc,
            iconField: Padding(
              padding: const EdgeInsets.only(top: 10, left: 12),
              child: FaIcon(
                FontAwesomeIcons.globe,
              ),
            ),
            labelText: "DNSN ",
            qrCodeTextFieldBloc: formBloc.dnsnTextField,
          ),

          QrScannerTextFieldBlocBuilder(
            formBloc: formBloc,
            // iconField: Icon(Icons.text_snippet),
            iconField: Padding(
              padding: const EdgeInsets.only(top: 10, left: 12),
              child: FaIcon(
                FontAwesomeIcons.phoneVolume,
              ),
            ),
            labelText: "SN Tel ",
            qrCodeTextFieldBloc: formBloc.snTelTextField,
          ),

          QrScannerTextFieldBlocBuilder(
            formBloc: formBloc,
            // iconField: Icon(Icons.text_snippet),
            iconField: Padding(
              padding: const EdgeInsets.only(top: 10, left: 12),
              child: FaIcon(
                FontAwesomeIcons.route,
              ),
            ),
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
              // prefixIcon: Icon(Icons.height),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(top: 10, left: 12),
                child: FaIcon(
                  FontAwesomeIcons.hardDrive,
                ),
              ),
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
              // prefixIcon: Icon(Icons.height),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(top: 10, left: 12),
                child: FaIcon(
                  FontAwesomeIcons.circleNodes,
                ),
              ),
            ),
          ),
          TextFieldBlocBuilder(
            textFieldBloc: formBloc.routeurTextField,
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
            decoration: InputDecoration(
              labelText: "Routeur ",
              // prefixIcon: Icon(Icons.height),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(top: 10, left: 12),
                child: FaIcon(
                  FontAwesomeIcons.circleNodes,
                ),
              ),
            ),
          ),
          Divider(
            color: Colors.black,
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
                  formBloc: formBloc,
                  fileFieldBloc: formBloc.pEquipementInstalle,
                  labelText: "Equipement installé ",
                  iconField: Icon(Icons.image_not_supported),
                ),
              ),
              Flexible(
                // flex: 2,
                child: ImageFieldBlocBuilder(
                  formBloc: formBloc,
                  fileFieldBloc: formBloc.pTestSignal,
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
                  formBloc: formBloc,
                  fileFieldBloc: formBloc.pEtiquetageIndoor,
                  labelText: "Etiquetage indoor ",
                  iconField: Icon(Icons.image_not_supported),
                ),
              ),
              Flexible(
                // flex: 2,
                child: ImageFieldBlocBuilder(
                  formBloc: formBloc,
                  fileFieldBloc: formBloc.pEtiquetageOutdoor,
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
                  formBloc: formBloc,
                  fileFieldBloc: formBloc.pPassageCable,
                  labelText: "Passage cable ",
                  iconField: Icon(Icons.image_not_supported),
                ),
              ),
              Flexible(
                // flex: 2,
                child: ImageFieldBlocBuilder(
                  formBloc: formBloc,
                  fileFieldBloc: formBloc.pFicheInstalation,
                  labelText: "Fiche instalation ",
                  iconField: Icon(Icons.image_not_supported),
                ),
              ),
            ],
          )),
          Center(
            child: ImageFieldBlocBuilder(
              formBloc: formBloc,
              fileFieldBloc: formBloc.pDosRouteur,
              labelText: "Dos routeur ",
              iconField: Icon(Icons.image_not_supported),
            ),
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

  FormBlocStep _step3(WizardFormBloc formBloc) {
    return FormBlocStep(
      title: Text('Etape 3'),
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
          if (Tools.selectedDemande?.etatId == "9")
            Container(
              padding: const EdgeInsets.only(bottom: 30),
              child: Text(
                Tools.selectedDemande?.etatName ?? "",
                style: TextStyle(fontSize: 20),
              ),
            ),
          // if (Tools.selectedDemande?.etatId != "9")
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
              labelText: 'Motif',
              prefixIcon: Icon(Icons.list),
            ),
            itemBuilder: (context, value) => FieldItem(
              child: Text(value.name ?? ""),
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
          Center(
            child: ImageFieldBlocBuilder(
              formBloc: formBloc,
              fileFieldBloc: formBloc.pSpeedTest,
              labelText: "Speed test ",
              iconField: Icon(Icons.image_not_supported),
            ),
          ),
        ],
      ),
    );
  }

  String getMsgShare(int currentStepNotifier) {
    String msgShare = "";

    print("msgShare currentStepNotifier ==> ${currentStepNotifier}");

    if (currentStepNotifier == 2) {
      msgShare +=
          "SIP                          : ${Tools.selectedDemande?.loginSip ?? ""}";

      msgShare +=
          "\nCLIENT                  : ${Tools.selectedDemande?.client ?? ""}";

      msgShare +=
          "\n MAC           : ${Tools.selectedDemande?.adresseMac ?? ""}";

      msgShare +=
          "\n SN-GPON       : ${Tools.selectedDemande?.snRouteur ?? ""}";

      // SN-DN
      msgShare += "\n SN-DN         : ${Tools.selectedDemande?.dnsn ?? ""}";

      // msgShare +=
      //     "\n ETAT DEMANDE= ${Tools.selectedDemande?.etatName ?? "" }";

      msgShare += "\nETAT DEMANDE  : Client installé";

      if (Tools.selectedDemande?.sousEtatName?.isNotEmpty == true) {

        ResponseGetListEtat responseGetListEtatShare = Tools.readfileEtatsList();

        bool canAddSousEtat = false ;

        responseGetListEtatShare.etat?.firstWhere((element) => element.id == Tools.selectedDemande?.etatId).sousEtat?.forEach((element) {
          if(element.id == Tools.selectedDemande?.subStatutId){
            canAddSousEtat = true ;
            // break;
          }
        });

        if(canAddSousEtat){
          msgShare +=
          "\nRaison                  : ${Tools.selectedDemande?.sousEtatName ?? ""}";
        }

      }

      msgShare +=
          "\nSN-TEL                  : ${Tools.selectedDemande?.snTel ?? ""}";

      msgShare +=
          "\nTEL                  : ${Tools.selectedDemande?.contactClient ?? ""}";

      msgShare +=
          "\nPLAQUE                : ${Tools.selectedDemande?.plaqueName ?? ""}";
    } else {
      msgShare +=
          "SIP                          : ${Tools.selectedDemande?.loginSip ?? ""}";

      msgShare +=
          "\nCLIENT                  : ${Tools.selectedDemande?.client ?? ""}";

      // msgShare += "\n" ;

      msgShare += "\nETAT DEMANDE  : ${Tools.selectedDemande?.etatName ?? ""}";

      if (Tools.selectedDemande?.sousEtatName?.isNotEmpty == true) {

        ResponseGetListEtat responseGetListEtatShare = Tools.readfileEtatsList();

        bool canAddSousEtat = false ;

        responseGetListEtatShare.etat?.firstWhere((element) => element.id == Tools.selectedDemande?.etatId).sousEtat?.forEach((element) {
          if(element.id == Tools.selectedDemande?.subStatutId){
            canAddSousEtat = true ;
            // break;
          }
        });

        if(canAddSousEtat){
          msgShare +=
          "\nRaison                  : ${Tools.selectedDemande?.sousEtatName ?? ""}";
        }

      }

      msgShare +=
          "\nTEL                  : ${Tools.selectedDemande?.contactClient ?? ""}";

      // msgShare +=
      // "\n TEL              : ${Tools.selectedDemande?.snTel ?? "" }";

      msgShare +=
          "\nPLAQUE                : ${Tools.selectedDemande?.plaqueName ?? ""}";
    }

    return msgShare;
  }

// isVisibleSHare() {
//   return ValueListenableBuilder(
//     valueListenable: commentaireCuuntValueNotifer,
//     builder: (BuildContext context, int commentaireCount,
//         Widget? child) {
//       return true ;
//     },
//   )
// }
}

class CustomRangeTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    print("new value ==> ${newValue.text}");
    if (newValue.text == '')
      return TextEditingValue();
    else if (double.parse(newValue.text) < -26)
      return TextEditingValue().copyWith(text: '-25.99');

    return double.parse(newValue.text) > -15
        ? TextEditingValue().copyWith(text: '-15')
        : newValue;
  }
}

class NumericalRangeFormatter extends TextInputFormatter {
  final double min;
  final double max;

  NumericalRangeFormatter({required this.min, required this.max});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    print("oldValue ==> ${oldValue.text}");
    print("newValue ==> ${newValue.text}");

    if (newValue.text == '-' && oldValue.text == '') {
      return newValue;
    }

    if (newValue.text == '') {
      return newValue;
    } else if (int.parse(newValue.text) < min) {
      return TextEditingValue().copyWith(text: min.toStringAsFixed(2));
    } else {
      return int.parse(newValue.text) > max ? oldValue : newValue;
    }
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Commentaires"),
              ),
              Expanded(
                child: Scrollbar(
                  // isAlwaysShown: true,
                  child: Timeline.tileBuilder(
                    // physics: BouncingScrollPhysics(),
                    builder: TimelineTileBuilder.fromStyle(
                      contentsBuilder: (context, index) => Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(Tools.selectedDemande
                                  ?.commentaires?[index].commentaire ??
                              ""),
                        ),
                      ),
                      oppositeContentsBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                            alignment: AlignmentDirectional.centerEnd,
                            child: Column(
                              children: [
                                // Text(Tools.selectedDemande?.commentaires?[index].userId ?? ""),
                                Text(Tools.selectedDemande?.commentaires?[index]
                                        .created
                                        ?.trim() ??
                                    ""),
                              ],
                            )),
                      ),
                      // itemExtent: 1,
                      // indicatorPositionBuilder: (BuildContext context, int index){
                      //   return 0 ;
                      // },
                      contentsAlign: ContentsAlign.alternating,
                      indicatorStyle: IndicatorStyle.dot,
                      connectorStyle: ConnectorStyle.dashedLine,
                      itemCount:
                          Tools.selectedDemande?.commentaires?.length ?? 0,
                    ),
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
        padding: const EdgeInsets.only(top: 10),
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
                right: notificationCount.toString().length >= 3 ? 15 : 25,
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

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.replay),
              label: const Text('AGAIN'),
            ),
          ],
        ),
      ),
    );
  }
}
