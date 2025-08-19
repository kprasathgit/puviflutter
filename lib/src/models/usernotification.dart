import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:puvi/src/common/constantvalues.dart';
import 'package:puvi/src/models/user.dart';

import 'package:intl/intl.dart';
class UserNotification {
  int? id;
  String uniquekey;
  User? user; // Reference to User, can be null if only UID is sent
  String title;
  String body;
  String? type; // 'O', 'R', 'P', 'S'
  String? referenceid;
  bool seen;
  String? fcmtoken;
  DateTime? createddate;
  DateTime? createdtime;
  DateTime? updateddatetime;
  // Factory constructor for FCM message
  factory UserNotification.fromFCM(RemoteMessage message) {
    return UserNotification(
      title: message.notification?.title ?? "",
      body: message.notification?.body ?? "",
      type: message.data['type'],
      referenceid: message.data['referenceid'],
      uniquekey: message.data['uniquekey'],
      seen: false,
    );
  }
  UserNotification({
    this.id,
    required this.uniquekey,
    this.user,
    required this.title,
    required this.body,
    this.type,
    this.referenceid,
    required this.seen,
    this.fcmtoken,
    this.createddate,
    this.createdtime,
    this.updateddatetime,
  });

  UserNotification copyWith({
    int? id,
    String? uniquekey,
    User? user,
    String? title,
    String? body,
    String? type,
    String? referenceid,
    bool? seen,
    String? fcmtoken,
    DateTime? createddate,
    DateTime? createdtime,
    DateTime? updateddatetime,
  }) {
    return UserNotification(
      id: id ?? this.id,
      uniquekey: uniquekey ?? this.uniquekey,
      user: user ?? this.user,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      referenceid: referenceid ?? this.referenceid,
      seen: seen ?? this.seen,
      fcmtoken: fcmtoken ?? this.fcmtoken,
      createddate: createddate ?? this.createddate,
      createdtime: createdtime ?? this.createdtime,
      updateddatetime: updateddatetime ?? this.updateddatetime,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    if (id != null) {
      result.addAll({'id': id});
    }
    result.addAll({'uniquekey': uniquekey});
    if (user != null) {
      result.addAll({'user': user!.toMap()});
    }
    result.addAll({'title': title});
    result.addAll({'body': body});
    if (type != null) {
      result.addAll({'type': type});
    }
    if (referenceid != null) {
      result.addAll({'referenceid': referenceid});
    }
    result.addAll({'seen': seen});
    if (fcmtoken != null) {
      result.addAll({'fcmtoken': fcmtoken});
    }
    if (createddate != null) {
      result.addAll({'createddate': createddate!.millisecondsSinceEpoch});
    }
    if (createdtime != null) {
      result.addAll({'createdtime': createdtime!.millisecondsSinceEpoch});
    }
    if (updateddatetime != null) {
      result
          .addAll({'updateddatetime': updateddatetime!.millisecondsSinceEpoch});
    }

    return result;
  }

  factory UserNotification.fromMap(Map<String, dynamic> map) {
    return UserNotification(
      id: map['id']?.toInt(),
      uniquekey: map['uniquekey'] ?? '',
      user: map['user'] != null ? User.fromMap(map['user']) : null,
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      type: map['type'],
      referenceid: map['referenceid'],
      seen: map['seen'] ?? false,
      fcmtoken: map['fcmtoken'],
      createddate: getDateFromMap(map['createddate']),
      createdtime: getDateFromMap(map['createdtime']),
      updateddatetime: getDateFromMap(map['updateddatetime']),
    );
  }

  static DateTime? getDateFromMap(dynamic input) {
    try {
      if (input is Map<String, dynamic>) {
        int? year = input['year'];
        int? month = input['monthValue'];
        int? day = input['dayOfMonth'];
        int? hour = input['hour'];
        int? minute = input['minute'];
        int? second = input['second'];
        int? nano = input['nano'];

        if (year != null && month != null && day != null) {
          return DateTime(
            year,
            month,
            day,
            hour ?? 0,
            minute ?? 0,
            second ?? 0,
            (nano ?? 0) ~/ 1000,
          );
        }
      } else if (input is String) {
        if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(input.trim())) {
          return DateTime.parse(input.trim());
        }
        if (input.contains('.') && input.split('.').last.length == 9) {
          input = input.substring(0, input.lastIndexOf('.') + 7);
        }
        String fixed = fixFractionSeparator(input);
        return DateFormat(ConstantValues.dateTimeWithMicroSeconds).parse(fixed);
      } else if (input is int) {
        return DateTime.fromMillisecondsSinceEpoch(input);
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  static String fixFractionSeparator(String s) {
    final regex = RegExp(r':(?=\d{6}$)');
    if (regex.hasMatch(s)) {
      return s.replaceFirst(regex, '.');
    }
    return s;
  }

  String toJson() => json.encode(toMap());

  factory UserNotification.fromJson(String source) =>
      UserNotification.fromMap(json.decode(source));

  @override
  String toString() {
    return 'UserNotification(id: $id, uniquekey: $uniquekey, user: $user, title: $title, body: $body, type: $type, referenceid: $referenceid, seen: $seen, fcmtoken: $fcmtoken, createddate: $createddate, createdtime: $createdtime, updateddatetime: $updateddatetime)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserNotification &&
        other.id == id &&
        other.uniquekey == uniquekey &&
        other.user == user &&
        other.title == title &&
        other.body == body &&
        other.type == type &&
        other.referenceid == referenceid &&
        other.seen == seen &&
        other.fcmtoken == fcmtoken &&
        other.createddate == createddate &&
        other.createdtime == createdtime &&
        other.updateddatetime == updateddatetime;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        uniquekey.hashCode ^
        user.hashCode ^
        title.hashCode ^
        body.hashCode ^
        type.hashCode ^
        referenceid.hashCode ^
        seen.hashCode ^
        fcmtoken.hashCode ^
        createddate.hashCode ^
        createdtime.hashCode ^
        updateddatetime.hashCode;
  }
}
