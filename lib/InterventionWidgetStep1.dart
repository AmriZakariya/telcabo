import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:im_stepper/stepper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:path_provider/path_provider.dart';
import 'package:telcabo/Tools.dart';
import 'package:telcabo/custome/ConnectivityCheckBlocBuilder.dart';
import 'package:telcabo/custome/ImageFieldBlocbuilder.dart';
import 'package:telcabo/models/response_get_liste_etats.dart';
import 'dart:convert';

import 'dart:developer' as developer;

import 'package:flutter/services.dart';

import 'NotificationExample.dart';
// import 'package:http/http.dart' as http;

class InterventionStep1FormBloc extends FormBloc<String, String> {
  late final ResponseGetListEtat responseListEtat;



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

  final InputFieldBloc<XFile?, Object> pPbiAvantTextField = InputFieldBloc(
    initialValue: null,
    name: "p_pbi_avant",
    validators: [
      FieldBlocValidators.required,
    ],
    toJson: (value) {
      MultipartFile file =  MultipartFile.fromFileSync(value?.path ?? "",filename: value?.name ?? "");
      return file ;

      },

  );

  final InputFieldBloc<XFile?, Object> pPbiApresTextField = InputFieldBloc(
    initialValue: null,
    name: "p_pbi_apres",
    validators: [
      FieldBlocValidators.required,
    ],
    toJson: (value) {
      MultipartFile file =  MultipartFile.fromFileSync(value?.path ?? "",filename: value?.name ?? "");
      return file ;

    },


  );

  final InputFieldBloc<XFile?, Object> pPboAvantTextField = InputFieldBloc(
    initialValue: null,
    name: "p_pbo_avant",
    toJson: (value) {
      MultipartFile file =  MultipartFile.fromFileSync(value?.path ?? "",filename: value?.name ?? "");
      return file ;

    },


  );

  final InputFieldBloc<XFile?, Object> pPboApresTextField = InputFieldBloc(
    initialValue: null,
    name: "p_pbo_apres",
    toJson: (value) {
      MultipartFile file =  MultipartFile.fromFileSync(value?.path ?? "",filename: value?.name ?? "");
      return file ;

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
        return formatted ;
      },

  );

