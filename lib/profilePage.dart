import 'package:flutter/material.dart';
import 'package:VendorApp/profileDetails.dart';
import 'package:firebase_auth/firebase_auth.dart';


class ProfilePage extends StatefulWidget {
  FirebaseUser user;
  ProfilePage(this.user);
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Profile"),
          backgroundColor: Colors.blueAccent.withOpacity(0.7),
          elevation: 0,
        ),
        body: ProfileEditScreen(widget.user),

    );
  }
}
