import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skype_app/models/message.dart';
import 'package:skype_app/models/user.dart';
import 'package:skype_app/provider/user_provider.dart';
import 'package:skype_app/resources/firebase_methods.dart';

class TraiLing extends StatefulWidget {
  final String sender;
  final String receiver;
  TraiLing({@required this.sender, @required this.receiver});

  @override
  _TraiLingState createState() => _TraiLingState();
}

class _TraiLingState extends State<TraiLing> {
  @override
  final FirebaseMethods _authMethods = FirebaseMethods();
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _authMethods.getnumberofunread(widget.sender, widget.receiver),
        builder: (_, s) {
          if (!s.hasData) {
            return CircularProgressIndicator();
          }
          final data = s.data;

          return data > 0
              ? Container(
                  height: 40,
                  width: 40,
                  child: Center(
                    child: Text(
                      '$data',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.lightBlue,
                    border: Border.all(
                      color: Colors.blue,
                    ),
                  ),
                )
              : Container();
        });
  }
}
