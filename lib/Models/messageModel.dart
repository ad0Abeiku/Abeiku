// ignore_for_file: file_names

class MessageModel {
  String? messageid;
  String? sender;
  String? text;
  bool? seen;
  DateTime? createdon;

  MessageModel(
      {this.sender, this.text, this.seen, this.createdon, this.messageid});

  MessageModel.fromMap(Map<String, dynamic> map) {
    sender = map["sender"];
    text = map["text"];
    seen = map["seen"];
    createdon = map["createdon"];
    messageid = map["messagesid"];
  }

  Map<String, dynamic> toMap() {
    return {
      "sender": sender,
      "text": text,
      "seen": seen,
      "createdon": createdon,
      "messageid": messageid,
    };
  }
}
