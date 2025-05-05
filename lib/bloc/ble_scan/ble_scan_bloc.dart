import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'ble_scan_event.dart';
import 'ble_scan_state.dart';

class BleScanBloc extends Bloc<BleScanEvent, BleScanState> {
  StreamSubscription? _scanSubscription;
  StreamSubscription? _connectionSubscription;
  Map<String, bool> _connectionStates = {};

  BleScanBloc() : super(BleScanInitial()) {
    on<StartScan>(_onStartScan);
    on<StopScan>(_onStopScan);
    on<UpdateDevices>(_onUpdateDevices);
    on<ConnectToDevice>(_onConnectToDevice);
    on<DisconnectFromDevice>(_onDisconnectFromDevice);
    on<LoadDeviceDetails>(_onLoadDeviceDetails);
  }

  Future<void> _onStartScan(StartScan event, Emitter<BleScanState> emit) async {
    try {
      emit(BleScanLoading());

      // Check if Bluetooth is available and turned on
      if (await FlutterBluePlus.isAvailable == false) {
        emit(const BleScanError('Bluetooth is not available on this device'));
        return;
      }

      if (await FlutterBluePlus.isOn == false) {
        emit(const BleScanError('Bluetooth is turned off'));
        return;
      }

      // Start scanning
      FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));

      _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
        add(UpdateDevices(results));
      });
    } catch (e) {
      emit(BleScanError(e.toString()));
    }
  }

  void _onStopScan(StopScan event, Emitter<BleScanState> emit) {
    _scanSubscription?.cancel();
    FlutterBluePlus.stopScan();
  }

  void _onUpdateDevices(UpdateDevices event, Emitter<BleScanState> emit) {
    if (state is DeviceDetailsLoaded) {
      final currentState = state as DeviceDetailsLoaded;
      emit(DeviceDetailsLoaded(currentState.device, currentState.services));
      return;
    }

    emit(BleScanSuccess(event.devices as List<ScanResult>,
        connectionStates: _connectionStates));
  }

  Future<void> _onConnectToDevice(
      ConnectToDevice event, Emitter<BleScanState> emit) async {
    try {
      // Cancel any existing connection subscription
      await _connectionSubscription?.cancel();

      // Emit connecting state
      emit(DeviceConnecting(event.device));

      // Listen to connection state changes
      _connectionSubscription =
          event.device.connectionState.listen((state) async {
        if (state == BluetoothConnectionState.connected) {
          _connectionStates[event.device.remoteId.str] = true;
          add(LoadDeviceDetails(event.device));
        } else if (state == BluetoothConnectionState.disconnected) {
          _connectionStates[event.device.remoteId.str] = false;
          if (this.state is BleScanSuccess) {
            final currentState = this.state as BleScanSuccess;
            emit(BleScanSuccess(currentState.devices,
                connectionStates: _connectionStates));
          }
        }
      });

      // Attempt connection
      await event.device.connect(
        timeout: const Duration(seconds: 4),
        autoConnect: false,
      );
    } catch (e) {
      _connectionStates[event.device.remoteId.str] = false;
      emit(BleScanError('Failed to connect: ${e.toString()}'));
    }
  }

  Future<void> _onDisconnectFromDevice(
      DisconnectFromDevice event, Emitter<BleScanState> emit) async {
    try {
      await event.device.disconnect();
      _connectionStates[event.device.remoteId.str] = false;

      if (state is BleScanSuccess) {
        final currentState = state as BleScanSuccess;
        emit(BleScanSuccess(currentState.devices,
            connectionStates: _connectionStates));
      }
    } catch (e) {
      emit(BleScanError('Failed to disconnect: ${e.toString()}'));
    }
  }

  Future<void> _onLoadDeviceDetails(
      LoadDeviceDetails event, Emitter<BleScanState> emit) async {
    try {
      emit(DeviceDetailsLoading(event.device));

      // Discover services
      List<BluetoothService> services = await event.device.discoverServices();
      emit(DeviceDetailsLoaded(event.device, services));

      // Update device list with connection state
      if (state is BleScanSuccess) {
        final currentState = state as BleScanSuccess;
        emit(BleScanSuccess(currentState.devices,
            connectionStates: _connectionStates));
      }
    } catch (e) {
      emit(BleScanError('Failed to load device details: ${e.toString()}'));
    }
  }

  @override
  Future<void> close() {
    _scanSubscription?.cancel();
    _connectionSubscription?.cancel();
    return super.close();
  }
}
