import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skype_app/models/contact.dart';
import 'package:skype_app/provider/user_provider.dart';
import 'package:skype_app/resources/firebase_methods.dart';
import 'package:skype_app/resources/firebase_repository.dart';
import 'package:skype_app/screens/callscreens/pickup/pickup_layout.dart';
import 'package:skype_app/screens/pageviews/pplumk.dart';
import 'package:skype_app/screens/pageviews/widgets/contact_view.dart';
import 'package:skype_app/screens/pageviews/widgets/new_chat_button.dart';
import 'package:skype_app/screens/pageviews/widgets/quiet_box.dart';
import 'package:skype_app/screens/pageviews/widgets/user_circle.dart';
import 'package:skype_app/screens/search_screen.dart';
import 'package:skype_app/utils/universal_variables.dart';
import 'package:skype_app/utils/utilities.dart';
import 'package:skype_app/widgets/appbar.dart';
import 'package:skype_app/widgets/custom_tile.dart';

class ChatListScreen extends StatefulWidget {
  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

//global
final FirebaseRepository _repository = FirebaseRepository();

class _ChatListScreenState extends State<ChatListScreen> {
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
          color: Colors.black87,
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
            color: Colors.black87,
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
            k = count();
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return PickupLayout(
      scaffold: Scaffold(
        backgroundColor: UniversalVariables.blackColor,
        appBar: customAppBar(context),
        floatingActionButton: FloatingActionButton(
            child: Container(
              decoration: BoxDecoration(
                  gradient: UniversalVariables.fabGradient,
                  borderRadius: BorderRadius.circular(50)),
              child: Icon(
                Icons.edit,
                color: Colors.white,
                size: 25,
              ),
              padding: EdgeInsets.all(15),
            ),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => KnownListScreen()));
            }),
        body: ChatListContainer(),
      ),
    );
  }
}

class ChatListContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    FirebaseMethods _chatMethods = FirebaseMethods();
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    return Container(
      child: StreamBuilder<QuerySnapshot>(
          stream: _chatMethods.fetchContacts(userId: userProvider.getUser.uid),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var docList = snapshot.data.documents;
              var reverse = new List.from(docList.reversed);
              if (docList.isEmpty) {
                return QuietBox();
              }
              return ListView.builder(
                padding: EdgeInsets.all(10),
                itemCount: docList.length,
                //reverse: true,
                itemBuilder: (context, index) {
                  Contact contact = Contact.fromMap(reverse[index].data);

                  return ContactView(contact);
                },
              );
            }

            return Center(child: CircularProgressIndicator());
          }),
    );
  }
}
