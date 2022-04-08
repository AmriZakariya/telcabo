import 'dart:async';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:dartx/dartx.dart';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_image_picker/form_builder_image_picker.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

import 'Tools.dart';

class InterventionWidget extends StatelessWidget {
  @override
  final String title;

  final List<String> optionsFr = const [
    "BMH",
    "Travaux municipaux ",
    "Nettoiement ",
    "Autres reclamations",
    "Suggestion-"
  ];

  final List<String> optionsAr = const [
    "المكتب الصحي",
    "أشغال البلدية",
    "النظافة",
    "شكايات اخرى",
    "إقتراحات"
  ];

  final List<String> subOptionsBMHFr = const [
    "hygiene alimentaire",
    "Salubrite publique",
    "Lutte antivectorielle",
    "Ramassage chats et chiens errants",
  ];

  final List<String> subOptionsOtherFr = const [
    "Reclamations autorisations",
    "Retard, accueil, service rendu",
    "Réclamations générales",
    "Réclamations police administrative",
    "Réclamations des commissions",
    "Urbaine, Economique, occupation domaine public…",
  ];

  final List<String> subOptionsBMHAr = const [
    "السلامة الغذائية",
    "السلامة العامة",
    "محاربة ناقلات الأمراض",
    "جمع القطط و الكلاب الضالة",
  ];
  final List<String> subOptionOtherAr = const [
    "شكايات الرخص",
    " تأخير ، إستقبال ، الخدمة المقدمة",
    "شكايات عامة",
    "شكايات الشرطة الإدارية",
    "شكايات اللجن",
    "الحضرية، الإقتصادية، احتلال الملك العمومي.",
  ];

  final List<String> optionsPlaque = ["MHAMMID SAADA", "test"];
  final List<String> options = [];
  final List<String> suboptions = [];
  final List<String> subOptionsBMH = [];
  final List<String> subOptionsOther = [];

  InterventionWidget({this.title = "default title"});

  final _formKey = GlobalKey<FormBuilderState>();

  final TextEditingController controller = TextEditingController();
  String initialCountry = 'MA';
  PhoneNumber number = PhoneNumber(isoCode: 'MA');

  void getPhoneNumber(String phoneNumber) async {
    PhoneNumber number =
    await PhoneNumber.getRegionInfoFromPhoneNumber(phoneNumber, 'US');

    // setState(() {
    //   this.number = number;
    // });
  }

