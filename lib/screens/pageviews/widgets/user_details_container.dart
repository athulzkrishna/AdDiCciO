import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:skype_app/enum/user_state.dart';
import 'package:skype_app/models/user.dart';
import 'package:skype_app/provider/user_provider.dart';
import 'package:skype_app/resources/firebase_methods.dart';
import 'package:flutter/scheduler.dart';
import 'package:skype_app/screens/chatscreens/widgets/cached_image.dart';
import 'package:skype_app/screens/login_screen.dart';
import 'package:skype_app/utils/utilities.dart';
import 'package:skype_app/widgets/appbar.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'shimmering_logo.dart';

class UserDetailsContainer extends StatefulWidget {
  @override
  _UserDetailsContainerState createState() => _UserDetailsContainerState();
}

class _UserDetailsContainerState extends State<UserDetailsContainer> {
  final FirebaseMethods authMethods = FirebaseMethods();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      UserProvider userProvider =
          Provider.of<UserProvider>(context, listen: false);
      await userProvider.refreshUser();
    });
  }

  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);

    signOut() async {
      final bool isLoggedOut = await FirebaseMethods().signOut();
      if (isLoggedOut) {
        // set userState to offline as the user logs out'
        authMethods.setUserState(
          userId: userProvider.getUser.uid,
          userState: UserState.Offline,
        );

        // move the user to login screen
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
          (Route<dynamic> route) => false,
        );
      }
    }

    return Container(
      margin: EdgeInsets.only(top: 25),
      child: Column(
        children: <Widget>[
          CustomAppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black87),
              onPressed: () => Navigator.maybePop(context),
            ),
            centerTitle: true,
            title: ShimmeringLogo(),
            actions: <Widget>[
              FlatButton(
                onPressed: () => signOut(),
                child: Text(
                  "Sign Out",
                  style: TextStyle(color: Colors.black87, fontSize: 12),
                ),
              )
            ],
          ),
          UserDetailsBody(),
        ],
      ),
    );
  }
}

class UserDetailsBody extends StatefulWidget {
  @override
  _UserDetailsBodyState createState() => _UserDetailsBodyState();
}

class _UserDetailsBodyState extends State<UserDetailsBody> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      UserProvider userProvider =
          Provider.of<UserProvider>(context, listen: false);
      await userProvider.refreshUser();
    });
  }

  final FirebaseMethods authMethods = FirebaseMethods();
  bool p = false;
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    final User user = userProvider.getUser;

    void set() {
      setState(() {
        p = true;
      });
    }

    void riset() {
      setState(() {
        p = false;
        Navigator.maybePop(context);
      });
    }

    void change({@required ImageSource source}) {
      setState(() async {
        // String str =
        //  'https://homepages.cae.wisc.edu/~ece533/images/airplane.png';
        set();
        File selectedImage = await Utils.pickImage(source: source);
        String url = await authMethods.uploadImageToStorage(selectedImage);

        authMethods.setUserphoto(userId: user.uid, l: url);
        riset();
        //CircularProgressIndicator();
      });
    }

    return p
        ? Load()
        : Container(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: Column(
              children: [
                Row(
                  children: [
                    CachedImage(
                      user.profilePhoto,
                      isRound: true,
                      radius: 50,
                    ),
                    SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          user.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          user.email,
                          style: TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 3,
                    ),
                    Expanded(
                        child: FlatButton(
                            color: Colors.blue,
                            highlightColor: Colors.blue,
                            onPressed: () =>
                                change(source: ImageSource.gallery),
                            child: Center(
                              child: Text('Change Picture',
                                  style: TextStyle(
                                      fontSize: 10, color: Colors.white)),
                            ))),
                  ],
                ),
                // p
                //  ?

                // Find the ScaffoldMessenger in the widget tree
                // and use it to show a SnackBar.
                //ScaffoldMessenger.of(context).showSnackBar(snackBar)
                // CircularProgressIndicator()
                // : Container(),
              ],
            ),
          );
  }
}

class Load extends StatefulWidget {
  @override
  _LoadState createState() => _LoadState();
}

class _LoadState extends State<Load> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 500,
      height: 700,
      color: Colors.blue[900],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SpinKitRotatingCircle(
              color: Colors.white,
              size: 50.0,
            ),
            Center(
              child: Text('Please wait while its loading',
                  style: TextStyle(fontSize: 10, color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }
}
