library draggable_home;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../helpers/gps_location_helper.dart';
import '../../../../provider/locationProvider.dart';
import '../../../../widgets/loading_location_widget.dart';

class DraggableAdhan extends StatefulWidget {
  @override
  _DraggableAdhanState createState() => _DraggableAdhanState();

  /// Leading: A widget to display before the toolbar's title.
  final Widget? leading;

  /// Title: A Widget to display title in AppBar
  final Widget title;

  /// Center Title: Allows toggling of title from the center. By default title is in the center.
  final bool centerTitle;

  /// Action: A list of Widgets to display in a row after the title widget.
  final List<Widget>? actions;

  /// Always Show Leading And Action : This make Leading and Action always visible. Default value is false.
  final bool alwaysShowLeadingAndAction;

  /// Always Show Title : This make Title always visible. Default value is false.
  final bool alwaysShowTitle;

  /// Drawer: Drawers are typically used with the Scaffold.drawer property.
  final Widget? drawer;

  /// Header Expanded Height : Height of the header widget. The height is a double between 0.0 and 1.0. The default value of height is 0.35 and should be less than stretchMaxHeigh
  final double headerExpandedHeight;

  /// Header Widget: A widget to display Header above body.
  final Widget headerWidget;

  /// headerBottomBar: AppBar or toolBar like widget just above the body.

  final Widget? headerBottomBar;

  /// backgroundColor: The color of the Material widget that underlies the entire DraggableHome body.
  final Color? backgroundColor;

  /// appBarColor: The color of the scaffold app bar.
  final Color? appBarColor;

  /// curvedBodyRadius: Creates a border top left and top right radius of body, Default radius of the body is 20.0. For no radius simply set value to 0.
  final double curvedBodyRadius;

  /// body: A widget to Body
  final Widget body;

  /// fullyStretchable: Allows toggling of fully expand draggability of the DraggableHome. Set this to true to allow the user to fully expand the header.
  final bool fullyStretchable;

  /// stretchTriggerOffset: The offset of overscroll required to fully expand the header.
  final double stretchTriggerOffset;

  /// expandedBody: A widget to display when fully expanded as header or expandedBody above body.
  final Widget? expandedBody;

  /// stretchMaxHeight: Height of the expandedBody widget. The height is a double between 0.0 and 0.95. The default value of height is 0.9 and should be greater than headerExpandedHeight
  final double stretchMaxHeight;

  /// floatingActionButton: An object that defines a position for the FloatingActionButton based on the Scaffold's ScaffoldPrelayoutGeometry.
  final Widget? floatingActionButton;

  /// bottomSheet: A persistent bottom sheet shows information that supplements the primary content of the app. A persistent bottom sheet remains visible even when the user interacts with other parts of the app.
  final Widget? bottomSheet;

  /// bottomNavigationBarHeight: This is requires when using custom height to adjust body height. This make no effect on bottomNavigationBar.
  final double? bottomNavigationBarHeight;

  /// bottomNavigationBar: Snack bars slide from underneath the bottom navigation bar while bottom sheets are stacked on top.
  final Widget? bottomNavigationBar;

  final Widget? dateChanger;

  /// floatingActionButtonLocation: An object that defines a position for the FloatingActionButton based on the Scaffold's ScaffoldPrelayoutGeometry.
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  /// floatingActionButtonAnimator: Provider of animations to move the FloatingActionButton between FloatingActionButtonLocations.
  final FloatingActionButtonAnimator? floatingActionButtonAnimator;

  /// physics: How the scroll view should respond to user input. For example, determines how the scroll view continues to animate after the user stops dragging the scroll view.
  final ScrollPhysics? physics;

  /// scrollController: An object that can be used to control the position to which this scroll view is scrolled.
  final ScrollController? scrollController;

