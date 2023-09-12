// ignore_for_file: prefer_const_constructors, non_constant_identifier_names, unused_local_variable

import 'package:chatapp/Pages/loginPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'Models/firebaseHelper.dart';
import 'Models/userModel.dart';

var uuid = Uuid();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  User? currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser != null) {
    //   //Logged In
    UserModel? thisuserModel =
        await FirebaseHelper.getUserModelById(currentUser.uid);
    if (thisuserModel != null) {
      var targetUser1;
      runApp(MyAppLoggedIn(
        userModel: thisuserModel,
        firebaseUser: currentUser,
        targetUser: currentUser,
      ));
      var targetUser;
      runApp(MyAppLoggedIn(
        userModel: thisuserModel,
        firebaseUser: currentUser,
        targetUser: targetUser,
      ));
    } else {
      runApp(MyApp());
    }
  } else {
    //   //Not Logged In
    runApp(MyApp());
  }
}

//Not Logged In
class MyApp extends StatelessWidget {
  late final UserModel userModel;
  late final User firebaseUser;
  late final User targetUser;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(
        userModel: userModel,
        firebaseUser: firebaseUser,
        targetUser: targetUser,
      ),
    );
  }
}

// ALready Logged In
class MyAppLoggedIn extends StatelessWidget {
  final UserModel userModel;
  final User firebaseUser;
  final User targetUser;

  const MyAppLoggedIn(
      {super.key,
      required this.userModel,
      required this.firebaseUser,
      required this.targetUser});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(
        userModel: userModel,
        firebaseUser: firebaseUser,
        targetUser: targetUser,
      ),
    );
  }
}
