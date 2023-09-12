// ignore_for_file: file_names
class ChatRoomModel {
  String? chatroomid;
  Map<String, dynamic>? participants;
  String? lastMessage;
  List<dynamic>? users;
  DateTime? createdon;

  ChatRoomModel({
    this.chatroomid,
    this.participants,
    required String lastMessage,
    this.users,
    this.createdon,
  });

  ChatRoomModel.fromMap(Map<String, dynamic> map) {
    chatroomid = map["chatroomid"];
    participants = map["participants"];
    lastMessage = map["lastMessage"];
    users = map["users"];
    createdon = map["createdon"].toDate();
  }

  Map<String, dynamic> toMap() {
    return {
      "chatroomid": chatroomid,
      "participants": participants,
      "lastMessage": lastMessage,
      "users": users,
      "createdon": createdon,
    };
  }
}
