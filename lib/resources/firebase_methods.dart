import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:skype_app/constants/strings.dart';
import 'package:skype_app/enum/user_state.dart';
import 'package:skype_app/models/contact.dart';
import 'package:skype_app/models/message.dart';
import 'package:skype_app/models/user.dart';
import 'package:skype_app/utils/utilities.dart';

class FirebaseMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  GoogleSignIn _googleSignIn = GoogleSignIn();
  static final Firestore firestore = Firestore.instance;
  static final Firestore _firestore = Firestore.instance;
  static final CollectionReference _userCollection =
      _firestore.collection(USERS_COLLECTION);
  final CollectionReference _messageCollection =
      _firestore.collection(MESSAGES_COLLECTION);

  //user class
  User user = User();
  StorageReference _storageReference;
  Future<FirebaseUser> getCurrentUser() async {
    FirebaseUser currentUser;
    currentUser = await _auth.currentUser();
    return currentUser;
  }

  Future<FirebaseUser> signIn() async {
    GoogleSignInAccount _signInAccount = await _googleSignIn.signIn();
    GoogleSignInAuthentication _signInAuthentication =
        await _signInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: _signInAuthentication.accessToken,
        idToken: _signInAuthentication.idToken);

    FirebaseUser user = await _auth.signInWithCredential(credential);
    return user;
  }

  Future<bool> authenticateUser(FirebaseUser user) async {
    QuerySnapshot result = await firestore
        .collection("users")
        .where("email", isEqualTo: user.email)
        .getDocuments();

    final List<DocumentSnapshot> docs = result.documents;

    //if user is registered then length of list > 0 or else less than 0
    return docs.length == 0 ? true : false;
  }

  Future<void> addDataToDb(FirebaseUser currentUser) async {
    String username = Utils.getUsername(currentUser.email);

    user = User(
        uid: currentUser.uid,
        email: currentUser.email,
        name: currentUser.displayName,
        profilePhoto: currentUser.photoUrl,
        username: username);

    firestore
        .collection("users")
        .document(currentUser.uid)
        .setData(user.toMap(user));
  }

  Future<bool> signOut() async {
    try {
      await _googleSignIn.disconnect();
      await _googleSignIn.signOut();
      await _auth.signOut();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<User>> fetchAllUsers(FirebaseUser currentUser) async {
    List<User> userList = List<User>();

    QuerySnapshot querySnapshot =
        await firestore.collection("users").getDocuments();
    for (var i = 0; i < querySnapshot.documents.length; i++) {
      if (querySnapshot.documents[i].documentID != currentUser.uid) {
        userList.add(User.fromMap(querySnapshot.documents[i].data));
      }
    }
    return userList;
  }

  Future<void> addMessageToDb(
      Message message, User sender, User receiver) async {
    var map = message.toMap();

    //   await firestore
    //     .collection("messages")
    //   .document(message.senderId)
    //   .collection(message.receiverId)
    //   .add(map);
    String convid = Utils().getid(message.senderId, message.receiverId);
    addToContacts(senderId: message.senderId, receiverId: message.receiverId);
    return await firestore
        .collection("messages")
        .document(convid)
        .collection(convid)
        .add(map);
  }

  DocumentReference getContactsDocument({String of, String forContact}) =>
      _userCollection
          .document(of)
          .collection(CONTACTS_COLLECTION)
          .document(forContact);

  addToContacts({String senderId, String receiverId}) async {
    Timestamp currentTime = Timestamp.now();

    await addToSenderContacts(senderId, receiverId, currentTime);
    await addToReceiverContacts(senderId, receiverId, currentTime);
  }

  Future<void> addToSenderContacts(
    String senderId,
    String receiverId,
    currentTime,
  ) async {
    DocumentSnapshot senderSnapshot =
        await getContactsDocument(of: senderId, forContact: receiverId).get();

    //if (!senderSnapshot.exists) {
    //does not exists
    Contact receiverContact = Contact(
      uid: receiverId,
      addedOn: currentTime,
    );

    var receiverMap = receiverContact.toMap(receiverContact);
    if (!senderSnapshot.exists) {
      await getContactsDocument(of: senderId, forContact: receiverId)
          .setData(receiverMap);
    } else {
      await getContactsDocument(of: senderId, forContact: receiverId)
          .updateData(receiverMap);
    }
    // }
  }

  Future<void> addToReceiverContacts(
    String senderId,
    String receiverId,
    currentTime,
  ) async {
    DocumentSnapshot receiverSnapshot =
        await getContactsDocument(of: receiverId, forContact: senderId).get();

    //if (!receiverSnapshot.exists) {
    //does not exists
    Contact senderContact = Contact(
      uid: senderId,
      addedOn: currentTime,
    );

    var senderMap = senderContact.toMap(senderContact);
    if (!receiverSnapshot.exists) {
      await getContactsDocument(of: receiverId, forContact: senderId)
          .setData(senderMap);
    } else {
      await getContactsDocument(of: receiverId, forContact: senderId)
          .updateData(senderMap);
    }
    //}
  }

  Future<User> getUserDetailsById(id) async {
    try {
      DocumentSnapshot documentSnapshot =
          await _userCollection.document(id).get();
      return User.fromMap(documentSnapshot.data);
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<User> getUserDetails() async {
    FirebaseUser currentUser = await getCurrentUser();

    DocumentSnapshot documentSnapshot =
        await _userCollection.document(currentUser.uid).get();

    return User.fromMap(documentSnapshot.data);
  }

  Stream<QuerySnapshot> fetchContacts({String userId}) => _userCollection
      .document(userId)
      .collection(CONTACTS_COLLECTION)
      .orderBy("added_on")
      .snapshots();

  Stream<QuerySnapshot> fetchLastMessageBetween({
    @required String senderId,
    @required String receiverId,
  }) {
    String idd = Utils().getid(senderId, receiverId);
    return _messageCollection
        .document(idd)
        .collection(idd)
        .orderBy("timestamp")
        .snapshots();
  }

  void setUserState({@required String userId, @required UserState userState}) {
    int stateNum = Utils.stateToNum(userState);

    _userCollection.document(userId).updateData({
      "state": stateNum,
    });
  }

  Stream<DocumentSnapshot> getUserStream({@required String uid}) =>
      _userCollection.document(uid).snapshots();
  Future<int> getCount() async {
    QuerySnapshot result = await firestore.collection("users").getDocuments();

    final List<DocumentSnapshot> docs = result.documents;

    //if user is registered then length of list > 0 or else less than 0
    print(
      docs.length,
    );
    //print('hello');
    return docs.length;
  }

  Future<QuerySnapshot> fetchusers() => _userCollection.getDocuments();
  Future<List<User>> fetchuusers(FirebaseUser currentUser) async {
    List<User> userList = List<User>();

    QuerySnapshot querySnapshot =
        await firestore.collection("users").getDocuments();
    for (var i = 0; i < querySnapshot.documents.length; i++) {
      if (querySnapshot.documents[i].documentID != currentUser.uid) {
        userList.add(User.fromMap(querySnapshot.documents[i].data));
      }
    }
    return userList;
  }

  void setUserphoto({@required String userId, @required String l}) {
    _userCollection.document(userId).updateData({
      "profile_photo": l,
    });
  }
  // void uploadImage(File image, String receiverId, String senderId,
  // ImageUploadProvider imageUploadProvider) async {
  // Set some loading value to db and show it to user
  // imageUploadProvider.setToLoading();

  // Get url from the image bucket
  // String url = await uploadImageToStorage(image);

  // Hide loading
  //  imageUploadProvider.setToIdle();

  //setImageMsg(url, receiverId, senderId);
  //}
  Future<String> uploadImageToStorage(File imageFile) async {
    // mention try catch later on

    try {
      _storageReference = FirebaseStorage.instance
          .ref()
          .child('${DateTime.now().millisecondsSinceEpoch}');
      StorageUploadTask storageUploadTask =
          _storageReference.putFile(imageFile);
      var url = await (await storageUploadTask.onComplete).ref.getDownloadURL();
      // print(url);
      return url;
    } catch (e) {
      return null;
    }
  }

  void makeit(idd, doc) {
    final DocumentReference document = Firestore.instance
        .collection('messages')
        .document(idd)
        .collection(idd)
        .document(doc.documentID);

    document.updateData(<String, dynamic>{'seen': true});
  }

  Future<int> getnumberofunread(String a, String b) async {
    int c = 0;
    String k = Utils().getid(a, b);
    QuerySnapshot querySnapshot = await firestore
        .collection("messages")
        .document(k)
        .collection(k)
        .orderBy("timestamp", descending: true)
        .getDocuments();
    for (var i = 0; i < querySnapshot.documents.length; i++) {
      Message p = Message.fromMap(querySnapshot.documents[i].data);
      if (p.seen == true || p.senderId == a) {
        break;
      } else {
        c++;
      }
    }
    return c;
  }
}


//    for (var i = 0; i < receivers.documents.length; i++) {
//      _messageCollection
//          .document(receiver)
//          .collection(user)
//          .document(l[i])
//          .updateData({'seen': true});
//    }  print(receivers.documents.length);
//    for (var i = 0; i < receivers.documents.length; i++) {
//      if (true) {
//        l.add(receivers.documents[i].documentID);
  //    }
//    }