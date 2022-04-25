import 'dart:ui';

import 'package:flutter/material.dart';


import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:telcabo/DemandeList.dart';
import 'package:telcabo/Tools.dart';

class LoginWidget extends StatefulWidget {
  const LoginWidget({Key? key}) : super(key: key);

  @override
  _LoginWidgetState createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {




  FirebaseMessaging messaging = FirebaseMessaging.instance;

  TextEditingController _emailController = TextEditingController(
    // text: "agent.test@telcabo.com"
    text: "0619993849"
  );
  TextEditingController _passwordController = TextEditingController(
    text: "aa"
  );





  @override
  Widget build(BuildContext context) {

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if(message.data['key'] == "image_update"){
        //call GET image API and display on app
      }
      //note: you can differentiate notification type with "key" so that you can perform different functions for each notification type
      return;
    });



    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Stack(
          children: [
            Container(
              decoration: new BoxDecoration(
                image: new DecorationImage(
                  image: new ExactAssetImage('assets/bg_login.jpeg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: new BackdropFilter(
                filter: new ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: new Container(
                  decoration: new BoxDecoration(color: Colors.white.withOpacity(0.0)),
                ),
              ),
            ),
            SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height / 4,),
                  Container(
                      child: Image(image: AssetImage('assets/logo.png'), width: MediaQuery.of(context).size.width / 1.7,)
                  ),
                  SizedBox(height: 40,),
                  Container(
                    margin: EdgeInsets.only(left: 35, right: 35),
                    child: Column(
                      children: [
                        TextField(
                          style: TextStyle(color: Colors.black),
                          controller: _emailController,
                          decoration: InputDecoration(
                              prefixIcon: Icon(Icons.person),
                              fillColor: Colors.grey.shade100,
                              filled: true,
                              hintText: "Login",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              )),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        TextField(
                          style: TextStyle(),
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                              prefixIcon: Icon(Icons.key),
                              fillColor: Colors.grey.shade100,
                              filled: true,
                              hintText: "Password",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              )),
                        ),
                        SizedBox(
                          height: 40,
                        ),

                        ElevatedButton(
                          onPressed: () async {
                            Map<String, dynamic> loginMap = {
                              "username" : _emailController.value.text,
                              "password" : _passwordController.value.text
                            };


                            var callWsLogin = await Tools.callWsLogin(loginMap) ;
                            if(callWsLogin){
                              SchedulerBinding.instance?.addPostFrameCallback((_) {
                                Navigator.of(context).pushReplacement(MaterialPageRoute(
                                  builder: (_) => DemandeList(),
                                ));
                              });

                            };
                          },
                          child: const Text(
                            'Se Connecter',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18.0,
                              letterSpacing: 2
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            // shape: CircleBorder(),
                            minimumSize: Size(280, 60),
                            // primary: Tools.colorPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(15.0),
                            ),
                          ),
                        ),

                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


}