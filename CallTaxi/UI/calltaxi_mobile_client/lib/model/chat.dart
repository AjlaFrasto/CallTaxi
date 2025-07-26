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
    this.id = 0,
    this.senderId = 0,
    this.senderName,
    this.senderPicture,
    this.receiverId = 0,
    this.receiverName,
    this.receiverPicture,
    this.message = '',
    required this.createdAt,
    this.isRead = false,
    this.readAt,
  });

  factory Chat.fromJson(Map<String, dynamic> json) => _$ChatFromJson(json);
  Map<String, dynamic> toJson() => _$ChatToJson(this);
}
