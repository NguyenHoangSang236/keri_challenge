import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:keri_challenge/bloc/account/account_bloc.dart';
import 'package:keri_challenge/core/extension/number_extension.dart';
import 'package:keri_challenge/view/components/gradient_button.dart';

import '../../data/entities/user.dart';

@RoutePage()
class AccountListScreen extends StatefulWidget {
  const AccountListScreen({super.key});

  @override
  State<StatefulWidget> createState() => _AccountListScreenState();
}

class _AccountListScreenState extends State<AccountListScreen> {
  SearchTypeEnum _searchEnum = SearchTypeEnum.name;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textEditingController = TextEditingController();

  void _onReloadPage() {
    context.read<AccountBloc>().add(OnLoadAllUserListEvent());
  }

  void _clearSearchBar() {
    setState(() {
      _textEditingController.clear();

      context.read<AccountBloc>().add(OnClearFilterUserListEvent());
    });
  }

  void _onChangeTypeSearch() {
    setState(() {
      _textEditingController.clear();

      _searchEnum = _searchEnum == SearchTypeEnum.name
          ? SearchTypeEnum.phone
          : SearchTypeEnum.name;
    });
  }

  void _searchText(String text) {
    if (text.isNotEmpty) {
      if (_searchEnum == SearchTypeEnum.name) {
        context.read<AccountBloc>().add(OnSearchUserByNameEvent(text));
      } else if (_searchEnum == SearchTypeEnum.phone) {
        context.read<AccountBloc>().add(OnSearchUserByPhoneEvent(text));
      }
    } else {
      context.read<AccountBloc>().add(OnClearFilterUserListEvent());
    }
  }

  void _onPressNextPage(int currentPage, int total) {
    if (currentPage < total) {
      context.read<AccountBloc>().add(
            OnLoadPaginationUserListEvent(currentPage + 1),
          );
    }
  }

  void _onPressPreviousPage(int currentPage) {
    if (currentPage > 1) {
      context.read<AccountBloc>().add(
            OnLoadPaginationUserListEvent(currentPage - 1),
          );
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AccountBloc>().add(OnLoadAllUserListEvent());
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 25.width,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {
            context.router.pop();
          },
        ),
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Expanded(
              flex: 7,
              child: TextField(
                controller: _textEditingController,
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 10.width,
                    vertical: 5.height,
                  ),
                  suffixIcon: SizedBox(
                    height: 7.size,
                    width: 7.size,
                    child: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: _clearSearchBar,
                    ),
                  ),
                  hintText: 'Search here...',
                  border: InputBorder.none,
                ),
                onChanged: _searchText,
              ),
            ),
            Expanded(
              flex: 3,
              child: GestureDetector(
                onTap: _onChangeTypeSearch,
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(20.radius),
                  ),
                  child: Text(_searchEnum.name),
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: RefreshIndicator(
          onRefresh: () async => _onReloadPage(),
          color: Colors.orange,
          child: Padding(
            padding: EdgeInsets.all(10.size),
            child: BlocConsumer<AccountBloc, AccountState>(
              listener: (context, state) {
                // TODO: implement listener
              },
              builder: (context, state) {
                List<User> paginationUserList =
                    context.read<AccountBloc>().paginationUserList;
                int limit = context.read<AccountBloc>().limit;
                int page = context.read<AccountBloc>().page;
                int totalPages = context
                            .read<AccountBloc>()
                            .filterUserList
                            .isEmpty &&
                        _textEditingController.text.isEmpty
                    ? (context.read<AccountBloc>().allUserList.length / limit)
                        .ceilToDouble()
                        .toInt()
                    : (context.read<AccountBloc>().filterUserList.length /
                            limit)
                        .ceilToDouble()
                        .toInt();

                if (state is AccountLoadingState) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Colors.orange,
                    ),
                  );
                } else if (state is PaginationAccountListLoadedState) {
                  paginationUserList = state.userList;
                  page = state.page;
                } else if (state is AccountListByNameLoadedState) {
                  totalPages =
                      (state.userList.length / limit).ceilToDouble().toInt();
                } else if (state is AccountListByPhoneNumberLoadedState) {
                  totalPages =
                      (state.userList.length / limit).ceilToDouble().toInt();
                }

                return Column(
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: paginationUserList.length,
                      itemBuilder: (context, index) {
                        return _userComponent(paginationUserList[index]);
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GradientElevatedButton(
                          text: 'Previous',
                          buttonMargin: EdgeInsets.zero,
                          buttonWidth: 120.width,
                          onPress: () => _onPressPreviousPage(page),
                        ),
                        Text(
                          'Page $page/$totalPages',
                        ),
                        GradientElevatedButton(
                          text: 'Next',
                          buttonMargin: EdgeInsets.zero,
                          buttonWidth: 120.width,
                          onPress: () => _onPressNextPage(page, totalPages),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _userComponent(User user) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.height),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('User: ${user.fullName}'),
          5.verticalSpace,
          Text('Phone number: ${user.phoneNumber}'),
        ],
      ),
    );
  }
}

enum SearchTypeEnum {
  phone,
  name,
}
