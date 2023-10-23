import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
          onPressed: () {
            context.router.pop();
          },
        ),
        backgroundColor: Colors.white,
        title: TextField(
          decoration: const InputDecoration(
            hintText: 'Search your location...',
            border: InputBorder.none,
          ),
          onChanged: (text) {
            if (text.isNotEmpty) {
              BlocProvider.of<GoogleMapBloc>(context).add(
                OnLoadPredictionsEvent(text),
              );
            }
          },
        ),
      ),
      body: BlocConsumer<GoogleMapBloc, GoogleMapState>(
        listener: (context, state) {
          if (state is GoogleMapLoadingState) {
            // Navigator.pop(context);
            print('loading');
          }

          if (state is GoogleMapLoadedState) {
            print(state.predictionList.first?.description);
          }

          if (state is GoogleMapErrorState) {
            print(state.message);
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