  /// This will create DraggableHome.
  const DraggableAdhan({
    Key? key,
    this.leading,
    required this.title,
    this.centerTitle = true,
    this.actions,
    this.alwaysShowLeadingAndAction = false,
    this.alwaysShowTitle = false,
    this.headerExpandedHeight = 0.25,
    required this.headerWidget,
    required this.dateChanger,
    this.headerBottomBar,
    this.backgroundColor,
    this.appBarColor,
    this.curvedBodyRadius = 20,
    required this.body,
    this.drawer,
    this.fullyStretchable = false,
    this.stretchTriggerOffset = 200,
    this.expandedBody,
    this.stretchMaxHeight = 0.9,
    this.bottomSheet,
    this.bottomNavigationBarHeight = kBottomNavigationBarHeight,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.floatingActionButtonAnimator,
    this.physics,
    this.scrollController,
  }) : assert(
         headerExpandedHeight > 0.0 && headerExpandedHeight < stretchMaxHeight,
       ),
       assert(
         (stretchMaxHeight > headerExpandedHeight) && (stretchMaxHeight < .95),
       ),
       super(key: key);
}

class _DraggableAdhanState extends State<DraggableAdhan> {
  final BehaviorSubject<bool> isFullyExpanded = BehaviorSubject<bool>.seeded(
    false,
  );
  final BehaviorSubject<bool> isFullyCollapsed = BehaviorSubject<bool>.seeded(
    false,
  );
  final BehaviorSubject<bool> isOpacity = BehaviorSubject<bool>.seeded(false);

