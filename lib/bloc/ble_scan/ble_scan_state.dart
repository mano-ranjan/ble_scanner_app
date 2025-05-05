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

  const BleScanSuccess(this.devices);

  @override
  List<Object> get props => [devices];
}

class BleScanError extends BleScanState {
  final String message;

  const BleScanError(this.message);

  @override
  List<Object> get props => [message];
}
