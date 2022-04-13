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
          GestureDetector(
            onTap: () {
              // currentUser.apiToken != null ? Navigator.of(context).pushNamed('/Profile') : Navigator.of(context).pushNamed('/Login');
            },
            child:UserAccountsDrawerHeader(
                    decoration: BoxDecoration(
                      color: Theme.of(context).hintColor.withOpacity(0.1),
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
                      backgroundColor: Theme.of(context).accentColor,
                      backgroundImage: NetworkImage("https://telcabo.castlit.com/img/logo.png"),
                    ),
                  )

          ),

          ListTile(
            onTap: () {
              // context.read<SheetBloc>().add(SheetFetched(listType: SheetListType.webNovels));
              Navigator.pop(context);
            },
            leading: Icon(
              Icons.list,
              color: Theme.of(context).focusColor.withOpacity(1),
            ),
            title: Text(
              "Demandes",
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ),
          ListTile(
            onTap: () {
              // context.read<SheetBloc>().add(SheetFetched(listType: SheetListType.webNovels));
              Navigator.pop(context);
            },
            leading: Icon(
              Icons.list,
              color: Theme.of(context).focusColor.withOpacity(1),
            ),
            title: Text(
              "Demandes en attente",
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ),

          Divider(color: Colors.black, height: 11.0,),

          ListTile(
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();

              prefs.remove('isOnline') ;
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (_) => LoginWidget(),
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
