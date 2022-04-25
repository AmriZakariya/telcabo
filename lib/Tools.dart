import 'package:dio_http_formatter/dio_http_formatter.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:geolocator/geolocator.dart';
import 'package:im_stepper/stepper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:telcabo/Tools.dart';
import 'package:telcabo/custome/ConnectivityCheckBlocBuilder.dart';
import 'package:telcabo/custome/ImageFieldBlocbuilder.dart';
import 'package:telcabo/models/response_get_demandes.dart';
import 'package:telcabo/models/response_get_liste_etats.dart';
import 'dart:convert';

import 'dart:developer' as developer;

import 'package:flutter/services.dart';
import 'package:telcabo/models/response_get_liste_types.dart';
import 'package:telcabo/ui/InterventionHeaderInfoWidget.dart';

import 'package:dio_logger/dio_logger.dart';

class Tools{

  static Demandes? selectedDemande;
  static int currentStep = 1 ;

  static ResponseGetDemandesList? demandesListSaved;


  static Map? searchFilter;

  static String deviceToken = "" ;
  static String userId = "" ;
  static String userName = "" ;
  static String userEmail = "" ;

  static List arr_d = [2,7,8];
  static List arr_w = [1,3,4,5];
  static List arr_s = [6,9];


  static String languageCode = "ar" ;
  static final Color colorPrimary = Color(0xff3f4d67);
  static final Color colorSecondary = Color(0xfff99e25);

  static String getLanguageName(){

    switch(languageCode){
      case "ar":
        return "العربية" ;
      case "fr":
        return "Français" ;
    }

    return languageCode;
  }



  static File fileEtatsList = File("");
  static File fileListType = File("");
  static File fileDemandesList = File("");
  static File fileTraitementList = File("");




  static void initFiles(){

    print("initFiles!");
    try {
      getApplicationDocumentsDirectory().then((Directory directory) {
        fileEtatsList = new File(directory.path + "/fileEtatsList.json");
        fileListType = new File(directory.path + "/fileListType.json");
        fileDemandesList = new File(directory.path + "/fileDemandesList.json");
        fileTraitementList = new File(directory.path + "/fileTraitementList.json");

        if(!fileEtatsList.existsSync()){
          fileEtatsList.createSync();
        }

        if(!fileListType.existsSync()){
          fileListType.createSync();
        }

        if(!fileDemandesList.existsSync()){
          fileDemandesList.createSync();
        }

        if(!fileTraitementList.existsSync()){
          fileTraitementList.createSync();
        }

      });
    } catch (e) {
      print("exeption -- " + e.toString());
    }
  }

