import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:skype_app/models/user.dart';
import 'package:skype_app/provider/user_provider.dart';
import 'package:skype_app/resources/firebase_methods.dart';
import 'package:skype_app/resources/firebase_repository.dart';
import 'package:skype_app/screens/callscreens/pickup/pickup_layout.dart';

import 'package:skype_app/screens/pageviews/widgets/contactviewsssss.dart';

import 'package:skype_app/screens/pageviews/widgets/quitbox.dart';
import 'package:skype_app/screens/pageviews/widgets/user_circle.dart';
import 'package:skype_app/screens/search_screen.dart';
import 'package:skype_app/utils/universal_variables.dart';
import 'package:skype_app/utils/utilities.dart';
import 'package:skype_app/widgets/appbar.dart';
import 'package:skype_app/widgets/custom_tile.dart';

class KnownListScreen extends StatefulWidget {
  @override
  _KnownListScreenState createState() => _KnownListScreenState();
}

//global
final FirebaseRepository _repository = FirebaseRepository();

class _KnownListScreenState extends State<KnownListScreen> {
  String currentUserId;
  String initials;
  String kl;
  int k = 15;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _repository.getCurrentUser().then((user) {
      setState(() {
        currentUserId = user.uid;
        initials = Utils.getInitials(user.displayName);
      });
    });
  }

  int count() {
    setState(() async {
      k = await _repository.getCount();
    });
    return k;
  }

  CustomAppBar customAppBar(BuildContext context) {
    return CustomAppBar(
      leading: IconButton(
        icon: Icon(
          Icons.notifications,
          color: Colors.white,
        ),
        onPressed: () {
          k = count();
        },
      ),
      title: UserCircle(),
      centerTitle: true,
      actions: <Widget>[
        IconButton(
          icon: Icon(
            Icons.search,
            color: Colors.white,
          ),
          onPressed: () async {
            if (k == 15) {
              kl = "many";
            } else {
              kl = k.toString();
            }
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SearchScreen(kl),
              ),
            );
            //  k = count();
          },
        ),
        IconButton(
          icon: Icon(
            Icons.more_vert,
            color: Colors.white,
          ),
          onPressed: () {},
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return PickupLayout(
      scaffold: Scaffold(
        backgroundColor: UniversalVariables.blackColor,
        appBar: AppBar(
          backgroundColor: Colors.lightBlue,
          title: Text("People you may know",
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                textStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 15.0,
                    fontWeight: FontWeight.w500),
              )),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          // title: Text("People You May Know"),
        ),
        body: ChattListContainer(),
      ),
    );
  }
}

class ChattListContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    FirebaseMethods _chatMethods = FirebaseMethods();
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    return Container(
      child: FutureBuilder<QuerySnapshot>(
          future: _chatMethods.fetchusers(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var docList = [];
              for (var i = 0; i < snapshot.data.documents.length; i++) {
                if (snapshot.data.documents[i].documentID !=
                    userProvider.getUser.uid) {
                  docList.add(snapshot.data.documents[i]);
                }
              }

              if (docList.isEmpty) {
                return QuitBox();
              }
              return ListView.builder(
                padding: EdgeInsets.all(10),
                itemCount: docList.length,
                //reverse: true,
                itemBuilder: (context, index) {
                  User contact = User.fromMap(docList[index].data);

                  return ContactViews(contact);
                },
              );
            }

            return Center(child: CircularProgressIndicator());
          }),
    );
  }
}
