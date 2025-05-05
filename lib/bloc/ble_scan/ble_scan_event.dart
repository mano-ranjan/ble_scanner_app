import 'package:equatable/equatable.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

abstract class BleScanEvent extends Equatable {
  const BleScanEvent();

  @override
  List<Object> get props => [];
}

class StartScan extends BleScanEvent {}

class StopScan extends BleScanEvent {}

class UpdateDevices extends BleScanEvent {
  final List<dynamic> devices;

  const UpdateDevices(this.devices);

  @override
  List<Object> get props => [devices];
}

class ConnectToDevice extends BleScanEvent {
  final BluetoothDevice device;

  const ConnectToDevice(this.device);

  @override
  List<Object> get props => [device];
}

class DisconnectFromDevice extends BleScanEvent {
  final BluetoothDevice device;

  const DisconnectFromDevice(this.device);

  @override
  List<Object> get props => [device];
}

class LoadDeviceDetails extends BleScanEvent {
  final BluetoothDevice device;

  const LoadDeviceDetails(this.device);

  @override
  List<Object> get props => [device];
}
