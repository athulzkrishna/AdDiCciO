import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skype_app/models/contact.dart';
import 'package:skype_app/models/user.dart';
import 'package:skype_app/provider/user_provider.dart';
import 'package:skype_app/resources/firebase_methods.dart';
import 'package:skype_app/screens/chatscreens/chat_screen.dart';
import 'package:skype_app/screens/chatscreens/widgets/cached_image.dart';
import 'package:skype_app/screens/pageviews/widgets/trailing.dart';
import 'package:skype_app/utils/universal_variables.dart';
import 'package:skype_app/widgets/custom_tile.dart';
import 'package:skype_app/widgets/profile_helper.dart';
import 'package:skype_app/widgets/tile.dart';
import 'package:recase/recase.dart';
import 'last_message_container.dart';
import 'online_dot_indicator.dart';

class ContactView extends StatelessWidget {
  final Contact contact;
  final FirebaseMethods _authMethods = FirebaseMethods();

  ContactView(this.contact);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User>(
      future: _authMethods.getUserDetailsById(contact.uid),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          User user = snapshot.data;

          return ViewLayout(
            contact: user,
          );
        }
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}

class ViewLayout extends StatelessWidget {
  final User contact;
  final FirebaseMethods _chatMethods = FirebaseMethods();

  ViewLayout({
    @required this.contact,
  });

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);

    return Tile(
      trailing:
          TraiLing(receiver: contact.uid, sender: userProvider.getUser.uid),
      mini: false,
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              receiver: contact,
            ),
          )),
      onLongPress: () =>
          onTapProfileChatItem(context, contact, userProvider.getUser),
      title: Text(
        (contact != null ? contact.name.camelCase : null) != null
            ? contact.name.titleCase
            : "..",
        style:
            TextStyle(color: Colors.black87, fontFamily: "Arial", fontSize: 16),
      ),
      subtitle: LastMessageContainer(
        stream: _chatMethods.fetchLastMessageBetween(
          senderId: userProvider.getUser.uid,
          receiverId: contact.uid,
        ),
      ),
      leading: Container(
        constraints: BoxConstraints(maxHeight: 60, maxWidth: 60),
        child: Stack(
          children: <Widget>[
            CachedNetworkImage(
              imageUrl: contact
                  .profilePhoto, //'https://homepages.cae.wisc.edu/~ece533/images/airplane.png',
              imageBuilder: (context, imageProvider) => Container(
                // width: 50.0,
                // height: 50.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image:
                      DecorationImage(image: imageProvider, fit: BoxFit.cover),
                ),
              ),
              placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) => Icon(Icons.call),
            ),

            //  CachedImage(
            //  contact.profilePhoto,
            //   radius: 80,
            //   isRound: true,
            // ),
            OnlineDotIndicator(
              uid: contact.uid,
            ),
          ],
        ),
      ),
    );
  }
}

void onTapProfileChatItem(BuildContext context, User chat, User sender) {
  Dialog profileDialog = DialogHelpers.getProfileDialog(
      context: context,
      id: chat.uid,
      imageUrl: chat.profilePhoto,
      name: chat.name,
      d: chat,
      u: sender);
  showDialog(
      context: context, builder: (BuildContext context) => profileDialog);
}
