
import 'package:flutter/material.dart';
import 'package:mobi_tv_entertainment/main.dart';
import 'package:mobi_tv_entertainment/home_screen_pages/webseries_screen/manage_webseries.dart';
import 'package:mobi_tv_entertainment/provider/color_provider.dart';
import 'package:mobi_tv_entertainment/provider/focus_provider.dart';
import 'package:mobi_tv_entertainment/video_widget/socket_service.dart';
import 'package:mobi_tv_entertainment/widgets/small_widgets/loading_indicator.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'banner_slider_screen/banner_slider_screen.dart';
import 'movies_screen/movies.dart';
import 'sub_live_screen/sub_live_screen.dart';
import 'sub_vod_screen/sub_vod.dart';
import 'home_category_screen/home_category.dart';

void main() {
  runApp(const HomeScreen());
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SocketService _socketService = SocketService();
  final GlobalKey watchNowKey = GlobalKey();
  final GlobalKey subLiveKey = GlobalKey();
  final GlobalKey subVodKey = GlobalKey();
  final GlobalKey manageMoviesKey = GlobalKey();
  final GlobalKey manageWebseriesKey = GlobalKey();
  final GlobalKey homeCategoryFirstBannerKey = GlobalKey();

  late FocusNode watchNowFocusNode;
  late FocusNode subLiveFocusNode;
  late FocusNode firstSubVodFocusNode;
  late FocusNode manageMoviesFocusNode;
  late FocusNode manageWebseriesFocusNode;
  late FocusNode firstHomeCategoryFocusNode;

  bool _isLoading = false;


  

  @override
  void initState() {
    super.initState();

    // Initialize focus nodes
    watchNowFocusNode = FocusNode();
    subLiveFocusNode = FocusNode();
    firstSubVodFocusNode = FocusNode();
    manageMoviesFocusNode = FocusNode();
    manageWebseriesFocusNode = FocusNode();
    firstHomeCategoryFocusNode = FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final focusProvider = context.read<FocusProvider>();

      // Set focus nodes
      focusProvider.setWatchNowFocusNode(watchNowFocusNode);
      focusProvider.setFirstMusicItemFocusNode(subLiveFocusNode);
      focusProvider.setFirstSubVodFocusNode(firstSubVodFocusNode);
      focusProvider.setFirstManageMoviesFocusNode(manageMoviesFocusNode);
      focusProvider.setFirstManageWebseriesFocusNode(manageWebseriesFocusNode);
      focusProvider.setHomeCategoryFirstBannerFocusNode(manageWebseriesFocusNode);

      context.read<FocusProvider>().registerElementKey('watchNow', watchNowKey);
      focusProvider.registerElementKey('subLiveScreen', subLiveKey);
      focusProvider.registerElementKey('subVod', subVodKey);
      focusProvider.registerElementKey('manageMovies', manageMoviesKey);
      focusProvider.registerElementKey('manageWebseries', manageMoviesKey);
      focusProvider.registerElementKey(
          'homeCategoryFirstBanner', homeCategoryFirstBannerKey);
    });
  }

  @override
  void dispose() {
    final focusProvider = context.read<FocusProvider>();
    focusProvider.unregisterElementKey('watchNow');
    focusProvider.unregisterElementKey('subLiveScreen');
    focusProvider.unregisterElementKey('subVod');
    focusProvider.unregisterElementKey('manageMovies');
    focusProvider.unregisterElementKey('manageWebseries');
    context
        .read<FocusProvider>()
        .unregisterElementKey('homeCategoryFirstBanner');
    // Clean up focus nodes
    watchNowFocusNode.dispose();
    subLiveFocusNode.dispose();
    firstSubVodFocusNode.dispose();
    manageMoviesFocusNode.dispose();
    manageWebseriesFocusNode.dispose();
    firstHomeCategoryFocusNode.dispose();
    _socketService.dispose();
    super.dispose();
  }

  // Calculate ManageMovies height based on category count
  double _calculateManageMoviesHeight(BuildContext context) {
    final focusProvider = context.watch<FocusProvider>();
    final int categoryCount = focusProvider.categoryCount;

    // Base height per category (adjust this value as needed)
    final double heightPerCategory = screenhgt * 0.42;

    // Calculate total height based on number of categories
    // Using a minimum of 1 category to avoid zero height
    final int effectiveCategoryCount = categoryCount > 0 ? categoryCount : 1;

    return heightPerCategory * effectiveCategoryCount;
  }


    // Handle back button press
  Future<bool> _onWillPop() async {
    // Close the app when back button is pressed
    SystemNavigator.pop();
    return false; // Return false to prevent default back navigation
  }


  @override
  Widget build(BuildContext context) {
    return Consumer<ColorProvider>(builder: (context, colorProvider, child) {
      Color backgroundColor = colorProvider.isItemFocused
          ? colorProvider.dominantColor.withOpacity(0.5)
          : cardColor;

      // Get the calculated height for ManageMovies
      final double manageMoviesHeight = _calculateManageMoviesHeight(context);
      // final double manageWebseriesHeight =
      //     _calculateManageWebseriesHeight(context);

      return 
       PopScope(
        canPop: false, // Prevent default back navigation
        onPopInvoked: (didPop) {
          if (!didPop) {
            _onWillPop();
          }
        },
        child:
      Scaffold(
        backgroundColor: backgroundColor,
        body: Container(
          width: screenwdt,
          height: screenhgt,
          color: cardColor,
          child: SingleChildScrollView(
            controller: context.read<FocusProvider>().scrollController,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: screenwdt * 0.03),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: screenhgt * 0.5,
                    width: screenwdt,
                    key: watchNowKey,
                    child: BannerSlider(
                      focusNode: watchNowFocusNode,
                    ),
                  ),
                  Container(
                    height: screenhgt * 0.45,
                    key: subLiveKey,
                    child: SubLiveScreen(
                      focusNode: subLiveFocusNode,
                    ),
                  ),
                  SizedBox(
                    height: screenhgt * 0.4,
                    key: subVodKey,
                    child: SubVod(
                      focusNode: firstSubVodFocusNode,
                    ),
                  ),
                  SizedBox(
                    // Use the dynamically calculated height based on category count
                    height: screenhgt * 0.4,
                    key: manageMoviesKey,
                    child: Movies(
                      focusNode: manageMoviesFocusNode,
                    ),
                    
                  ),
                  SizedBox(
                    // Use the dynamically calculated height based on category count
                    // height: manageWebseriesHeight,
                    height: screenhgt * 0.5,

                    key: manageWebseriesKey,
                    child: ManageWebseries(
                      focusNode: manageWebseriesFocusNode,
                    ),
                  ),
                  // SizedBox(
                  //   height: screenhgt * 4,
                  //   key: homeCategoryFirstBannerKey,
                  //   child: HomeCategory(),
                  // ),
                  if (_isLoading) Center(child: LoadingIndicator()),
                ],
              ),
            ),
          ),
        ),
      ));
    });
  }
}
