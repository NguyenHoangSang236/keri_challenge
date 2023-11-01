import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:keri_challenge/data/entities/shipper_service.dart';

import '../../data/repository/shipper_service_repository.dart';

part 'shipper_service_event.dart';
part 'shipper_service_state.dart';

class ShipperServiceBloc
    extends Bloc<ShipperServiceEvent, ShipperServiceState> {
  final ShipperServiceRepository _shipperServiceRepository;

  ShipperServiceBloc(this._shipperServiceRepository)
      : super(ShipperServiceInitial()) {
    on<OnAddNewShipperService>((event, emit) async {
      emit(ShipperServiceLoadingState());

      try {
        final response = await _shipperServiceRepository
            .registerNewShipperService(event.newService);

        response.fold(
          (failure) => emit(ShipperServiceErrorState(failure.message)),
          (success) => emit(ShipperServiceAddedState(success)),
        );
      } catch (e, stackTrace) {
        debugPrint('Caught error: ${e.toString()} \n${stackTrace.toString()}');
        emit(ShipperServiceErrorState(e.toString()));
      }
    });
  }
}
