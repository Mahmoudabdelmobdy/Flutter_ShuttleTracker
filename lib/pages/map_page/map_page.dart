import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/widgets.dart';

import '../../blocs/shuttle/shuttle_bloc.dart';
import '../../blocs/theme/theme_bloc.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/loading_state.dart';
import 'states/error_map.dart';
import 'states/initial_map.dart';
import 'states/loaded_map.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  int i = 0;

  @override
  Widget build(BuildContext context) {
    var shuttleBloc = context.bloc<ShuttleBloc>();
    return BlocBuilder<ThemeBloc, ThemeState>(builder: (context, theme) {
      return Scaffold(
        appBar: PreferredSize(
            preferredSize:
                Size.fromHeight(MediaQuery.of(context).size.width * 0.115),
            child: CustomAppBar(
              pageName: 'Map',
            )),
        body: Center(
          child:
              BlocBuilder<ShuttleBloc, ShuttleState>(builder: (context, state) {
            if (state is ShuttleInitial) {
              shuttleBloc.add(ShuttleEvent.getShuttleMap);
              print('state is initial');
              return InitialMap();
            } else if (state is ShuttleError) {
              shuttleBloc.add(ShuttleEvent.getShuttleMap);
              print('state has error\n\n');
              return ErrorMap(
                message: state.message,
              );
            } else if (state is ShuttleLoaded) {
              print('state is loaded');
              i++;
              print('API poll $i\n\n');
              shuttleBloc.add(ShuttleEvent.getShuttleMap);
              return LoadedMap(
                  routes: state.routes,
                  location: state.location,
                  stops: state.stops,
                  updates: state.updates,
                  theme: theme.getTheme);
            }
            print('state is loading');
            return LoadingState(theme: theme.getTheme);
          }),
        ),
      );
    });
  }
}
