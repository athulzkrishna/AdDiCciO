import 'package:flutter/material.dart';
import 'package:skype_app/screens/callscreens/pickup/pickup_layout.dart';
import 'package:skype_app/screens/logs/widgets/floatingcoloumn.dart';
import 'package:skype_app/screens/logs/widgets/loglistcontainer.dart';
import 'package:skype_app/utils/universal_variables.dart';
import 'package:skype_app/widgets/skype_appbar.dart';

class LogScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PickupLayout(
      scaffold: Scaffold(
        backgroundColor: UniversalVariables.blackColor,
        appBar: SkypeAppBar(
          title: "Calls",
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.search, color: Colors.black87),
              onPressed: () => Navigator.pushNamed(context, "/search_screen"),
            ),
          ],
        ),
        floatingActionButton: FloatingColumn(),
        body: Padding(
          padding: EdgeInsets.only(left: 15),
          child: LogListContainer(),
        ),
      ),
    );
  }
}
