// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Chat _$ChatFromJson(Map<String, dynamic> json) => Chat(
  id: (json['id'] as num?)?.toInt() ?? 0,
  senderId: (json['senderId'] as num?)?.toInt() ?? 0,
  senderName: json['senderName'] as String?,
  senderPicture: json['senderPicture'] as String?,
  receiverId: (json['receiverId'] as num?)?.toInt() ?? 0,
  receiverName: json['receiverName'] as String?,
  receiverPicture: json['receiverPicture'] as String?,
  message: json['message'] as String? ?? '',
  createdAt: DateTime.parse(json['createdAt'] as String),
  isRead: json['isRead'] as bool? ?? false,
  readAt: json['readAt'] == null
      ? null
      : DateTime.parse(json['readAt'] as String),
);

Map<String, dynamic> _$ChatToJson(Chat instance) => <String, dynamic>{
  'id': instance.id,
  'senderId': instance.senderId,
  'senderName': instance.senderName,
  'senderPicture': instance.senderPicture,
  'receiverId': instance.receiverId,
  'receiverName': instance.receiverName,
  'receiverPicture': instance.receiverPicture,
  'message': instance.message,
  'createdAt': instance.createdAt.toIso8601String(),
  'isRead': instance.isRead,
  'readAt': instance.readAt?.toIso8601String(),
};
