import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../bloc/ble_scan/ble_scan_bloc.dart';
import '../bloc/ble_scan/ble_scan_event.dart';
import '../screens/device_details_screen.dart';

class DeviceListItem extends StatelessWidget {
  final ScanResult device;
  final bool isConnected;

  const DeviceListItem({
    super.key,
    required this.device,
    this.isConnected = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(device.device.name.isNotEmpty
          ? device.device.name
          : 'Unknown Device'),
      subtitle: Text(device.device.id.id),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('${device.rssi} dBm'),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(
              isConnected ? Icons.bluetooth_connected : Icons.bluetooth,
              color: isConnected ? Colors.blue : Colors.grey,
            ),
            onPressed: () {
              if (isConnected) {
                context
                    .read<BleScanBloc>()
                    .add(DisconnectFromDevice(device.device));
              } else {
                context.read<BleScanBloc>().add(ConnectToDevice(device.device));
              }
            },
          ),
          if (isConnected)
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlocProvider.value(
                      value: context.read<BleScanBloc>(),
                      child: DeviceDetailsScreen(device: device.device),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
      leading: const Icon(Icons.bluetooth),
    );
  }
}