  static  Future<ResponseGetListEtat> callWSGetEtats() async {
    print("****** callWSGetEtats ***");

    Response response ;
    try {
      Dio dio = new Dio();
      dio.interceptors.add(dioLoggerInterceptor);

      response =
      await dio.get("http://telcabo.castlit.com/etats/liste_etats");

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

    return Tools.readfileEtatsList();
    // return ResponseGetListEtat(etat: []);

  }
  static  Future<ResponseGetListType> callWSGetlisteTypes() async {
    print("****** callWSGetlisteTypes ***");

    Response response ;
    try {
      Dio dio = new Dio();
      dio.interceptors.add(dioLoggerInterceptor);

      response =
      await dio.get("http://telcabo.castlit.com/etats/liste_types");

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.data}');

      if (response.statusCode == 200) {
        var responseApiHome = jsonDecode(response.data);
        writeToFileTypeInstallationList(responseApiHome);

        ResponseGetListType etats = ResponseGetListType.fromJson(responseApiHome);
        print(etats);

        return etats;
      } else {
        throw Exception('error fetching posts');
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

    return Tools.readfileListType();
    // return ResponseGetListEtat(etat: []);

  }

  static  Future<ResponseGetDemandesList> getDemandes() async {

    FormData formData = FormData.fromMap({
      "user_id" : userId
    });

    print(formData.fields.toString());

    Response apiRespon ;
    try {
      print("************** getDemandes ***********");
      Dio dio = new Dio();
      dio.interceptors.add(dioLoggerInterceptor);


      apiRespon =
      await dio.post("http://telcabo.castlit.com/demandes/get_demandes",
          data: formData,
          options: Options(
            // followRedirects: false,
            // validateStatus: (status) { return status < 500; },
            method: "POST",
            headers: {
              'Content-Type': 'multipart/form-data;charset=UTF-8',
              'Charset': 'utf-8',
              'Accept': 'application/json',
            },
          ));


      print('Response status: ${apiRespon.statusCode}');
      print('Response body: ${apiRespon.data}');

      if (apiRespon.statusCode == 200) {
        var responseApiHome = jsonDecode(apiRespon.data);
        writeToFileDemandeList(responseApiHome);

        ResponseGetDemandesList demandesList = ResponseGetDemandesList.fromJson(responseApiHome);
        print(demandesList);

        return demandesList;
      } else {
        throw Exception('error fetching posts');
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

    // return ResponseGetDemandesList(demandes: []) ;

    return readfileDemandesList();
  }


  static  Future<bool> callWSSendMail() async {

    FormData formData = FormData.fromMap({
      "demande_id" : Tools.selectedDemande?.id
    });

    Response apiRespon ;
    try {
      print("************** callWSSendMail ***********");
      Dio dio = new Dio();


      apiRespon =
      await dio.post("http://telcabo.castlit.com/traitements/send_mail",
          data: formData,
          options: Options(
            // followRedirects: false,
            // validateStatus: (status) { return status < 500; },
            method: "POST",
            headers: {
              'Content-Type': 'multipart/form-data;charset=UTF-8',
              'Charset': 'utf-8',
              'Accept': 'application/json',
            },
          ));


      print('Response status: ${apiRespon.statusCode}');
      print('Response body: ${apiRespon.data}');

      if (apiRespon.statusCode == 200) {
        if(apiRespon.data == "000"){
          return true ;
        }
      } else {
        throw Exception('error fetching posts');
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

    // return ResponseGetDemandesList(demandes: []) ;

    return false;
  }


  static void writeToFileEtatsList(Map jsonMapContent) {
    print("Writing to writeToFileEtatsList!");
    try {
      fileEtatsList.writeAsStringSync(json.encode(jsonMapContent));
      print("OK");
    } catch (e) {
      print("exeption -- "+e.toString());
    }
  }
  static void writeToFileTypeInstallationList(Map jsonMapContent) {
    print("Writing to writeToFileTypeInstallationList!");
    try {
      fileListType.writeAsStringSync(json.encode(jsonMapContent));
      print("OK");
    } catch (e) {
      print("exeption -- "+e.toString());
    }
  }

  static void writeToFileDemandeList(Map jsonMapContent) {
    print("Writing to writeToFileDemandeList!");
    try {
      fileDemandesList.writeAsStringSync(json.encode(jsonMapContent));
      print("OK");
    } catch (e) {
      print("exeption -- "+e.toString());
    }
  }


  static Future<void> readFileTraitementList() async{
    print("readFileTraitementList!");

    // fileTraitementList.writeAsStringSync("");

    try {

      String fileContent =  fileTraitementList.readAsStringSync();
      print("file content ==> ${fileContent}");

      if(!fileContent.isEmpty){
        Map<String, dynamic> demandeListMap = json.decode(fileContent);

        print(demandeListMap);

        List traitementList = demandeListMap.values.elementAt(0);
        print("traitementList ==> ${traitementList}");

        List traitementListResult  = [];


        for(int i = 0; i < traitementList.length; i++){
          print("element ==> ${traitementList[i]}");

          var isUpdated = await callWsAddMobileFromLocale(jsonDecode(traitementList[i])) ;
          if ( isUpdated == true){


          }else{
            traitementListResult.add(traitementList[i]);
          }

        }


        Map rsultMap = {
          "traitementList" : traitementListResult
        };
        fileTraitementList.writeAsStringSync(json.encode(rsultMap));




      }else{
        print("empty file");
      }



    } catch (e) {
      print("exeption -- " + e.toString());
    }
  }


  static Future<bool> callWsAddMobileFromLocale(Map<String, dynamic> formDateValues) async {
    print("****** callWsAddMobile ***");

    formDateValues.addAll({
      "isOffline" : true
    });

    FormData formData = FormData.fromMap(formDateValues);
    print(formData);


    Response apiRespon ;
    try {
      print("**************doPOST***********");
      Dio dio = new Dio();
      dio.interceptors.add(dioLoggerInterceptor);


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

      if(apiRespon.data == "000"){
        return true ;
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


  static ResponseGetListEtat readfileEtatsList() {
    ResponseGetListEtat responseListEtat;

    print("Read to readfileEtatsList!");
    try {

      String fileContent =  fileDemandesList.readAsStringSync();
      print("file content ==> ${fileContent}");

      if(!fileContent.isEmpty){
        Map<String, dynamic> etatsListMap =
        json.decode(fileEtatsList.readAsStringSync());
        print(etatsListMap);

        responseListEtat = ResponseGetListEtat.fromJson(etatsListMap);


        print("OK");

        return responseListEtat ;

      }else{
        print("empty file");
      }


    } catch (e) {
      print("exeption -- " + e.toString());
    }

    print("return empty list");
    return ResponseGetListEtat(etat: []);
  }

  static ResponseGetListType readfileListType() {
    ResponseGetListType responseGetListType;

    print("Read to readfileListType!");

    String fileContent =  fileDemandesList.readAsStringSync();
    print("file content ==> ${fileContent}");

    if(!fileContent.isEmpty){
      Map<String, dynamic> etatsListMap =
      json.decode(fileListType.readAsStringSync());
      print(etatsListMap);

      responseGetListType = ResponseGetListType.fromJson(etatsListMap);

      print("OK");

      return responseGetListType ;


    }else{
      print("empty file");
    }



    return ResponseGetListType(types: []);
  }

  static ResponseGetDemandesList readfileDemandesList() {
    ResponseGetDemandesList responseGetDemandesList;

    print("Read to readfileDemandesList!");
    try {

      String fileContent =  fileDemandesList.readAsStringSync();
      print("file content ==> ${fileContent}");

      if(!fileContent.isEmpty){
        Map<String, dynamic> demandeListMap = json.decode(fileContent);
        print(demandeListMap);

        responseGetDemandesList = ResponseGetDemandesList.fromJson(demandeListMap);

        print("OK");

        return responseGetDemandesList ;
      }



    } catch (e) {
      print("exeption -- " + e.toString());
    }

    return ResponseGetDemandesList(demandes: []);
  }

  static Future<ResponseGetListEtat> getListEtatFromLocalAndINternet() async{
    print("****** getListEtatFromLocalAndINternet ***");
    ResponseGetListEtat responseListEtat;

    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {
      responseListEtat = await Tools.callWSGetEtats();

    }else{
      responseListEtat =  Tools.readfileEtatsList() ;
    }

    print("****** getListEtatFromLocalAndINternet *** return  ${responseListEtat.toJson()} " );

    return responseListEtat;

  }
  static Future<ResponseGetListType> getTypeListFromLocalAndINternet() async{
    print("****** getTYpeListFromLocalAndINternet ***");
    ResponseGetListType responseGetListType;

    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {
      responseGetListType = await Tools.callWSGetlisteTypes();

    }else{
      responseGetListType =  Tools.readfileListType() ;
    }

    return responseGetListType;

  }
  static Future<ResponseGetDemandesList> getListDemandeFromLocalAndINternet() async{
    ResponseGetDemandesList responseGetDemandesList;

    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {
      print("read from ws");
      responseGetDemandesList = await Tools.getDemandes();

    }else{
      responseGetDemandesList =  Tools.readfileDemandesList() ;
    }

    return responseGetDemandesList;

  }



  static Future<bool> callWsLogin(Map<String, dynamic> formDateValues) async {

    print("Tools.deviceToken = "+ Tools.deviceToken);

    formDateValues.addAll({
      "registration_id"  : Tools.deviceToken
    });

    print(formDateValues);

    FormData formData = FormData.fromMap(formDateValues);

    Response apiRespon ;
    try {
      print("************** callWsLogin ***********");
      Dio dio = new Dio();


      apiRespon =
      await dio.post("http://telcabo.castlit.com/users/login_android",
          data: formData,
          options: Options(
            // followRedirects: false,
            // validateStatus: (status) { return status < 500; },
            method: "POST",
            headers: {
              'Content-Type': 'multipart/form-data;charset=UTF-8',
              'Charset': 'utf-8',
              'Accept': 'application/json',
            },
          ));


      print(apiRespon);

      Map result = json.decode(apiRespon.data) as Map ;

      String userId = result["id"];
      String userName = result["name"];

      if(userId.isNotEmpty && userId != "0"){
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isOnline', true);
        await prefs.setString('userId', userId);
        await prefs.setString('userName', userName);
        await prefs.setString('userEmail', formDateValues["username"]);


        Tools.userId =  userId ;
        Tools.userName =  userName ;
        Tools.userEmail = formDateValues["username"] ;

        return true ;

      }
      // print(json.decode(apiRespon).toString());




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



  static Future<Position> determinePosition() async {
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







  static  Future<bool> refreshSelectedDemande() async {
    print("****** callWSRefreshSelectedDEmande ***");

    FormData formData = FormData.fromMap({
      "demande_id" : Tools.selectedDemande?.id ?? ""
    });

    print(formData);

    Response apiRespon ;
    try {
      print("************** getDemandes ***********");
      Dio dio = new Dio();
      dio.interceptors.add(dioLoggerInterceptor);


      apiRespon =
      await dio.post("http://telcabo.castlit.com/demandes/get_demandes_byid",
          data: formData,
          options: Options(
            // followRedirects: false,
            // validateStatus: (status) { return status < 500; },
            method: "POST",
            headers: {
              'Content-Type': 'multipart/form-data;charset=UTF-8',
              'Charset': 'utf-8',
              'Accept': 'application/json',
            },
          ));


      print('Response status: ${apiRespon.statusCode}');
      print('Response body: ${apiRespon.data}');

      if (apiRespon.statusCode == 200) {
        var responseApiHome = jsonDecode(apiRespon.data);

        ResponseGetDemandesList demandesList = ResponseGetDemandesList.fromJson(responseApiHome);
        print(demandesList);

        Tools.selectedDemande = demandesList.demandes?.first ;

        return true ;

      } else {
        throw Exception('error fetching posts');
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

  static  Future<File?> compressAndGetFile(File file, String targetPath) async {
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path, targetPath,
      quality: 60,
      minWidth: 800,
      minHeight: 600
    );

    return result;
  }

}
