import 'package:cloud_firestore/cloud_firestore.dart';

class Mesg {
  String senderId;
  String receiverId;
  String type;
  String message;
  Timestamp timestamp;
  String photoUrl;
  String seen;

  Mesg(
      {this.senderId,
      this.receiverId,
      this.type,
      this.message,
      this.timestamp,
      this.seen});

  //Will be only called when you wish to send an image
  // named constructor
  Mesg.imageMessage(
      {this.senderId,
      this.receiverId,
      this.message,
      this.type,
      this.timestamp,
      this.photoUrl});

  Map toMap() {
    var map = Map<String, dynamic>();
    map['senderId'] = this.senderId;
    map['receiverId'] = this.receiverId;
    map['type'] = this.type;
    map['message'] = this.message;
    map['timestamp'] = this.timestamp;
    map['seen'] = this.seen;
    return map;
  }

  // named constructor
  Mesg.fromMap(Map<String, dynamic> map) {
    this.senderId = map['senderId'];
    this.receiverId = map['receiverId'];
    this.type = map['type'];
    this.message = map['message'];
    this.timestamp = map['timestamp'];
    this.seen = map['seen'];
  }
}
