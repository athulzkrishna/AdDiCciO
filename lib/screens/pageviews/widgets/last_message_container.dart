import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skype_app/models/message.dart';
import 'package:skype_app/provider/user_provider.dart';

class LastMessageContainer extends StatelessWidget {
  final stream;

  LastMessageContainer({
    @required this.stream,
  });

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    return StreamBuilder(
      stream: stream,
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          var docList = snapshot.data.documents;

          if (docList.isNotEmpty) {
            Message message = Message.fromMap(docList.last.data);
            bool p =
                message.seen || (message.senderId == userProvider.getUser.uid);
            return p
                ? SizedBox(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: Text(
                      message.message,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey[300],
                        fontSize: 14,
                      ),
                    ),
                  )
                : SizedBox(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: Text(
                      message.message,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[800],
                        fontSize: 15,
                      ),
                    ),
                  );
          }

          return Text(
            "No Message",
            style: TextStyle(
              color: Colors.grey[300],
              fontSize: 14,
            ),
          );
        }
        return Text(
          "..",
          style: TextStyle(
            color: Colors.grey[300],
            fontSize: 14,
          ),
        );
      },
    );
  }
}