  @override
  Widget build(BuildContext context) {
    if (context.locale.languageCode == "ar") {
      options.addAll(optionsAr);
      subOptionsBMH.addAll(subOptionsBMHAr);
      subOptionsOther.addAll(subOptionOtherAr);
    } else {
      options.addAll(optionsFr);
      subOptionsBMH.addAll(subOptionsBMHFr);
      subOptionsOther.addAll(subOptionsOtherFr);
    }
    // bool showSubCategorie = true;
    ValueNotifier<bool> showSubCategorie = ValueNotifier(false);
    return Theme(
        data: Theme.of(context).copyWith(
          primaryColor: Tools.colorPrimary,
          backgroundColor: Tools.colorPrimary,
          accentColor: Tools.colorPrimary
          /*inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),*/
        ),
        child: Scaffold(
          appBar: AppBar(
            title: Text(title),
          ),
          body: SingleChildScrollView(
              physics: ClampingScrollPhysics(),
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/bg_home.jpg"),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(children: <Widget>[
                    // SizedBox(height: 200,child: ProfileSevenPage()),
                    FormBuilder(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.disabled,
                      child: Column(
                        children: [
                          FormBuilderDropdown(
                            onChanged: (value) {
                              print(value);

                            },
                            name: 'plaque',
                            decoration: InputDecoration(
                              labelText: 'plaque'.tr().toUpperCase(),
                              prefixIcon: Icon(Icons.list),
                            ),
                            // initialValue: 'Male',
                            allowClear: true,
                            hint: Text('plaque'.tr().toUpperCase()),
                            validator: FormBuilderValidators.compose(
                                [FormBuilderValidators.required(context)]),
                            items: optionsPlaque
                                .map((option) => DropdownMenuItem(
                              value: option,
                              child: Text('$option'),
                            ))
                                .toList(),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          FormBuilderDropdown(
                            onChanged: (value) {
                              print(value);
                              if (value == options.first) {
                                suboptions.clear();
                                suboptions.addAll(subOptionsBMH);
                                showSubCategorie.value = true;
                              } else if (value == options[3]) {
                                suboptions.clear();
                                suboptions.addAll(subOptionsOther);
                                showSubCategorie.value = true;
                              } else {
                                showSubCategorie.value = false;
                              }
                            },
                            name: 'etat',
                            decoration: InputDecoration(
                              labelText: 'etat'.tr().toUpperCase(),
                              prefixIcon: Icon(Icons.list),
                            ),
                            // initialValue: 'Male',
                            allowClear: true,
                            hint: Text('etat'.tr().toUpperCase()),
                            validator: FormBuilderValidators.compose(
                                [FormBuilderValidators.required(context)]),
                            items: options
                                .map((option) => DropdownMenuItem(
                              value: option,
                              child: Text('$option'),
                            ))
                                .toList(),
                          ),
                          ValueListenableBuilder<bool>(
                            builder: (BuildContext context, bool value,
                                Widget? child) {
                              return Visibility(
                                visible: value,
                                child: SizedBox(
                                  height: 20,
                                ),
                              );
                            },
                            valueListenable: showSubCategorie,
                          ),
                          ValueListenableBuilder<bool>(
                            builder: (BuildContext context, bool value,
                                Widget? child) {
                              return Visibility(
                                visible: value,
                                child: FormBuilderDropdown(
                                  name: 'sub_categories',
                                  decoration: InputDecoration(
                                    labelText: 'categories'.tr().toUpperCase(),
                                    prefixIcon: Icon(Icons.list),
                                  ),
                                  // initialValue: 'Male',
                                  allowClear: true,
                                  hint: Text('categories'.tr().toUpperCase()),
                                  validator: FormBuilderValidators.compose([
                                    FormBuilderValidators.required(context)
                                  ]),
                                  items: suboptions
                                      .map((option) => DropdownMenuItem(
                                    value: option,
                                    child: Text('$option'),
                                  ))
                                      .toList(),
                                ),
                              );
                            },
                            valueListenable: showSubCategorie,
                          ),

                          SizedBox(
                            height: 20,
                          ),
                          FormBuilderTextField(
                            name: 'fullName',
                            decoration: InputDecoration(
                              labelText: 'full name'.tr().toUpperCase(),
                              prefixIcon: Icon(Icons.person),
                            ),
                            onChanged: (value) {},
                            // valueTransformer: (text) => num.tryParse(text),
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(context),
                              // FormBuilderValidators.numeric(context),
                              // FormBuilderValidators.max(context, 70),
                            ]),
                            keyboardType: TextInputType.text,
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          FormBuilderTextField(
                            name: 'cin',
                            decoration: InputDecoration(
                              labelText: 'cin'.tr().toUpperCase(),
                              prefixIcon: Icon(Icons.perm_identity),
                            ),
                            onChanged: (value) {},
                            // valueTransformer: (text) => num.tryParse(text),
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(context),
                              // FormBuilderValidators.numeric(context),
                              // FormBuilderValidators.max(context, 70),
                            ]),
                            keyboardType: TextInputType.text,
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          FormBuilderTextField(
                            name: 'email',
                            decoration: InputDecoration(
                              labelText: 'email'.tr().toUpperCase(),
                              prefixIcon: Icon(Icons.alternate_email),
                            ),
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(context),
                              FormBuilderValidators.email(context),
                            ]),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          InternationalPhoneNumberInput(
                            hintText: "phone number".tr().capitalize(),
                            locale: context.locale.languageCode,
                            errorMessage:
                            "please enter a valid phone number".tr(),
                            onInputChanged: (PhoneNumber number) {
                              print(number.isoCode);
                              print(number.phoneNumber);
                            },
                            onInputValidated: (bool value) {
                              print(value);
                            },
                            // selectorButtonOnErrorPadding: 50,
                            selectorConfig: SelectorConfig(
                                selectorType: PhoneInputSelectorType.DIALOG,
                                setSelectorButtonAsPrefixIcon: true,
                                leadingPadding: 15),
                            ignoreBlank: true,
                            autoValidateMode: AutovalidateMode.disabled,
                            selectorTextStyle: TextStyle(color: Colors.black),
                            initialValue: number,
                            // countries: ["MA"],
                            textFieldController: controller,
                            formatInput: false,
                            keyboardType: TextInputType.numberWithOptions(
                                signed: true, decimal: true),
                            // inputBorder: OutlineInputBorder(),
                            inputBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20)),
                            onSaved: (PhoneNumber number) {
                              print('On Saved: $number');
                            },
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          FormBuilderTextField(
                            name: 'details',
                            decoration: InputDecoration(
                              labelText: 'details'.tr().toUpperCase(),
                              prefixIcon: Icon(Icons.messenger_rounded),
                            ),
                            onChanged: (value) {},
                            // valueTransformer: (text) => num.tryParse(text),
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(context),
                              // FormBuilderValidators.numeric(context),
                              // FormBuilderValidators.max(context, 70),
                            ]),
                            maxLines: 10,
                            keyboardType: TextInputType.multiline,
                          ),
                          SizedBox(
                            height: 20,
                          ),

                          TextButton(
                            child: Text('submit'.tr().capitalize()),
                            style: TextButton.styleFrom(
                              minimumSize: Size(500, 50),
                              primary: Colors.white,
                              backgroundColor: Tools.colorPrimary,
                              // shape: const BeveledRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                            ),
                            onPressed: () {
                              _formKey.currentState!.save();
                              if (_formKey.currentState!.validate()) {
                                print(_formKey.currentState!.value);
                              } else {
                                print("validation failed");
                              }
                            },
                          )
                          // Row(
                          //   children: <Widget>[
                          //     Expanded(
                          //       child: MaterialButton(
                          //         color: Theme.of(context).colorScheme.secondary,
                          //         child: Text(
                          //           "Submit",
                          //           style: TextStyle(color: Colors.white),
                          //         ),
                          //         onPressed: () {
                          //           _formKey.currentState!.save();
                          //           if (_formKey.currentState!.validate()) {
                          //             print(_formKey.currentState!.value);
                          //           } else {
                          //             print("validation failed");
                          //           }
                          //         },
                          //       ),
                          //     ),
                          //     SizedBox(width: 20),
                          //     Expanded(
                          //       child: MaterialButton(
                          //         color: Theme.of(context).colorScheme.secondary,
                          //         child: Text(
                          //           "Reset",
                          //           style: TextStyle(color: Colors.white),
                          //         ),
                          //         onPressed: () {
                          //           _formKey.currentState!.reset();
                          //         },
                          //       ),
                          //     ),
                          //   ],
                          // )
                        ],
                      ),
                    ),
                    // FormBuilderPhoneField(
                    //   name: 'phone_number',
                    //   decoration: const InputDecoration(
                    //     labelText: 'Phone Number',
                    //     hintText: 'Hint',
                    //   ),
                    //   priorityListByIsoCode: ['KE'],
                    //   validator: FormBuilderValidators.compose([
                    //     FormBuilderValidators.required(context),
                    //   ]),
                    // ),
                    // FormBuilderMapField(
                    //   attribute: 'Coordinates',
                    //   decoration: InputDecoration(labelText: 'Select Location'),
                    //   markerIconColor: Colors.red,
                    //   markerIconSize: 50,
                    //   onChanged: (val){
                    //     print(val);
                    //   },
                    // ),
                  ]),
                ),
              )),
        ));
  }

  void _onChangedDateTimeRange(DateTimeRange? value) {}
  void _onChanged(String? value) {}
}



