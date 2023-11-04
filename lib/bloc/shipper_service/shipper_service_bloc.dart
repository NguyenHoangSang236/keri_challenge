import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:keri_challenge/data/entities/shipper_service.dart';
import 'package:keri_challenge/data/enum/shipper_service_enum.dart';

import '../../data/repository/shipper_service_repository.dart';

part 'shipper_service_event.dart';
part 'shipper_service_state.dart';

class ShipperServiceBloc
    extends Bloc<ShipperServiceEvent, ShipperServiceState> {
  final ShipperServiceRepository _shipperServiceRepository;

  ShipperService? currentShipperService;
  List<ShipperService> shipperServiceList = [];

  ShipperServiceBloc(this._shipperServiceRepository)
      : super(ShipperServiceInitial()) {
    on<OnAddNewShipperServiceEvent>((event, emit) async {
      emit(ShipperServiceLoadingState());

      try {
        final response =
            await _shipperServiceRepository.registerNewShipperService(
          event.newService,
          event.billImageFile,
        );

        response.fold(
          (failure) => emit(ShipperServiceErrorState(failure.message)),
          (success) => emit(ShipperServiceAddedState(success)),
        );
      } catch (e, stackTrace) {
        debugPrint('Caught error: ${e.toString()} \n${stackTrace.toString()}');
        emit(ShipperServiceErrorState(e.toString()));
      }
    });

    on<OnLoadHistoryShipperServiceListEvent>((event, emit) async {
      emit(ShipperServiceLoadingState());

      try {
        final response = await _shipperServiceRepository.getShipperServiceList(
          page: event.page,
          limit: event.limit,
          shipperPhoneNumber: event.shipperPhoneNumber,
        );

        response.fold(
          (failure) => emit(ShipperServiceErrorState(failure.message)),
          (list) {
            shipperServiceList = List.of(list);

            emit(ShipperServiceListLoadedState(list));
          },
        );
      } catch (e, stackTrace) {
        debugPrint('Caught error: ${e.toString()} \n${stackTrace.toString()}');
        emit(ShipperServiceErrorState(e.toString()));
      }
    });

    on<OnLoadCurrentShipperServiceEvent>((event, emit) async {
      emit(ShipperServiceLoadingState());

      try {
        final response =
            await _shipperServiceRepository.getCurrentShipperService(
                shipperPhoneNumber: event.shipperPhoneNumber);

        response.fold(
          (failure) => emit(ShipperServiceErrorState(failure.message)),
          (service) {
            currentShipperService = service;

            emit(CurrentShipperServiceLoadedState(service));
          },
        );
      } catch (e, stackTrace) {
        debugPrint('Caught error: ${e.toString()} \n${stackTrace.toString()}');
        emit(ShipperServiceErrorState(e.toString()));
      }
    });

    on<OnClearShipperServiceEvent>((event, emit) async {
      currentShipperService = null;
      shipperServiceList.clear();

      emit(ShipperServiceClearedState());
    });

    on<OnCheckExpiredCurrentShipperServiceEvent>((event, emit) async {
      emit(ShipperServiceLoadingState());

      try {
        final response =
            await _shipperServiceRepository.checkExpireCurrentShipperService(
          event.shipperPhoneNumber,
        );

        response.fold(
          (failure) => emit(ShipperServiceUnexpiredState(failure.message)),
          (success) => emit(ShipperServiceExpiredState(success)),
        );
      } catch (e, stackTrace) {
        debugPrint('Caught error: ${e.toString()} \n${stackTrace.toString()}');
        emit(ShipperServiceErrorState(e.toString()));
      }
    });

    on<OnAcceptShipperServiceEvent>((event, emit) async {
      emit(ShipperServiceLoadingState());

      try {
        final response =
            await _shipperServiceRepository.actionsOnShipperService(
          event.shipperService,
          ShipperServiceEnum.accepted,
        );

        response.fold(
          (failure) => emit(ShipperServiceErrorState(failure.message)),
          (success) => emit(ShipperServiceAcceptedState(success)),
        );
      } catch (e, stackTrace) {
        debugPrint('Caught error: ${e.toString()} \n${stackTrace.toString()}');
        emit(ShipperServiceErrorState(e.toString()));
      }
    });

    on<OnRejectShipperServiceEvent>((event, emit) async {
      emit(ShipperServiceLoadingState());

      try {
        final response =
            await _shipperServiceRepository.actionsOnShipperService(
          event.shipperService,
          ShipperServiceEnum.rejected,
        );

        response.fold(
          (failure) => emit(ShipperServiceErrorState(failure.message)),
          (success) => emit(ShipperServiceRejectedState(success)),
        );
      } catch (e, stackTrace) {
        debugPrint('Caught error: ${e.toString()} \n${stackTrace.toString()}');
        emit(ShipperServiceErrorState(e.toString()));
      }
    });
  }
}
