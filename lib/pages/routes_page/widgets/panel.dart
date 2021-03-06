import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:latlong/latlong.dart';

import '../../../blocs/on_tap/on_tap_bloc.dart';
import '../../../blocs/theme/theme_bloc.dart';
import '../../../models/shuttle_stop.dart';
import 'shuttle_line.dart';

class Panel extends StatefulWidget {
  final Color routeColor;
  final Map<int, ShuttleStop> routeStops;
  final MapCallback animate;
  final OnTapBloc bloc;
  Panel({this.routeColor, this.routeStops, this.animate, this.bloc});

  @override
  _PanelState createState() => _PanelState();
}

class _PanelState extends State<Panel> {
  String selectedName;
  ItemScrollController scrollController = ItemScrollController();

  List<Widget> _getStopTileList(ThemeData theme) {
    var tileList = <Widget>[];

    widget.routeStops.forEach((key, value) {
      var tileSelected = selectedName != null && selectedName == value.name;
      var tileTextColor = theme.brightness == Brightness.dark
          ? Colors.white
          : Colors.green[600];
      var tileColor = tileSelected
          ? theme.brightness == Brightness.dark
              ? Colors.white.withOpacity(0.1)
              : Colors.green.withOpacity(0.1)
          : theme.backgroundColor;
      tileList.add(
        IntrinsicHeight(
          child: ListTileTheme(
            selectedColor: tileTextColor,
            child: ListTile(
              dense: true,
              selected: tileSelected ? true : false,
              title: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  ShuttleLine(
                    routeColor: widget.routeColor,
                    isSelected: tileSelected,
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: tileColor,
                        borderRadius: BorderRadius.circular(16.0),
                        shape: BoxShape.rectangle,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          value.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              onTap: () {
                widget.bloc.add(TileStopTapped(stopName: value.name));
                widget.animate(value.getLatLng, 15.2);
              },
            ),
          ),
        ),
      );
    });
    return tileList;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(builder: (context, theme) {
      return MediaQuery.removePadding(
        context: context,
        removeTop: true,
        //notification listener used to remove scroll glow
        child: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (overscroll) {
            overscroll.disallowGlow();
            return null;
          },
          child: BlocBuilder<OnTapBloc, OnTapState>(
              cubit: widget.bloc,
              builder: (context, state) {
                if (state is TappedState) {
                  selectedName = state.stopName;
                  if (state.index != null && scrollController.isAttached) {
                    scrollController.scrollTo(
                        index: state.index,
                        duration: Duration(milliseconds: 250));
                  }
                }
                var _stopTileList = _getStopTileList(theme.getTheme);
                return Container(
                  color: theme.getTheme.backgroundColor,
                  child: _stopTileList.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ScrollablePositionedList.builder(
                            physics: ClampingScrollPhysics(),
                            itemScrollController: scrollController,
                            itemCount: _stopTileList.length,
                            itemBuilder: (context, index) =>
                                _stopTileList[index],
                          ),
                        )
                      : Center(
                          child: Text(
                            'No stops to show',
                          ),
                        ),
                );
              }),
        ),
      );
    });
  }
}

typedef MapCallback = void Function(LatLng pos, double zoom);
