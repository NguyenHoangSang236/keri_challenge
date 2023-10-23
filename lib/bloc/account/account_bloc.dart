import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:keri_challenge/core/extension/string%20_extension.dart';

import '../../data/entities/user.dart';
import '../../services/firebase_database_service.dart';

part 'account_event.dart';
part 'account_state.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  List<User> allUserList = [];
  List<User> filterUserList = [];
  List<User> paginationUserList = [];
  int page = 1;
  int limit = 10;

  AccountBloc() : super(AccountInitial()) {
    on<OnLoadAllUserListEvent>((event, emit) async {
      emit(AccountLoadingState());
      try {
        String jsonString = await FirebaseDatabaseService.get('users');

        Map<String, dynamic> jsonMap = json.decode(jsonString.formatToJson);

        allUserList = List.from(
          jsonMap.entries.map((e) => User.fromJson(e.value)),
        );

        filterUserList = allUserList;

        add(const OnLoadPaginationUserListEvent(1));

        emit(AllAccountListByNameLoadedState(allUserList));
      } catch (e, stackTrace) {
        debugPrint('Caught error: ${e.toString()} \n${stackTrace.toString()}');
        emit(AccountErrorState(e.toString()));
      }
    });

    on<OnSearchUserByNameEvent>((event, emit) async {
      emit(AccountLoadingState());
      try {
        if (allUserList.isNotEmpty) {
          page = 1;

          filterUserList = allUserList
              .where((user) => user.fullName.contains(event.userName))
              .toList();

          add(OnLoadPaginationUserListEvent(page));

          emit(AccountListByNameLoadedState(filterUserList));
        }
      } catch (e, stackTrace) {
        debugPrint('Caught error: ${e.toString()} \n${stackTrace.toString()}');
        emit(AccountErrorState(e.toString()));
      }
    });

    on<OnSearchUserByPhoneEvent>((event, emit) async {
      emit(AccountLoadingState());
      try {
        if (allUserList.isNotEmpty) {
          page = 1;

          filterUserList = allUserList
              .where((user) => user.phoneNumber.contains(event.phoneNumber))
              .toList();

          add(OnLoadPaginationUserListEvent(page));

          emit(AccountListByPhoneNumberLoadedState(filterUserList));
        }
      } catch (e, stackTrace) {
        debugPrint('Caught error: ${e.toString()} \n${stackTrace.toString()}');
        emit(AccountErrorState(e.toString()));
      }
    });

    on<OnLoadPaginationUserListEvent>((event, emit) async {
      emit(AccountLoadingState());
      try {
        if (event.page > 0) {
          page = event.page;

          paginationUserList = page * limit < filterUserList.length
              ? filterUserList.sublist(
                  (page - 1) * limit,
                  page * limit,
                )
              : filterUserList.sublist((page - 1) * limit);
        }

        emit(PaginationAccountListLoadedState(paginationUserList, page));
      } catch (e, stackTrace) {
        debugPrint('Caught error: ${e.toString()} \n${stackTrace.toString()}');
        emit(AccountErrorState(e.toString()));
      }
    });

    on<OnClearFilterUserListEvent>((event, emit) {
      filterUserList = allUserList;
      page = 1;
      paginationUserList = filterUserList.sublist(0, limit);

      emit(PaginationAccountListLoadedState(paginationUserList, page));
    });
  }

  List<User> _removeDuplicates(List<User> list) {
    Set<String> set = {};
    List<User> uniqueList =
        list.where((element) => set.add(element.fullName)).toList();

    return uniqueList;
  }
}
