import 'package:flutter/material.dart';
import 'package:skype_app/screens/search_screen.dart';
import 'package:skype_app/utils/universal_variables.dart';

class QuitBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 25),
        child: Container(
          color: UniversalVariables.separatorColor,
          padding: EdgeInsets.symmetric(vertical: 35, horizontal: 25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                "Please come again later",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                ),
              ),
              SizedBox(height: 25),
              Text(
                "There is an error with our server",
                textAlign: TextAlign.center,
                style: TextStyle(
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.normal,
                  fontSize: 15,
                ),
              ),
              SizedBox(height: 25),
              FlatButton(
                color: UniversalVariables.lightBlueColor,
                child: Text("START SEARCHING"),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchScreen("many"),
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
