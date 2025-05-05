import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class DeviceListItem extends StatelessWidget {
  final ScanResult device;

  const DeviceListItem({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(device.device.name.isNotEmpty
          ? device.device.name
          : 'Unknown Device'),
      subtitle: Text(device.device.id.id),
      trailing: Text('${device.rssi} dBm'),
      leading: const Icon(Icons.bluetooth),
    );
  }
}
