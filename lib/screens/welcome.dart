import 'package:skype_app/configs/newconstant.dart';

import 'package:flutter/material.dart';
import 'package:skype_app/screens/login_screen.dart';
import 'package:skype_app/utils/universal_variables.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UniversalVariables.blackColor,
      body: SafeArea(
        child: Column(
          children: [
            Spacer(flex: 2),
            Image.asset("assets/welcome_image.png"),
            Spacer(flex: 3),
            Text("Welcome to Addició \nMessaging app",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                    color: Colors.lightBlue,
                    letterSpacing: 1.2)),
            Spacer(),
            Text(
              "Chat and Video call \nYour Favourite People\n",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Colors.lightBlue,
                fontWeight: FontWeight.w400,
              ),
            ),
            Spacer(flex: 3),
            FittedBox(
              child: TextButton(
                  onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginScreen(),
                        ),
                      ),
                  child: Row(
                    children: [
                      Text(
                        "Next",
                        style: TextStyle(
                          color: Colors.lightBlue,
                          fontSize: 18,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      SizedBox(width: kDefaultPadding / 4),
                      Icon(Icons.arrow_forward_ios,
                          size: 16, color: UniversalVariables.greyColor)
                    ],
                  )),
            )
          ],
        ),
      ),
    );
  }
}
