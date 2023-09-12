// ignore_for_file: prefer_const_constructors, avoid_unnecessary_containers, unused_local_variable, body_might_complete_normally_nullable, use_build_context_synchronously, unused_import, duplicate_ignore

import 'package:chatapp/Models/chatRoomModel.dart';
import 'package:chatapp/Models/firebaseHelper.dart';
import 'package:chatapp/Models/uiHelper.dart';
import 'package:chatapp/Pages/chatRoomPage.dart';
import 'package:chatapp/Pages/loginPage.dart';
// ignore: unused_import
import 'package:chatapp/Pages/seachPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../Models/userModel.dart';

class Homepage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;
  final User targetUser;
  const Homepage({
    super.key,
    required this.userModel,
    required this.firebaseUser,
    required this.targetUser,
  });

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat App"),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.popUntil(context, (route) => route.isFirst);
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) {
                  return LoginPage(
                    userModel: widget.userModel,
                    firebaseUser: widget.firebaseUser,
                    targetUser: widget.targetUser,
                  );
                }));
              },
              icon: Icon(Icons.exit_to_app))
        ],
      ),
      body: SafeArea(
        child: Container(
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("chatrooms")
                .where("users", arrayContains: widget.userModel.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                if (snapshot.hasData) {
                  QuerySnapshot chatRoomSnapshot =
                      snapshot.data as QuerySnapshot;

                  return ListView.builder(
                    itemCount: chatRoomSnapshot.docs.length,
                    itemBuilder: ((context, index) {
                      ChatRoomModel chatRoomModel = ChatRoomModel.fromMap(
                          chatRoomSnapshot.docs[index].data()
                              as Map<String, dynamic>);

                      Map<String, dynamic> participants =
                          chatRoomModel.participants!;

                      List<String> participantsKeys =
                          participants.keys.toList();
                      participantsKeys.remove(widget.userModel.uid);

                      return FutureBuilder(
                          future: FirebaseHelper.getUserModelById(
                              participantsKeys[0]),
                          builder: (context, userData) {
                            if (userData.connectionState ==
                                ConnectionState.done) {
                              if (userData.data != null) {
                                UserModel targetUser =
                                    userData.data as UserModel;

                                return ListTile(
                                  onTap: () {
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                      return ChatRoomPage(
                                          targetUser: targetUser,
                                          chatroom: chatRoomModel,
                                          userModel: widget.userModel,
                                          firebaseUser: widget.firebaseUser);
                                    }));
                                  },
                                  leading: CircleAvatar(
                                    backgroundImage: NetworkImage(
                                        targetUser.profilepic.toString()),
                                  ),
                                  title: Text(targetUser.fullname.toString()),
                                  subtitle: (chatRoomModel.lastMessage
                                              .toString() !=
                                          "")
                                      ? Text(
                                          chatRoomModel.lastMessage.toString())
                                      : Text(
                                          "Say hi to your new friend",
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondary),
                                        ),
                                );
                              } else {
                                return Container();
                              }
                            } else {
                              return Container();
                            }
                          });
                    }),
                  );
                } else if (snapshot.hasError) {
                  return Text(snapshot.error.toString());
                } else {
                  return Center(
                    child: Text("No Chats"),
                  );
                }
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return SearchPage(
              userModel: widget.userModel,
              firebaseUser: widget.firebaseUser,
              targetUser: widget.targetUser,
            );
          }));
        },
        child: Icon(Icons.search),
      ),
    );
  }
}
