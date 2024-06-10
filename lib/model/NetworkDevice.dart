// ignore_for_file: file_names

import 'dart:io';
import 'dart:typed_data';

class NetworkDevice {
  late int index;
  late List<NetworkInfo> networkInfoList;

  NetworkDevice({
    required this.index,
    required this.networkInfoList,
  });

  NetworkDevice.fromMap(Map mapContent) {
    index = mapContent["index"];
    networkInfoList = (mapContent["networkInfoList"] as List<Object?>)
        .map((e) => NetworkInfo.fromMap(e as Map))
        .toList();
  }
}

class NetworkInfo {
  late String gateway;
  late String ip;
  late String ipMask;
  late String name;

  NetworkInfo({
    required this.gateway,
    required this.ip,
    required this.ipMask,
    required this.name,
  });

  NetworkInfo.fromMap(Map mapContent) {
    gateway = mapContent["gateway"];
    ip = mapContent["ip"];
    ipMask = mapContent["ipMask"];
    name = mapContent["name"];
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

class CommonNetworkAddress_c {
  late String address;
  late int networkPrefixLength;

  CommonNetworkAddress_c.fromJson(Map<dynamic, dynamic> data) {
    address = data["address"] ?? "";
    networkPrefixLength = data["networkPrefixLength"] ?? 0;
  }
}

class CommonNetworkInfo_c {
  late String name;
  late String displayName;
  late bool isUp;
  late bool isLoopback;
  late bool isPointToPoint;
  late bool supportsMulticast;
  final addressList = <CommonNetworkAddress_c>[];

  CommonNetworkInfo_c.fromJson(Map<dynamic, dynamic> data) {
    name = data["name"] ?? "";
    displayName = data["displayName"] ?? "";
    isUp = data["isUp"] ?? false;
    isLoopback = data["isLoopback"] ?? false;
    isPointToPoint = data["isPointToPoint"] ?? false;
    supportsMulticast = data["supportsMulticast"] ?? false;

    final addrlist = data["addressList"];
    if (addrlist is List) {
      for (final addr in addrlist) {
        final item = CommonNetworkAddress_c.fromJson(addr);
        addressList.add(item);
      }
    }
  }

  List<NetworkInfo> toNetworkInfoList() {
    final relist = <NetworkInfo>[];
    print(addressList.length);
    for (final item in addressList) {
      if (item.networkPrefixLength <= 0) {
        continue;
      }
      final rawAddr = InternetAddress.tryParse(item.address)?.rawAddress;
      if (null == rawAddr) {
        continue;
      }
      for (int i = 0, j = item.networkPrefixLength; i < rawAddr.length; ++i) {
        if (j >= 8) {
          j -= 8;
        } else {
          final sub = 8 - j;
          rawAddr[i] = (rawAddr[i] >> sub) << sub; // 置零低[sub]个比特位
          j = 0;
        }
      }
      relist.add(NetworkInfo(
        name: name,
        gateway: "",
        ip: item.address,
        ipMask: InternetAddress.fromRawAddress(
          Uint8List.fromList(rawAddr),
        ).address,
      ));
    }
    return relist;
  }
}
