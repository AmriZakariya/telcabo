import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:telcabo/Tools.dart';

import '../LoginWidget.dart';

class DrawerWidget extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          // Container(
          //     width: 10,
          //     child: Image(image: AssetImage('assets/icon.png'),)),
          //
          // Text(
          //   Tools.userName,
          //   style: Theme.of(context).textTheme.headline6,
          // ),
          //
          // Text(
          //   Tools.userEmail,
          //   style: Theme.of(context).textTheme.caption!.copyWith(
          //       fontFamily: "Poppins"
          //   ),
          // ),

          GestureDetector(
            onTap: () {
              // currentUser.apiToken != null ? Navigator.of(context).pushNamed('/Profile') : Navigator.of(context).pushNamed('/Login');
            },
            child: UserAccountsDrawerHeader(
                    decoration: BoxDecoration(
                      // color: Theme.of(context).hintColor.withOpacity(0.1),
                    ),
                    accountName: Text(
                      Tools.userName,
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    accountEmail: Text(
                      Tools.userEmail,
                      style: Theme.of(context).textTheme.caption!.copyWith(
                        fontFamily: "Poppins"
                      ),
                    ),
                    currentAccountPicture: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.transparent,
                      // backgroundImage: NetworkImage("${Tools.baseUrl}/img/logo.png"),
                      backgroundImage: AssetImage('assets/icon.png',)
                      ,
                    ),
                  )

          ),

          ListTile(
            onTap: () {
              // context.read<SheetBloc>().add(SheetFetched(listType: SheetListType.webNovels));
              Tools.showDemandesEnAttentes = false ;

              Navigator.pop(context);
            },
            leading: Icon(
              Icons.list,
              color: Theme.of(context).focusColor.withOpacity(1),
            ),
            title: Text(
              "Demandes (${Tools.demandesListSaved?.demandes?.length ?? 0})",
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ),
          ListTile(
            onTap: () {
              // context.read<SheetBloc>().add(SheetFetched(listType: SheetListType.webNovels));
              Tools.showDemandesEnAttentes = true ;
              Navigator.pop(context);
            },
            leading: Icon(
              Icons.list,
              color: Theme.of(context).focusColor.withOpacity(1),
            ),
            title: Text(
              "Demandes en attente (${Tools.demandesListSaved?.demandes?.where((element) {
                return ( ["6", "9"].contains(element.etatId ) && (element.speed?.isEmpty == true)  && (element.speed?.isEmpty == true) );
              }).length })",
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ),

          Divider(color: Colors.black, height: 11.0,),

          ListTile(
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();

              prefs.remove('isOnline') ;
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (_) => LoginForm(),
              ));
            },
            leading: Icon(
              Icons.exit_to_app,
              color: Theme.of(context).focusColor.withOpacity(1),
            ),
            title: Text(
              "Se déconnecter",
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ),

        ],
      ),
    );
  }

}
