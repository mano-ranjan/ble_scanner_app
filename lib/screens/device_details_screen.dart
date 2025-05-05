import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../bloc/ble_scan/ble_scan_bloc.dart';
import '../bloc/ble_scan/ble_scan_event.dart';
import '../bloc/ble_scan/ble_scan_state.dart';
import 'dart:convert';

class DeviceDetailsScreen extends StatefulWidget {
  final BluetoothDevice device;

  const DeviceDetailsScreen({super.key, required this.device});

  @override
  State<DeviceDetailsScreen> createState() => _DeviceDetailsScreenState();
}

class _DeviceDetailsScreenState extends State<DeviceDetailsScreen> {
  @override
  void initState() {
    super.initState();
    // Load device details when screen opens
    context.read<BleScanBloc>().add(LoadDeviceDetails(widget.device));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.device.platformName.isNotEmpty
            ? widget.device.platformName
            : 'Device Details'),
        actions: [
          BlocBuilder<BleScanBloc, BleScanState>(
            builder: (context, state) {
              return IconButton(
                icon: state is DeviceDetailsLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
                onPressed: state is DeviceDetailsLoading
                    ? null
                    : () {
                        context
                            .read<BleScanBloc>()
                            .add(LoadDeviceDetails(widget.device));
                      },
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<BleScanBloc, BleScanState>(
        builder: (context, state) {
          if (state is DeviceDetailsLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is DeviceDetailsLoaded) {
            return ListView.builder(
              itemCount: state.services.length,
              itemBuilder: (context, index) {
                final service = state.services[index];
                return ExpansionTile(
                  title: Text('Service: ${service.uuid}'),
                  children: service.characteristics.map((characteristic) {
                    return ListTile(
                      title: Text('Characteristic: ${characteristic.uuid}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              'Properties: ${_getCharacteristicProperties(characteristic)}'),
                          StreamBuilder<List<int>>(
                            stream: characteristic.lastValueStream,
                            builder: (context, snapshot) {
                              if (snapshot.hasData &&
                                  snapshot.data!.isNotEmpty) {
                                return Text('Value: ${snapshot.data}');
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (characteristic.properties.read)
                            IconButton(
                              icon: const Icon(Icons.info_outline),
                              onPressed: () async {
                                try {
                                  await characteristic.read();
                                  final bytes = characteristic.lastValue;
                                  final decoded = utf8.decode(bytes);
                                  // Show popup dialog instead of snackbar
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Characteristic Value'),
                                      content: Text(decoded),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                          child: const Text('OK'),
                                        ),
                                      ],
                                    ),
                                  );
                                } catch (e) {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Error'),
                                      content: Text('Failed to read: $e'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                          child: const Text('OK'),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              },
                            ),
                          if (characteristic.properties.write)
                            IconButton(
                              icon: const Icon(Icons.upload),
                              onPressed: () {
                                // TODO: Implement write characteristic
                              },
                            ),
                          if (characteristic.properties.notify)
                            IconButton(
                              icon: const Icon(Icons.notifications),
                              onPressed: () {
                                // TODO: Implement notify characteristic
                              },
                            ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            );
          }

          return const Center(
            child: Text('No device details available'),
          );
        },
      ),
    );
  }

  String _getCharacteristicProperties(BluetoothCharacteristic characteristic) {
    final properties = <String>[];
    if (characteristic.properties.read) properties.add('Read');
    if (characteristic.properties.write) properties.add('Write');
    if (characteristic.properties.writeWithoutResponse)
      properties.add('Write Without Response');
    if (characteristic.properties.notify) properties.add('Notify');
    if (characteristic.properties.indicate) properties.add('Indicate');
    return properties.join(', ');
  }
}
