import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../bloc/ble_scan/ble_scan_bloc.dart';
import '../bloc/ble_scan/ble_scan_event.dart';
import '../bloc/ble_scan/ble_scan_state.dart';

class DeviceDetailsScreen extends StatelessWidget {
  final BluetoothDevice device;

  const DeviceDetailsScreen({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(device.platformName.isNotEmpty
            ? device.platformName
            : 'Device Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<BleScanBloc>().add(LoadDeviceDetails(device));
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
                              icon: const Icon(Icons.download),
                              onPressed: () {
                                // TODO: Implement read characteristic
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