  @override
  void dispose() {
    isFullyExpanded.close();
    isFullyCollapsed.close();
    isOpacity.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double appBarHeight =
        AppBar().preferredSize.height + widget.curvedBodyRadius;
    final double topPadding = MediaQuery.of(context).padding.top;
    final double expandedHeight =
        MediaQuery.of(context).size.height * widget.headerExpandedHeight;
    final double fullyExpandedHeight =
        MediaQuery.of(context).size.height * (widget.stretchMaxHeight);

    return Scaffold(
      // extendBodyBehindAppBar: true,
      // primary: false,
      backgroundColor: widget.backgroundColor,
      // drawer: widget.drawer,
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.axis == Axis.vertical) {
            // for opacity for the time
            if (notification.metrics.extentBefore >
                expandedHeight - AppBar().preferredSize.height - 100) {
              if (!(isOpacity.value)) isOpacity.add(true);
            } else {
              if ((isOpacity.value)) isOpacity.add(false);
            }
            // isFullyCollapsed
            if ((isFullyExpanded.value) &&
                notification.metrics.extentBefore > 100) {
              isFullyExpanded.add(false);
            }
            //isFullyCollapsed
            if (notification.metrics.extentBefore >
                expandedHeight - AppBar().preferredSize.height - 40) {
              if (!(isFullyCollapsed.value)) isFullyCollapsed.add(true);
            } else {
              if ((isFullyCollapsed.value)) isFullyCollapsed.add(false);
            }
          }
          return false;
        },
        child: sliver(
          context,
          appBarHeight,
          fullyExpandedHeight,
          expandedHeight,
          topPadding,
        ),
      ),
      bottomSheet: widget.bottomSheet,
      bottomNavigationBar: widget.bottomNavigationBar,
      floatingActionButton: widget.floatingActionButton,
      floatingActionButtonLocation: widget.floatingActionButtonLocation,
      floatingActionButtonAnimator: widget.floatingActionButtonAnimator,
    );
  }

  CustomScrollView sliver(
    BuildContext context,
    double appBarHeight,
    double fullyExpandedHeight,
    double expandedHeight,
    double topPadding,
  ) {
    return CustomScrollView(
      physics: widget.physics ?? const ScrollPhysics(),
      controller: widget.scrollController,
      slivers: [
        StreamBuilder<List<bool>>(
          stream: CombineLatestStream.list<bool>([
            isFullyCollapsed.stream,
            isFullyExpanded.stream,
            isOpacity.stream,
          ]),
          builder: (BuildContext context, AsyncSnapshot<List<bool>> snapshot) {
            final List<bool> streams = (snapshot.data ?? [false, false, false]);
            final bool fullyCollapsed = streams[0];
            final bool fullyExpanded = streams[1];
            return SliverAppBar(
              backgroundColor: !fullyCollapsed
                  ? widget.backgroundColor
                  : widget.appBarColor,
              /*       actions: widget.alwaysShowLeadingAndAction
                  ? widget.actions
                  : !fullyCollapsed
                  ? []
                  : widget.actions, */
              elevation: 0,
              pinned: true,
              stretch: false,
              /* title: widget.alwaysShowTitle
                  ? widget.title
                  : AnimatedOpacity(
                      opacity: fullyCollapsed ? 1 : 0,
                      duration: const Duration(milliseconds: 100),
                      child: widget.title,
                    ), */
              collapsedHeight: appBarHeight,
              expandedHeight: fullyExpanded
                  ? fullyExpandedHeight
                  : expandedHeight,
              flexibleSpace: Stack(
                children: [
                  FlexibleSpaceBar(
                    background: Container(
                      margin: const EdgeInsets.only(bottom: 0.0),
                      child: fullyExpanded
                          ? (widget.expandedBody ?? const SizedBox())
                          : widget.headerWidget,
                    ),
                  ),
                  // center App header
                  /* fullyCollapsed
                      ? const SizedBox()
                      :  */
                  Positioned(
                    top: 30,
                    left: 5,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildLocation(),
                        Container(
                          margin: const EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            color: Colors.transparent.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(100.0),
                          ),
                          child: const InkResponse(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.notifications_none,
                                size: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // fullyCollapsed
                  // ? const SizedBox()
                  // : widget.currentAdhan != null
                  // center time date changer calendar
                  // :
                  Positioned(
                    top: 100,
                    left: 0,
                    right: 0,
                    child: widget.dateChanger!,
                  ),
                  // : const SizedBox(),
                  Positioned(
                    bottom: -1,
                    left: 0,
                    right: 0,
                    child: roundedCorner(context),
                  ),
                ],
              ),
              stretchTriggerOffset: widget.stretchTriggerOffset,
              onStretchTrigger: widget.fullyStretchable
                  ? () async {
                      if (!fullyExpanded) isFullyExpanded.add(true);
                    }
                  : null,
            );
          },
        ),
        SliverToBoxAdapter(child: SizedBox(height: 500, child: widget.body)),
        // SliverToBoxAdapter(child: widget.body),
      ],
    );
  }

  _buildLocation() {
    final locationState = context.watch<LocationProvider>().locationState;
    if (locationState is LocationAvailable) {
      return Container(
        margin: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0)),
        child: InkResponse(
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Row(
              children: [
                const Icon(
                  Icons.pin_drop_outlined,
                  size: 20,
                  color: Colors.white,
                ),
                const SizedBox(width: 4),
                Text(
                  locationState.locationLocality,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                ),
                const SizedBox(width: 1),
              ],
            ),
          ),
        ),
      );
    } else {
      //* Loading site
      return const LoadingLocationWidget();
    }
  }

  Container roundedCorner(BuildContext context) {
    return Container(
      height: widget.curvedBodyRadius,
      decoration: BoxDecoration(
        color:
            widget.backgroundColor ?? Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(widget.curvedBodyRadius),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            child: Container(
              width: 60,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /* SliverList sliverList(BuildContext context, double topHeight) {
    return SliverList(
      delegate: SliverChildListDelegate([
        Container(

          color: Theme.of(context).colorScheme.secondary,
          child: Column(
            children: [
              expandedUpArrow(),
              //Body
              ...widget.body,
            ],
          ),
        ),
      ]),
    );
  } */

  StreamBuilder<bool> expandedUpArrow() {
    return StreamBuilder<bool>(
      stream: isFullyExpanded.stream,
      builder: (context, snapshot) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          height: (snapshot.data ?? false) ? 25 : 0,
          width: MediaQuery.of(context).size.width,
          child: Center(
            child: Icon(
              Icons.keyboard_arrow_up_rounded,
              color: (snapshot.data ?? false) ? null : Colors.transparent,
            ),
          ),
        );
      },
    );
  }
}
