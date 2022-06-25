import 'package:flutter_bloc/flutter_bloc.dart';

class BluetoothConnectionCubit extends Cubit<BluetoothConnectionState> {
  BluetoothConnectionCubit()
      : super(const BluetoothConnectionState.initialState());
}

class BluetoothConnectionState {
  const BluetoothConnectionState.initialState();
}
