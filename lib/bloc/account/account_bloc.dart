import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:keri_challenge/data/enum/role_enum.dart';

import '../../data/entities/user.dart';
import '../../data/repository/account_repository.dart';

part 'account_event.dart';
part 'account_state.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  final AccountRepository _accountRepository;

  List<User> clientUserList = [];
  List<User> shipperUserList = [];
  int clientListLimit = 10;
  int shipperListLimit = 10;

  AccountBloc(this._accountRepository) : super(AccountInitial()) {
    on<OnLoadUserListEvent>((event, emit) async {
      emit(AccountLoadingState());

      try {
        final response = await _accountRepository.getUserList(
          role: event.role,
          limit: event.limit,
        );

        response.fold(
          (failure) => emit(AccountErrorState(failure.message)),
          (list) {
            if (event.role == RoleEnum.client.name) {
              clientUserList = List.of(list);
              clientListLimit = event.limit;

              emit(ClientAccountListLoadedState(clientUserList));
            } else if (event.role == RoleEnum.shipper.name) {
              shipperUserList = List.of(list);
              shipperListLimit = event.limit;

              emit(ShipperAccountListLoadedState(shipperUserList));
            }
          },
        );
      } catch (e, stackTrace) {
        debugPrint('Caught error: ${e.toString()} \n${stackTrace.toString()}');
        emit(AccountErrorState(e.toString()));
      }
    });

    on<OnClearAccountEvent>((event, emit) {
      clientUserList.clear();
      shipperUserList.clear();
      clientListLimit = 10;
      shipperListLimit = 10;
    });
  }
}
