import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:show_network_interface_info/model/NetworkDevice.dart';

class ShowNetworkInterfaceInfo {
  static const MethodChannel _channel =
      MethodChannel('show_network_interface_info');

  static Future<List<NetworkDevice>> getNetWorkInfo() async {
    if (Platform.isAndroid) {
      final netList = (await getAllNetWorkInfo());
      if (null != netList) {
        final relist = <NetworkDevice>[];
        for (final item in netList) {
          relist.add(NetworkDevice(
            index: relist.length,
            networkInfoList: item.toNetworkInfoList(),
          ));
        }
        return relist;
      }
    }
    final getNetWorkInfo = await _channel.invokeMethod('getNetWorkInfo');
    return (getNetWorkInfo as List<Object?>)
        .map((e) => NetworkDevice.fromMap(e as Map))
        .toList();
  }

  static Future<List<CommonNetworkInfo_c>?> getAllNetWorkInfo() async {
    if (false == Platform.isAndroid) {
      return null;
    }
    try {
      final getNetWorkInfo = await _channel.invokeMethod('getAllNetWorkInfo');
      if (getNetWorkInfo is List) {
        final relist = <CommonNetworkInfo_c>[];
        for (final item in getNetWorkInfo) {
          final data = CommonNetworkInfo_c.fromJson(item);
          relist.add(data);
        }
        return relist;
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return null;
    // return (getNetWorkInfo as List<Object?>)
    //     .map((e) => NetworkDevice.fromMap(e as Map))
    //     .toList();
  }
}

/**
    [
      {index: 1, networkInfoList: [{gateway: 0.0.0.0, ip: 0.0.0.0, ipMask: 0.0.0.0}]},
      {index: 2, networkInfoList: [{gateway: 0.0.0.0, ip: 169.254.52.70, ipMask: 255.255.0.0}]},
      {index: 3, networkInfoList: [{gateway: 0.0.0.0, ip: 169.254.114.12, ipMask: 255.255.0.0}]},
      {index: 4, networkInfoList: [{gateway: 172.16.5.254, ip: 172.16.5.107, ipMask: 255.255.255.0}]},
      {index: 5, networkInfoList: [{gateway: 0.0.0.0, ip: 0.0.0.0, ipMask: 0.0.0.0}]},
      {index: 6, networkInfoList: [{gateway: 0.0.0.0, ip: 0.0.0.0, ipMask: 0.0.0.0}]}
    ]
*/