import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'bloc/ble_scan/ble_scan_bloc.dart';
import 'bloc/ble_scan/ble_scan_event.dart';
import 'bloc/ble_scan/ble_scan_state.dart';
import 'widgets/device_list_item.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BleScanBloc(),
      child: MaterialApp(
        title: 'BLE Scanner',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const MyHomePage(title: 'BLE Scanner'),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: BlocBuilder<BleScanBloc, BleScanState>(
        builder: (context, state) {
          if (state is BleScanInitial) {
            return const Center(
              child: Text('Press the scan button to start scanning'),
            );
          }

          if (state is BleScanLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is DeviceConnected) {
            // After successful connection, return to the device list
            context.read<BleScanBloc>().add(StartScan());
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is DeviceConnecting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text('Connecting to ${state.device.platformName}...'),
                ],
              ),
            );
          }

          if (state is BleScanSuccess) {
            if (state.devices.isEmpty) {
              return const Center(
                child: Text('No devices found'),
              );
            }

            return ListView.builder(
              itemCount: state.devices.length,
              itemBuilder: (context, index) {
                final device = state.devices[index];
                final isConnected =
                    state.connectionStates[device.device.remoteId.str] ?? false;
                return DeviceListItem(
                  device: device,
                  isConnected: isConnected,
                );
              },
            );
          }

          if (state is BleScanError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    state.message,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<BleScanBloc>().add(StartScan());
                    },
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: BlocBuilder<BleScanBloc, BleScanState>(
        builder: (context, state) {
          return FloatingActionButton(
            onPressed: () {
              if (state is BleScanLoading) {
                context.read<BleScanBloc>().add(StopScan());
              } else {
                context.read<BleScanBloc>().add(StartScan());
              }
            },
            tooltip: state is BleScanLoading ? 'Stop Scan' : 'Start Scan',
            child: Icon(state is BleScanLoading ? Icons.stop : Icons.search),
          );
        },
      ),
    );
  }
}
