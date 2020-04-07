import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_shuttletracker/bloc/shuttle_bloc.dart';
import 'package:flutter_shuttletracker/widgets/states.dart';

class MapPage extends StatefulWidget {
  MapPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child:
            BlocBuilder<ShuttleBloc, ShuttleState>(builder: (context, state) {
          if (state is ShuttleInitial) {
            print('state is initial');
            BlocProvider.of<ShuttleBloc>(context).add(GetShuttleMap());
            return buildInitialState();
          } else if (state is ShuttleError) {
            print('state has error');
            return buildErrorState(state.message);
          } else if (state is ShuttleLoaded) {
            print('state is loaded');
            return buildLoadedState(state.routes, state.location, state.stops,
                state.updates, state.mapkey);
          }
          print('state is loading');
          return buildLoadingState();
        }),
      ),
    );
  }
}