  InterventionStep1FormBloc() : super(isLoading: true) {
    addFieldBlocs(fieldBlocs: [
      etatDropDown,
      commentaireTextField,
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
            rdvDate,
            sousEtatDropDown,
          ]);
        } else {
          removeFieldBlocs(fieldBlocs: [
            rdvDate,
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

    print("InterventionStep1FormBloc onSubmitting() ");
    print('onSubmittinga ${state.toJson()}');


    try {


      Map<String, dynamic> formDateValues = await state.toJson();
      print(formDateValues);

      formDateValues.addAll({
        "etape" : "1",
        "demande_id" : "demande_id",
        "user_id" : Tools.userId
      });


      writeToFileTraitementList(formDateValues);
      return;

     // AUtomatic fill data
     //  Map<String, dynamic> formDateValues = {};
     //  List fileItems = [] ;
     //
     //  state.fieldBlocs()?.forEach((k,v) {
     //    // print('key : ${k}: ${v}');
     //
     //
     //    if(v is TextFieldBloc){
     //      print('TextFieldBloc key : ${k}: ${v.value}');
     //
     //      formDateValues.putIfAbsent(k, () => v.value);
     //
     //    }else if(v is SelectFieldBloc<Etat, dynamic>){
     //      print('SelectFieldBloc<Etat, dynamic> key : ${k}: ${v.value}');
     //
     //      formDateValues.putIfAbsent(k, () => v.value?.id );
     //
     //
     //    }else if(v is SelectFieldBloc<SousEtat, dynamic>){
     //      print('SelectFieldBloc<SousEtat, dynamic> key : ${k}: ${v.value}');
     //
     //      formDateValues.putIfAbsent(k, () => v.value?.id);
     //
     //
     //    }else if(v is InputFieldBloc<DateTime?, Object>){
     //      print('InputFieldBloc<DateTime?, Object> key : ${k}: ${v.value}');
     //
     //      formDateValues.putIfAbsent(k, () => v.value);
     //
     //    }else if(v is InputFieldBloc<File?, Object>){
     //      print('InputFieldBloc<File?, Object> key : ${k}: ${v.value}');
     //
     //
     //    }else{
     //      print('Else key : ${k}: ${v}');
     //    }
     //
     //
     //  });


      // for(var mapKey in formDateValues.keys){
      //   // print('${k}: ${v}');
      //   // print(k);
      //   if(mapKey == "p_pbi_avant"
      //     || mapKey == "p_pbi_apres"
      //     || mapKey == "p_pbo_avant"
      //     || mapKey == "p_pbo_apres"
      //   ){
      //
      //     formDateValues[mapKey] = await MultipartFile.fromFile(pPbiAvantTextField.value?.path ?? "",filename: pPbiAvantTextField.value?.name ?? "");
      //     // print(v);
      //   }
      // }


      // FormData formData = FormData.fromMap(formDateValues);



      // Dio dio = Dio();
      // dio
      //   ..interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      //     // Do something before request is sent
      //
      //     return handler.next(options); //continue
      //   }, onResponse: (response, handler) {
      //     return handler.next(response); // continue
      //   }, onError: (DioError e, handler) {
      //     return handler.next(e); //continue
      //   }));

      print("dio start");


      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {
        print('YAY! Free cute dog pics!');

        bool checkCallWs = await callWsAddMobile(formDateValues);

        if(checkCallWs){
          emitSuccess(canSubmitAgain: true);

        }else{
          emitFailure(failureResponse: "WS");

        }

      } else if (connectivityResult == ConnectivityResult.none) {
        print('No internet :( Reason:');
        writeToFileTraitementList(formDateValues);
        emitSuccess(canSubmitAgain: true);

      }






      // readJson();
    } catch (e) {
      emitFailure();
    }
  }

  Future<bool> callWsAddMobile(Map<String, dynamic> formDateValues) async {

    FormData formData = FormData.fromMap(formDateValues);

    Response apiRespon ;
    try {
      print("**************doPOST***********");
      Dio dio = new Dio();

      // dio.interceptors.add(CustomPrettyDioLogger(
      //   requestHeader: true,
      //   requestBody: true,
      //   responseBody: true,
      //   responseHeader: true,
      //   compact: true,
      //   error: true,
      //   request: true,
      // ));

      apiRespon =
      await dio.post("https://telcabo.castlit.com/traitements/add_mobile",
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

      if (apiRespon.statusCode == 201) {
        apiRespon.statusCode == 201;

        return true ;
      } else {
        print('errr');
      }



    } on DioError catch (e) {
      print("**************DioError***********");
      print(e);
      // The request was made and the server responded with a status code
      // that falls out of the range of 2xx and is also not 304.
      if (e.response != null) {
    //        print(e.response.data);
    //        print(e.response.headers);
    //        print(e.response.);
    //           print("**->REQUEST ${e.response?.re.uri}#${Transformer.urlEncodeMap(e.response?.request.data)} ");
        throw (e.response?.statusMessage ?? "");
      } else {
        // Something happened in setting up or sending the request that triggered an Error
    //        print(e.request);
    //        print(e.message);
      }
    } catch (e) {
      throw ('API ERROR');
    }

    return false ;

  }


  // Future<Map<String, dynamic>> fixFileInput(Map<String, dynamic> formDateValues) async {
  //   formDateValues.forEach((k,v) async {
  //     print('${k}: ${v}');
  //     print(k);
  //     if(k == "p_pbi_avant" ){
  //       // File testFile = File(pPbiAvantTextField.value?.path ?? "");
  //
  //       v = await MultipartFile.fromFile(pPbiAvantTextField.value?.path ?? "",filename: pPbiAvantTextField.value?.name ?? "");
  //       print(v);
  //     }
  //   });
  //
  //   return formDateValues ;
  //
  // }


  @override
  void onLoading() async {

    getApplicationDocumentsDirectory().then((Directory directory) {
      dir = directory;
      fileEtatsList = new File(dir.path + "/fileEtatsList.json");
      fileTraitementList = new File(dir.path + "/fileTraitementList.json");

      if(!fileEtatsList.existsSync()){
        fileEtatsList.createSync();
      }
      if(!fileTraitementList.existsSync()){
        fileTraitementList.createSync();
      }


    });

    try {

      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {
        print('YAY! Free cute dog pics!');
        responseListEtat = await getEtats();

      } else if (connectivityResult == ConnectivityResult.none) {
        print('No internet :( Reason:');
        readfileEtatsList();
      }




      responseListEtat.etat = responseListEtat.etat?.take(3).toList();

      etatDropDown.updateItems(responseListEtat.etat ?? []);

      emitLoaded();
    } catch (e) {
      print(e);
      emitLoadFailed(failureResponse: e.toString());
    }
  }

  Future<ResponseGetListEtat> getEtats() async {
    // var url = Uri.parse('http://telcabo.castlit.com/etats/liste_etats');
    var response =
        await Dio().get('http://telcabo.castlit.com/etats/liste_etats');

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.data}');

    if (response.statusCode == 200) {
      var responseApiHome = jsonDecode(response.data);
      writeToFileEtatsList(responseApiHome);

      ResponseGetListEtat etats = ResponseGetListEtat.fromJson(responseApiHome);
      print(etats);

      return etats;
    } else {
      throw Exception('error fetching posts');
    }
  }

  // String fileLEtatsList = "fileLEtatsList.json";
  // String fileTraitementList = "fileTraitementList.json";

  Directory dir = Directory("");

  File fileEtatsList = File("");
  File fileTraitementList = File("");




  void writeToFileEtatsList(Map jsonMapContent) {
    print("Writing to writeToFileEtatsList!");
    try {
      fileEtatsList.writeAsStringSync(json.encode(jsonMapContent));
      print("OK");
    } catch (e) {
      print("exeption -- "+e.toString());
    }
  }
  void readfileEtatsList() {
    print("Read to readfileEtatsList!");
    try {

      Map<String, dynamic> etatsListMap =
      json.decode(fileEtatsList.readAsStringSync());
      print(etatsListMap);

      responseListEtat = ResponseGetListEtat.fromJson(etatsListMap);
      print("OK");

    } catch (e) {
      print("exeption -- "+e.toString());
    }
  }

  void writeToFileTraitementList(Map jsonMapContent) {
    print("Writing to writeToFileTraitementList!");


      try {

        Map traitementListMap =
                      json.decode(fileTraitementList.readAsStringSync());
        print(traitementListMap);


        List traitementList = traitementListMap.values.elementAt(0);

        traitementList.add(json.encode(jsonMapContent));

        traitementListMap[0] = traitementList ;

        fileTraitementList.writeAsStringSync(json.encode(traitementListMap));


      } catch (e) {
        print("exeption -- "+e.toString());
      }

  }
  void fethchFileTraitementList(Map jsonMapContent) {
    print("Writing to writeToFileTraitementList!");

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
}

class InterventionFormStep1 extends StatelessWidget {
  const InterventionFormStep1({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<InterventionStep1FormBloc>(
          create: (BuildContext context) => InterventionStep1FormBloc(),
        ),
        BlocProvider<InternetCubit>(
          create: (BuildContext context) => InternetCubit(connectivity: Connectivity()),
        ),
      ],
      // create: (context) => InterventionStep1FormBloc(),
      child: Builder(
        builder: (context) {
          final formBloc = BlocProvider.of<InterventionStep1FormBloc>(context);

          return Scaffold(
            appBar: AppBar(title: const Text('Intervention')),
            floatingActionButton: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // FloatingActionButton.extended(
                //   heroTag: null,
                //   onPressed: formBloc.addErrors,
                //   icon: const Icon(Icons.error_outline),
                //   label: const Text('ADD ERRORS'),
                // ),
                // const SizedBox(height: 12),
                // FloatingActionButton.extended(
                //   heroTag: null,
                //   onPressed: formBloc.submit,
                //   icon: const Icon(Icons.send),
                //   label: const Text('SUBMIT'),
                // ),
              ],
            ),
            body:
            MultiBlocListener(
              listeners: [
                FormBlocListener<InterventionStep1FormBloc, String, String>(
                  onSubmitting: (context, state) {
                    print(" FormBlocListener onSubmitting") ;
                    // LoadingDialog.show(context);
                  },
                  onSuccess: (context, state) {
                    print(" FormBlocListener onSuccess") ;

                    // LoadingDialog.hide(context);

                    // Navigator.of(context).pushReplacement(
                    //     MaterialPageRoute(builder: (_) => const SuccessScreen()));
                  },
                  onFailure: (context, state) {
                    print(" FormBlocListener onFailure") ;
                    // LoadingDialog.hide(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.failureResponse ?? "")));
                  },
                ),
                BlocListener<InternetCubit, InternetState>(
                  listener: (context, state) {
                    if(state is InternetConnected){
                      showSimpleNotification(
                        Text("status : en ligne"),
                        // subtitle: Text("onlime"),
                        background: Colors.green,
                        duration: Duration(seconds: 5),
                      );
                    }
                    if(state is InternetDisconnected ){
                      showSimpleNotification(
                        Text("Offline"),
                        // subtitle: Text("onlime"),
                        background: Colors.red,
                        duration: Duration(seconds: 5),
                      );
                    }
                  },
                ),

              ],
              child: ScrollableFormBlocManager(
                formBloc: formBloc,
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: <Widget>[
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
                            return Container(
                              color: Colors.grey.shade400,
                              width: double.infinity,
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    "Pas d'accès internet",
                                    style: TextStyle(color: Colors.red, fontSize: 20),

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
                      NumberStepper(
                        numbers:[
                          1,
                          2,
                          3,
                        ],
                        activeStep: 0,
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
                        ),
                        itemBuilder: (context, value) => FieldItem(
                          child: Text(value.name ?? ""),
                        ),
                      ),
                      DropdownFieldBlocBuilder<MotifList>(
                        selectFieldBloc: formBloc.motifDropDown,
                        decoration: const InputDecoration(
                          labelText: 'Morif',
                        ),
                        itemBuilder: (context, value) => FieldItem(
                          child: Text(value.name ?? ""),
                        ),
                      ),

                      // Container(
                      //   child: Expanded(
                      //     child: GridView.count(
                      //       crossAxisCount: 2,
                      //       // crossAxisSpacing: 4.0,
                      //       // mainAxisSpacing: 8.0,
                      //       children: [
                      //
                      //         ]
                      //       ),
                      //   ),
                      // ),
                      Container(
                          margin: const EdgeInsets.only(top: 20),
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
                          margin: const EdgeInsets.only(top: 20),
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

                      SizedBox(
                        height: 20,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          print("cliick");
                          // formBloc.readJson();
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
}

