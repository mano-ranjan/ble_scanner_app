import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'ble_scan_event.dart';
import 'ble_scan_state.dart';

class BleScanBloc extends Bloc<BleScanEvent, BleScanState> {
  StreamSubscription? _scanSubscription;

  BleScanBloc() : super(BleScanInitial()) {
    on<StartScan>(_onStartScan);
    on<StopScan>(_onStopScan);
    on<UpdateDevices>(_onUpdateDevices);
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
    emit(BleScanSuccess(event.devices as List<ScanResult>));
  }

  @override
  Future<void> close() {
    _scanSubscription?.cancel();
    return super.close();
  }
}
