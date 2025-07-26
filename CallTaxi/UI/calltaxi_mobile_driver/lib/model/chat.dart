import 'package:json_annotation/json_annotation.dart';

part 'chat.g.dart';

@JsonSerializable()
class Chat {
  final int id;
  final int senderId;
  final String? senderName;
  final String? senderPicture;
  final int receiverId;
  final String? receiverName;
  final String? receiverPicture;
  final String message;
  final DateTime createdAt;
  final bool isRead;
  final DateTime? readAt;

  Chat({
    required this.id,
    required this.senderId,
    this.senderName,
    this.senderPicture,
    required this.receiverId,
    this.receiverName,
    this.receiverPicture,
    required this.message,
    required this.createdAt,
    required this.isRead,
    this.readAt,
  });

  factory Chat.fromJson(Map<String, dynamic> json) => _$ChatFromJson(json);
  Map<String, dynamic> toJson() => _$ChatToJson(this);
}
