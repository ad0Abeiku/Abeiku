// ignore_for_file: prefer_const_constructors, avoid_unnecessary_containers, unused_local_variable, sort_child_properties_last

import 'dart:developer';

import 'package:chatapp/Models/chatRoomModel.dart';
import 'package:chatapp/Models/messageModel.dart';
import 'package:chatapp/Models/userModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../main.dart';

class ChatRoomPage extends StatefulWidget {
  final UserModel targetUser;
  final ChatRoomModel chatroom;
  final UserModel userModel;
  final User firebaseUser;
  const ChatRoomPage(
      {super.key,
      required this.targetUser,
      required this.chatroom,
      required this.userModel,
      required this.firebaseUser});

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  TextEditingController messageController = TextEditingController();

  void sendMessage() async {
    String msg = messageController.text.trim();
    messageController.clear();

    if (msg != "") {
      //Send message
      MessageModel newMessage = MessageModel(
        messageid: uuid.v1(),
        sender: widget.userModel.uid,
        createdon: DateTime.now(),
        text: msg,
        seen: false,
      );

      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatroom.chatroomid)
          .collection("messages")
          .doc(newMessage.messageid)
          .set(newMessage.toMap());

      widget.chatroom.lastMessage = msg;
      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatroom.chatroomid)
          .collection("messages")
          .doc(newMessage.messageid)
          .set(newMessage.toMap());

      log("Message Sent!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff5ac18e),
        title: Row(children: [
          CircleAvatar(
            backgroundColor: Colors.grey[300],
            backgroundImage:
                NetworkImage(widget.targetUser.profilepic.toString()),
          ),
          SizedBox(width: 10),
          Text(widget.targetUser.fullname.toString()),
        ]),
      ),
      body: SafeArea(
        child: Container(
          child: Column(children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("chatrooms")
                      .doc(widget.chatroom.chatroomid)
                      .collection("messages")
                      .orderBy("createdon", descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.active) {
                      if (snapshot.hasData) {
                        QuerySnapshot dataSnapshot =
                            snapshot.data as QuerySnapshot;

                        return ListView.builder(
                          reverse: true,
                          itemCount: dataSnapshot.docs.length,
                          itemBuilder: ((context, index) {
                            MessageModel currentMessage = MessageModel.fromMap(
                                dataSnapshot.docs[index].data()
                                    as Map<String, dynamic>);

                            return Row(
                              mainAxisAlignment: (currentMessage.sender ==
                                      widget.userModel.uid)
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                              children: [
                                Container(
                                    margin: EdgeInsets.symmetric(vertical: 2),
                                    padding: EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 10),
                                    decoration: BoxDecoration(
                                        color: (currentMessage.sender ==
                                                widget.userModel.uid)
                                            ? Color(0xff5ac18e)
                                            : Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                        borderRadius: BorderRadius.circular(5)),
                                    child: Text(
                                      currentMessage.text.toString(),
                                      style: TextStyle(color: Colors.white),
                                    )),
                              ],
                            );
                          }),
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text(
                              "An error occurred please check your internet connection"),
                        );
                      } else {
                        return Center(
                          child: Text("Say hi to your new friend"),
                        );
                      }
                    } else {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                ),
                color: Colors.grey[500],
              ),
            ),
            Container(
              child: Row(
                children: [
                  Flexible(
                    child: TextField(
                      maxLines: null,
                      controller: messageController,
                      decoration: InputDecoration(
                        hintText: "Enter Message",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      sendMessage();
                    },
                    icon: Icon(
                      Icons.send,
                      color: Color(0xff5ac18e),
                    ),
                  )
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
