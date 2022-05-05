import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

Future<String> uidFetch() async {
  var deviceInfo = DeviceInfoPlugin();

  var android_id = await _getId();
  print(android_id);
  var bytes = utf8.encode(android_id!);
  var digest = sha256.convert(bytes);
  var UID = digest.toString();
  return UID;
}

Future<String?> _getId() async {
  var deviceInfo = DeviceInfoPlugin();
  if (Platform.isIOS) {
    // import 'dart:io'
    var iosDeviceInfo = await deviceInfo.iosInfo;
    return iosDeviceInfo.identifierForVendor; // unique ID on iOS
  } else if (Platform.isAndroid) {
    var androidDeviceInfo = await deviceInfo.androidInfo;
    return androidDeviceInfo.androidId; // unique ID on Android
  }
}
