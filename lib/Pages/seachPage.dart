// ignore_for_file: prefer_const_constructors, unused_local_variable, prefer_is_empty, body_might_complete_normally_nullable, unused_import, use_build_context_synchronously

import 'dart:math';

import 'package:chatapp/Models/userModel.dart';
import 'package:chatapp/Pages/chatRoomPage.dart';
import 'package:chatapp/Widgets/my_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../Models/chatRoomModel.dart';
import '../Widgets/widgets.dart';
import '../main.dart';

class SearchPage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;
  final User targetUser;

  const SearchPage({
    super.key,
    required this.userModel,
    required this.firebaseUser,
    required this.targetUser,
  });

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();

  ChatRoomModel? chatRoom;

  Future<ChatRoomModel?> getChatRoomModel(UserModel targetModel) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("chatrooms")
        .where("participants.${widget.userModel.uid}", isEqualTo: true)
        .where("participants.${widget.targetUser.uid}", isEqualTo: true)
        .get();

    if (snapshot.docs.length > 0) {
      // Fetch the existing one
      var docData = snapshot.docs[0].data();
      ChatRoomModel existingChatroom =
          ChatRoomModel.fromMap(docData as Map<String, dynamic>);

      chatRoom = existingChatroom;
    } else {
      //create a new one
      ChatRoomModel newChatroom = ChatRoomModel(
          chatroomid: uuid.v1(),
          lastMessage: "",
          participants: {
            widget.userModel.uid.toString(): true,
            widget.targetUser.uid.toString(): true,
          },
          users: [
            widget.userModel.uid.toString(),
            widget.targetUser.uid.toString(),
          ],
          createdon: DateTime.now());

      await FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(newChatroom.chatroomid)
          .set(newChatroom.toMap());

      chatRoom = newChatroom;

      log("New chatroom created!" as num);
    }
    return chatRoom;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff5ac18e),
        title: Text("Search"),
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: [
              TextFormField(
                controller: searchController,
                decoration: textInputDecoration.copyWith(
                  labelText: "Email Address",
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {});
                },
                child: Text("Search"),
                style: searchPrimary,
              ),
              SizedBox(height: 20),
              StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("users")
                    .where("email", isEqualTo: searchController.text)
                    .where("email", isNotEqualTo: widget.userModel.email)
                    .snapshots(),
                builder: (context, snapShot) {
                  if (snapShot.connectionState == ConnectionState.active) {
                    if (snapShot.hasData) {
                      QuerySnapshot dataSnapShot =
                          snapShot.data as QuerySnapshot;

                      if (dataSnapShot.docs.length > 0) {
                        Map<String, dynamic> userMap =
                            dataSnapShot.docs[0].data() as Map<String, dynamic>;

                        UserModel searchedUser = UserModel.fromMap(userMap);

                        return ListTile(
                          onTap: () async {
                            ChatRoomModel? chatroomModel =
                                await getChatRoomModel(searchedUser);

                            if (chatroomModel != null) {
                              Navigator.pop(context);
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return ChatRoomPage(
                                  targetUser: searchedUser,
                                  userModel: widget.userModel,
                                  firebaseUser: widget.firebaseUser,
                                  chatroom: chatroomModel,
                                );
                              }));
                            }
                          },
                          leading: CircleAvatar(
                            backgroundImage:
                                NetworkImage(searchedUser.profilepic!),
                            backgroundColor: Colors.grey[500],
                          ),
                          title: Text(searchedUser.fullname!),
                          subtitle: Text(searchedUser.email!),
                          trailing: Icon(Icons.keyboard_arrow_right),
                        );
                      } else {
                        return Text("No results found!");
                      }
                    } else if (snapShot.hasError) {
                      return Text("An error occurred!");
                    } else {
                      return Text("No results found!");
                    }
                  } else {
                    return CircularProgressIndicator();
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
