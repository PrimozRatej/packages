// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
// Autogenerated from Pigeon (v11.0.1), do not edit directly.
// See also: https://pub.dev/packages/pigeon
// ignore_for_file: public_member_api_docs, non_constant_identifier_names, avoid_as, unused_import, unnecessary_parenthesis, prefer_null_aware_operators, omit_local_variable_types, unused_shown_name, unnecessary_import

import 'dart:async';
import 'dart:typed_data' show Float64List, Int32List, Int64List, Uint8List;

import 'package:flutter/foundation.dart' show ReadBuffer, WriteBuffer;
import 'package:flutter/services.dart';

/// Home screen quick-action shortcut item.
class ShortcutItemMessage {
  ShortcutItemMessage({
    required this.type,
    required this.localizedTitle,
    this.icon,
    this.base64Icon,
  });

  /// The identifier of this item; should be unique within the app.
  String type;

  /// Localized title of the item.
  String localizedTitle;

  /// Name of native resource to be displayed as the icon for this item.
  String? icon;

  /// Name of native resource to be displayed as the icon for this item.
  String? base64Icon;


  Object encode() {
    return <Object?>[
      type,
      localizedTitle,
      icon,
      base64Icon,
    ];
  }

  static ShortcutItemMessage decode(Object result) {
    result as List<Object?>;
    return ShortcutItemMessage(
      type: result[0]! as String,
      localizedTitle: result[1]! as String,
      icon: result[2] as String?,
      base64Icon: result[3] as String?,
    );
  }
}

class _AndroidQuickActionsApiCodec extends StandardMessageCodec {
  const _AndroidQuickActionsApiCodec();
  @override
  void writeValue(WriteBuffer buffer, Object? value) {
    if (value is ShortcutItemMessage) {
      buffer.putUint8(128);
      writeValue(buffer, value.encode());
    } else {
      super.writeValue(buffer, value);
    }
  }

  @override
  Object? readValueOfType(int type, ReadBuffer buffer) {
    switch (type) {
      case 128:
        return ShortcutItemMessage.decode(readValue(buffer)!);
      default:
        return super.readValueOfType(type, buffer);
    }
  }
}

class AndroidQuickActionsApi {
  /// Constructor for [AndroidQuickActionsApi].  The [binaryMessenger] named argument is
  /// available for dependency injection.  If it is left null, the default
  /// BinaryMessenger will be used which routes to the host platform.
  AndroidQuickActionsApi({BinaryMessenger? binaryMessenger})
      : _binaryMessenger = binaryMessenger;
  final BinaryMessenger? _binaryMessenger;

  static const MessageCodec<Object?> codec = _AndroidQuickActionsApiCodec();

  /// Checks for, and returns the action that launched the app.
  Future<String?> getLaunchAction() async {
    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        'dev.flutter.pigeon.quick_actions_android.AndroidQuickActionsApi.getLaunchAction',
        codec,
        binaryMessenger: _binaryMessenger);
    final List<Object?>? replyList = await channel.send(null) as List<Object?>?;
    if (replyList == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on channel.',
      );
    } else if (replyList.length > 1) {
      throw PlatformException(
        code: replyList[0]! as String,
        message: replyList[1] as String?,
        details: replyList[2],
      );
    } else {
      return (replyList[0] as String?);
    }
  }

  /// Sets the dynamic shortcuts for the app.
  Future<void> setShortcutItems(
      List<ShortcutItemMessage?> arg_itemsList) async {
    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        'dev.flutter.pigeon.quick_actions_android.AndroidQuickActionsApi.setShortcutItems',
        codec,
        binaryMessenger: _binaryMessenger);
    final List<Object?>? replyList =
        await channel.send(<Object?>[arg_itemsList]) as List<Object?>?;
    if (replyList == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on channel.',
      );
    } else if (replyList.length > 1) {
      throw PlatformException(
        code: replyList[0]! as String,
        message: replyList[1] as String?,
        details: replyList[2],
      );
    } else {
      return;
    }
  }

  /// Removes all dynamic shortcuts.
  Future<void> clearShortcutItems() async {
    final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
        'dev.flutter.pigeon.quick_actions_android.AndroidQuickActionsApi.clearShortcutItems',
        codec,
        binaryMessenger: _binaryMessenger);
    final List<Object?>? replyList = await channel.send(null) as List<Object?>?;
    if (replyList == null) {
      throw PlatformException(
        code: 'channel-error',
        message: 'Unable to establish connection on channel.',
      );
    } else if (replyList.length > 1) {
      throw PlatformException(
        code: replyList[0]! as String,
        message: replyList[1] as String?,
        details: replyList[2],
      );
    } else {
      return;
    }
  }
}

abstract class AndroidQuickActionsFlutterApi {
  static const MessageCodec<Object?> codec = StandardMessageCodec();

  /// Sends a string representing a shortcut from the native platform to the app.
  void launchAction(String action);

  static void setup(AndroidQuickActionsFlutterApi? api,
      {BinaryMessenger? binaryMessenger}) {
    {
      final BasicMessageChannel<Object?> channel = BasicMessageChannel<Object?>(
          'dev.flutter.pigeon.quick_actions_android.AndroidQuickActionsFlutterApi.launchAction',
          codec,
          binaryMessenger: binaryMessenger);
      if (api == null) {
        channel.setMessageHandler(null);
      } else {
        channel.setMessageHandler((Object? message) async {
          assert(message != null,
              'Argument for dev.flutter.pigeon.quick_actions_android.AndroidQuickActionsFlutterApi.launchAction was null.');
          final List<Object?> args = (message as List<Object?>?)!;
          final String? arg_action = (args[0] as String?);
          assert(arg_action != null,
              'Argument for dev.flutter.pigeon.quick_actions_android.AndroidQuickActionsFlutterApi.launchAction was null, expected non-null String.');
          api.launchAction(arg_action!);
          return;
        });
      }
    }
  }
}
