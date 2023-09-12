// ignore_for_file: prefer_const_constructors, avoid_print, unused_local_variable, use_build_context_synchronously, duplicate_ignore

import 'package:chatapp/Pages/signUpPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../Models/uiHelper.dart';
import '../Models/userModel.dart';
import '../Widgets/my_button.dart';
import '../Widgets/widgets.dart';
import 'Homepage.dart';

class LoginPage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;
  final User targetUser;
  LoginPage(
      {super.key,
      required this.userModel,
      required this.firebaseUser,
      required this.targetUser});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void checkValues() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email == "" || password == "") {
      print("Please fill all the fields");
      UIHelper.showAlertDialog(
          context, "Incomplete Data", "Please fill all the fields");
    } else {
      logIn(email, password);
    }
  }

  void logIn(String email, String password) async {
    UserCredential? credential;

    UIHelper.showLoadingDialog(context, "Loggin In...");

    try {
      credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (ex) {
      //Close the loading dialog
      Navigator.pop(context);

      //Show Alert Dialog
      UIHelper.showAlertDialog(
          context, "An erorr occurred", ex.message.toString());
      print(ex.message.toString());
    }

    if (credential != null) {
      String uid = credential.user!.uid;

      DocumentSnapshot userData =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      UserModel userModel =
          UserModel.fromMap(userData.data() as Map<String, dynamic>);

      print("Log In Successful");
      // ignore: use_build_context_synchronously
      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
        return Homepage(
          userModel: userModel,
          firebaseUser: credential!.user!,
          targetUser: widget.targetUser,
        );
      }));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
          child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 30,
        ),
        child: Center(
          child: SingleChildScrollView(
              child: Column(
            children: [
              Text(
                "Login to see what they are talking",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Image.asset("assets/knust.png"),
              SizedBox(height: 10),
              TextFormField(
                controller: emailController,
                decoration: textInputDecoration.copyWith(
                  prefixIcon: Icon(
                    Icons.email,
                    color: Color(0xff5ac18e),
                  ),
                  labelText: "Email Address",
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: textInputDecoration.copyWith(
                  prefixIcon: Icon(
                    Icons.lock,
                    color: Color(0xff5ac18e),
                  ),
                  labelText: "Password",
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  checkValues();
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return Homepage(
                      firebaseUser: widget.firebaseUser,
                      userModel: widget.userModel,
                      targetUser: widget.targetUser,
                    );
                  }));
                },
                child: Text("Log in"),
                style: signUpPrimary,
              ),
            ],
          )),
        ),
      )),
      bottomNavigationBar: Container(
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                  text: "Don't have an account?",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
              TextSpan(
                  text: "Register Now",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: ((context) {
                        return SignUpPage(
                            userModel: widget.userModel,
                            firebaseUser: widget.firebaseUser,
                            targetUser: widget.targetUser);
                      })));
                    })
            ],
          ),
        ),
      ),
    );
  }
}
