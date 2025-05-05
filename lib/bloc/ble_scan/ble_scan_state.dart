import 'package:equatable/equatable.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

abstract class BleScanState extends Equatable {
  const BleScanState();

  @override
  List<Object> get props => [];
}

class BleScanInitial extends BleScanState {}

class BleScanLoading extends BleScanState {}

class BleScanSuccess extends BleScanState {
  final List<ScanResult> devices;
  final Map<String, bool> connectionStates;

  const BleScanSuccess(this.devices, {this.connectionStates = const {}});

  @override
  List<Object> get props => [devices, connectionStates];
}

class BleScanError extends BleScanState {
  final String message;

  const BleScanError(this.message);

  @override
  List<Object> get props => [message];
}

class DeviceConnecting extends BleScanState {
  final BluetoothDevice device;

  const DeviceConnecting(this.device);

  @override
  List<Object> get props => [device];
}

class DeviceConnected extends BleScanState {
  final BluetoothDevice device;

  const DeviceConnected(this.device);

  @override
  List<Object> get props => [device];
}

class DeviceDisconnected extends BleScanState {
  final BluetoothDevice device;

  const DeviceDisconnected(this.device);

  @override
  List<Object> get props => [device];
}

class DeviceDetailsLoading extends BleScanState {
  final BluetoothDevice device;

  const DeviceDetailsLoading(this.device);

  @override
  List<Object> get props => [device];
}

class DeviceDetailsLoaded extends BleScanState {
  final BluetoothDevice device;
  final List<BluetoothService> services;

  const DeviceDetailsLoaded(this.device, this.services);

  @override
  List<Object> get props => [device, services];
}
