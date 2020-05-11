import 'dart:async';
import 'package:flutter/material.dart';
import 'homePage.dart';
import 'login.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'VendorApp',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: OpeningScreen(),
    );
  }
}

enum AuthStatus {
  NOT_DETERMINED,
  NOT_LOGGED_IN,
  LOGGED_IN,
}

class OpeningScreen extends StatefulWidget {
  OpeningScreenState createState() => OpeningScreenState();
}

class OpeningScreenState extends State<OpeningScreen> {
  static AuthStatus authStatus = AuthStatus.NOT_DETERMINED;

  @override
  void initState() {
    FirebaseAuth.instance.currentUser().then((FirebaseUser user) {
      if (user == null) {
        authStatus = AuthStatus.NOT_LOGGED_IN;
      } else {
        if (user.isEmailVerified || user.phoneNumber != null) {
          authStatus = AuthStatus.LOGGED_IN;
        } else {
          authStatus = AuthStatus.NOT_LOGGED_IN;
        }
      }
    });
    Timer(Duration(seconds: 3), () {
      print(authStatus);
      if (authStatus == AuthStatus.NOT_LOGGED_IN) {
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (BuildContext c) {
          return LoginPage();
        }));
      } else if (authStatus == AuthStatus.LOGGED_IN) {
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (BuildContext c) {
          return HomePage();
        }));
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
      ),
    );
  }
}
