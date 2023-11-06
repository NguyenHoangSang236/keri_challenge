import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keri_challenge/util/ui_render.dart';

import '../../bloc/google_map/google_map_bloc.dart';
import '../../view/components/search_result_option.dart';

@RoutePage()
class SearchingScreen extends StatefulWidget {
  const SearchingScreen({
    super.key,
    this.isFromLocation = true,
  });

  final bool isFromLocation;

  @override
  State<StatefulWidget> createState() => _SearchingScreenState();
}

class _SearchingScreenState extends State<SearchingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () => context.router.pop(),
        ),
        backgroundColor: Colors.white,
        title: TextField(
          decoration: const InputDecoration(
            hintText: 'Tìm kiếm địa điểm...',
            border: InputBorder.none,
          ),
          onChanged: (text) {
            if (text.trim().isNotEmpty) {
              Future.delayed(
                  const Duration(
                    milliseconds: 500,
                  ), () {
                BlocProvider.of<GoogleMapBloc>(context).add(
                  OnLoadPredictionsEvent(text),
                );
              });
            }
          },
        ),
      ),
      body: BlocConsumer<GoogleMapBloc, GoogleMapState>(
        listener: (context, state) {
          if (state is GoogleMapLoadedState) {
            debugPrint(state.predictionList.first.description);
          }

          if (state is GoogleMapSearchingErrorState) {
            UiRender.showDialog(context, '', 'Lỗi tìm kiếm!');
          }
        },
        builder: (context, state) {
          if (state is GoogleMapLoadingState) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.orange,
              ),
            );
          }
          if (state is GoogleMapLoadedState) {
            return SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(10),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: state.predictionList.length,
                  itemBuilder: (context, index) {
                    return SearchResultOption(
                      prediction: state.predictionList[index],
                      isFromLocation: widget.isFromLocation,
                    );
                  },
                ),
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}
