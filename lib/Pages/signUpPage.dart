// ignore_for_file: prefer_const_constructors, avoid_unnecessary_containers, unused_local_variable, avoid_print, unnecessary_null_comparison

import 'package:chatapp/Pages/Homepage.dart';
import 'package:chatapp/Pages/completeProfile.dart';
import 'package:chatapp/Pages/loginPage.dart';
import 'package:chatapp/Widgets/my_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../Models/uiHelper.dart';
import '../Models/userModel.dart';
import '../Widgets/widgets.dart';

class SignUpPage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;
  final User targetUser;
  const SignUpPage(
      {super.key,
      required this.userModel,
      required this.firebaseUser,
      required this.targetUser});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController cPasswordController = TextEditingController();

  void checkValues() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String cPassword = cPasswordController.text.trim();

    if (email == "" || password == "" || cPassword == "") {
      UIHelper.showAlertDialog(
          context, "Incomplete Data", "Please fill all the fields!");
      print("Fill all the fields");
    } else if (password != cPassword) {
      UIHelper.showAlertDialog(context, "Password Mismatch",
          "The passwords you have entered does not match!");
      print("Fill all the fields");
    } else {
      signUp(email, password);
    }
  }

  void signUp(String email, String password) async {
    UserCredential? credential;

    UIHelper.showLoadingDialog(context, "Creating new user...");

    try {
      credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (ex) {
      Navigator.pop(context);

      UIHelper.showAlertDialog(
          context, "An error occured!", ex.message.toString());
      print(ex.code.toString());
    }

    if (credential != null) {
      String uid = credential.user!.uid;
      UserModel newUser = UserModel(
        uid: uid,
        email: email,
        fullname: "",
        profilepic: "",
      );
      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .set(newUser.toMap())
          .then((value) {
        print("New User Created!");
        Navigator.popUntil(context, (route) => route.isFirst);
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: ((context) {
          return CompleteProfile(
            userModel: newUser,
            firebaseUser: credential!.user!,
            targetUser: widget.targetUser,
          );
        })));
      });
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
                "Welcome Back",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "create account to text others",
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
                  labelText: "Password",
                  prefixIcon: Icon(
                    Icons.lock,
                    color: Color(0xff5ac18e),
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: cPasswordController,
                obscureText: true,
                decoration: textInputDecoration.copyWith(
                  prefixIcon: Icon(
                    Icons.lock,
                    color: Color(0xff5ac18e),
                  ),
                  labelText: "Confirm Password",
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  checkValues();
                  Navigator.push(context,
                      MaterialPageRoute(builder: ((context) {
                    return Homepage(
                      userModel: widget.userModel,
                      firebaseUser: widget.firebaseUser,
                      targetUser: widget.targetUser,
                    );
                  })));
                },
                child: Text("Sign Up"),
                style: registerPrimary,
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
                  text: "Already have a account?",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
              TextSpan(
                  text: "Login Now",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: ((context) {
                        return LoginPage(
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