class ProfileSevenPage extends StatelessWidget {
  static final String path = "lib/src/pages/profile/profile7.dart";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          child: Icon(Platform.isIOS?Icons.arrow_back_ios : Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Color.fromRGBO(255, 255, 255, .9),
        body: SafeArea(
          child: ListView(
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Container(
                    width: double.infinity,
                    height: 330,
                    color: Colors.deepOrange,
                  ),
                  Positioned(
                    top: 10,
                    right: 30,
                    child: Icon(
                      Icons.settings,
                      color: Colors.white,
                    ),
                  ),
                  Column(
                    children: <Widget>[
                      Container(
                          height: 90,
                          margin: EdgeInsets.only(top: 60),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white,
                            // child: PNetworkImage(rocket),
                          )
                      ),
                      Padding(
                        padding: EdgeInsets.all(4),
                      ),
                      Text(
                        "Sudip Thapa",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 20),
                        textAlign: TextAlign.center,
                      ),
                      Padding(
                        padding: EdgeInsets.all(4),
                      ),
                      Text(
                        "Kathmandu",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                            fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 77),
                        padding: EdgeInsets.all(10),
                        child: Card(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              Column(
                                children: <Widget>[
                                  Container(
                                      padding:
                                      EdgeInsets.only(top: 15, bottom: 5),
                                      child: Text("Photos",
                                          style: TextStyle(
                                              color: Colors.black54))),
                                  Container(
                                      padding: EdgeInsets.only(bottom: 15),
                                      child: Text("5,000",
                                          style: TextStyle(
                                              color: Colors.black87,
                                              fontSize: 16))),
                                ],
                              ),
                              Column(
                                children: <Widget>[
                                  Container(
                                      padding:
                                      EdgeInsets.only(top: 15, bottom: 5),
                                      child: Text("Followers",
                                          style: TextStyle(
                                              color: Colors.black54))),
                                  Container(
                                      padding: EdgeInsets.only(bottom: 15),
                                      child: Text("5,000",
                                          style: TextStyle(
                                              color: Colors.black87,
                                              fontSize: 16))),
                                ],
                              ),
                              Column(
                                children: <Widget>[
                                  Container(
                                      padding:
                                      EdgeInsets.only(top: 10, bottom: 5),
                                      child: Text("Followings",
                                          style: TextStyle(
                                              color: Colors.black54))),
                                  Container(
                                      padding: EdgeInsets.only(bottom: 10),
                                      child: Text("5,000",
                                          style: TextStyle(
                                              color: Colors.black87,
                                              fontSize: 16))),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      UserInfo()
                    ],
                  )
                ],
              ),
            ],
          ),
        ));
  }
}

class UserInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          Card(
            child: Container(
              alignment: Alignment.topLeft,
              padding: EdgeInsets.all(15),
              child: Column(
                children: <Widget>[
                  Container(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "User Information",
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Divider(
                    color: Colors.black38,
                  ),
                  Container(
                      child: Column(
                        children: <Widget>[
                          ListTile(
                            contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            leading: Icon(Icons.my_location),
                            title: Text("Location"),
                            subtitle: Text("Kathmandu"),
                          ),
                          ListTile(
                            leading: Icon(Icons.email),
                            title: Text("Email"),
                            subtitle: Text("sudeptech@gmail.com"),
                          ),
                          ListTile(
                            leading: Icon(Icons.phone),
                            title: Text("Phone"),
                            subtitle: Text("99--99876-56"),
                          ),
                          ListTile(
                            leading: Icon(Icons.person),
                            title: Text("About Me"),
                            subtitle: Text(
                                "This is a about me link and you can khow about me in this section."),
                          ),
                        ],
                      ))
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
