import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/animation.dart';
import 'package:skype_app/screens/home_screen.dart';
import 'package:skype_app/utils/universal_variables.dart';

import 'animation_screen.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Material(
        child: Stack(children: <Widget>[
      Scaffold(body: HomeScreen()),
      IgnorePointer(
          child: AnimationScreen(color: UniversalVariables.blackColor))
    ]));
  }
}
