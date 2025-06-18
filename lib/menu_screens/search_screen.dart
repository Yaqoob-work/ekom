import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as https;
import 'package:mobi_tv_entertainment/home_screen_pages/sub_vod_screen/sub_vod.dart';
import 'package:mobi_tv_entertainment/provider/color_provider.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../provider/focus_provider.dart';
import '../video_widget/socket_service.dart';
import '../video_widget/video_screen.dart';
import '../widgets/models/news_item_model.dart';
import '../widgets/utils/color_service.dart';

Future<List<NewsItemModel>> fetchFromApi(String searchTerm) async {
  try {
    // Get auth key from AuthManager
    String authKey = AuthManager.authKey;

    if (authKey.isEmpty) {
      throw Exception('Authentication key is missing');
    }

    final response = await https.get(
      Uri.parse(
          'https://acomtv.coretechinfo.com/public/api/searchContent/${searchTerm}/0'),
      headers: {
        'auth-key': authKey,
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      // Check if response is valid JSON
      String responseBody = response.body.trim();
      if (responseBody.startsWith('[') || responseBody.startsWith('{')) {
        final dynamic responseData = json.decode(responseBody);

        // Handle both array and object responses
        List<dynamic> dataList;
        if (responseData is List) {
          dataList = responseData;
        } else if (responseData is Map && responseData['data'] is List) {
          dataList = responseData['data'];
        } else if (responseData is Map && responseData['results'] is List) {
          dataList = responseData['results'];
        } else {
          throw Exception('Unexpected response format');
        }

        // Log first item details for debugging
        if (dataList.isNotEmpty) {}

        // Apply filtering logic
        List<dynamic> filteredList;
        if (settings['tvenableAll'] == 0) {
          final enabledChannels =
              settings['channels']?.map((id) => id.toString()).toSet() ?? {};

          filteredList = dataList
              .where((channel) =>
                  channel['name'] != null &&
                  channel['name']
                      .toString()
                      .toLowerCase()
                      .contains(searchTerm.toLowerCase()) &&
                  enabledChannels.contains(channel['id'].toString()))
              .toList();
        } else {
          filteredList = dataList
              .where((channel) =>
                  channel['name'] != null &&
                  channel['name']
                      .toString()
                      .toLowerCase()
                      .contains(searchTerm.toLowerCase()))
              .toList();
        }

        // Convert to NewsItemModel and log
        List<NewsItemModel> newsItems = [];
        for (int i = 0; i < filteredList.length; i++) {
          try {
            // Fix the data types before parsing
            Map<String, dynamic> itemData =
                Map<String, dynamic>.from(filteredList[i]);

            // Convert integer fields to strings if needed
            if (itemData['id'] != null) {
              itemData['id'] = itemData['id'].toString();
            }
            if (itemData['status'] != null) {
              itemData['status'] = itemData['status'].toString();
            }

            // Fix banner URL if it's relative
            if (itemData['banner'] != null &&
                !itemData['banner'].toString().startsWith('http')) {
              String bannerPath = itemData['banner'].toString();
              // Add base URL for relative paths
              itemData['banner'] =
                  'https://acomtv.coretechinfo.com/public/$bannerPath';
            }

            NewsItemModel item = NewsItemModel.fromJson(itemData);
            newsItems.add(item);
          } catch (e) {}
        }

        return newsItems;
      } else {
        throw Exception('Invalid response format');
      }
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      throw Exception('Authentication failed. Please login again.');
    } else {
      throw Exception('Failed to load data from API: ${response.statusCode}');
    }
  } catch (e) {
    // If it's an authentication error, you might want to handle it specially
    if (e.toString().contains('Authentication')) {
      rethrow; // Re-throw auth errors so UI can handle them
    }

    return [];
  }
}

Uint8List _getImageFromBase64String(String base64String) {
  try {
    // Split the base64 string to remove metadata if present
    String cleanBase64 = base64String.split(',').last;

    Uint8List result = base64Decode(cleanBase64);
    return result;
  } catch (e) {
    rethrow;
  }
}

Map<String, dynamic> settings = {};

Future<void> fetchSettings() async {
  try {
    // Use auth key for settings API as well
    String authKey = AuthManager.authKey;

    final response = await https.get(
      Uri.parse('https://acomtv.coretechinfo.com/public/api/getSettings'),
      headers: {
        'auth-key': authKey,
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      settings = json.decode(response.body);
    } else {
      // Fallback to old API if new one fails
      final fallbackResponse = await https.get(
        Uri.parse('https://api.ekomflix.com/android/getSettings'),
        headers: {'x-api-key': 'vLQTuPZUxktl5mVW'},
      );

      if (fallbackResponse.statusCode == 200) {
        settings = json.decode(fallbackResponse.body);
      } else {
        throw Exception('Failed to load settings from both APIs');
      }
    }
  } catch (e) {
    // Set default settings to prevent crashes
    settings = {
      'tvenableAll': 1,
      'channels': [],
    };
  }
}

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<NewsItemModel> searchResults = [];
  bool isLoading = false;
  TextEditingController _searchController = TextEditingController();
  int selectedIndex = -1;
  final FocusNode _searchFieldFocusNode = FocusNode();
  final FocusNode _searchIconFocusNode = FocusNode();
  Timer? _debounce;
  final List<FocusNode> _itemFocusNodes = [];
  bool _isNavigating = false;
  bool _showSearchField = false;
  Color paletteColor = Colors.grey;
  final PaletteColorService _paletteColorService = PaletteColorService();
  final SocketService _socketService = SocketService();
  final int _maxRetries = 3;
  final int _retryDelay = 5;
  bool _shouldContinueLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _searchFieldFocusNode.addListener(_onSearchFieldFocusChanged);
    _searchIconFocusNode.addListener(_onSearchIconFocusChanged);
    _socketService.initSocket();
    checkServerStatus();

    // Initialize settings
    fetchSettings();

    // Ensure auth key is available
    _ensureAuthKey();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<FocusProvider>()
          .setSearchIconFocusNode(_searchIconFocusNode);
    });
  }

  Future<void> _ensureAuthKey() async {
    await AuthManager.initialize();
    if (!AuthManager.hasValidAuthKey) {
      setState(() {
        _errorMessage = 'Authentication required. Please login again.';
      });
    } else {}
  }

  @override
  void dispose() {
    _searchFieldFocusNode.removeListener(_onSearchFieldFocusChanged);
    _searchIconFocusNode.removeListener(_onSearchIconFocusChanged);
    _searchFieldFocusNode.dispose();
    _searchIconFocusNode.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    _itemFocusNodes.forEach((node) => node.dispose());
    _socketService.dispose();
    super.dispose();
  }

  Future<void> _updateChannelUrlIfNeeded(
      List<NewsItemModel> result, int index) async {
    if (result[index].streamType == 'YoutubeLive' ||
        result[index].streamType == 'Youtube') {
      for (int i = 0; i < _maxRetries; i++) {
        if (!_shouldContinueLoading) break;
        try {
          String updatedUrl =
              await _socketService.getUpdatedUrl(result[index].url);
          setState(() {
            result[index] =
                result[index].copyWith(url: updatedUrl, streamType: 'M3u8');
          });
          break;
        } catch (e) {
          if (i == _maxRetries - 1) rethrow;
          await Future.delayed(Duration(seconds: _retryDelay));
        }
      }
    }
  }

  Future<void> _onItemTap(BuildContext context, int index) async {
    if (_isNavigating) return;
    _isNavigating = true;
    _showLoadingIndicator(context);

    try {
      // await _updateChannelUrlIfNeeded(searchResults, index);
      if (_shouldContinueLoading) {
        await _navigateToVideoScreen(context, searchResults, index);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Something Went Wrong')),
      );
    } finally {
      _isNavigating = false;
      _shouldContinueLoading = true;
      _dismissLoadingIndicator();
    }
  }

  void _showLoadingIndicator(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async {
            _shouldContinueLoading = false;
            _dismissLoadingIndicator();
            return Future.value(false);
          },
          child: Center(
            child: SpinKitFadingCircle(
              color: Colors.white,
              size: 50.0,
            ),
          ),
        );
      },
    );
  }

  Future<void> _navigateToVideoScreen(
      BuildContext context, List<NewsItemModel> channels, int index) async {
    if (index < 0 || index >= channels.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid channel index')),
      );
      return;
    }

    final channel = channels[index];
    final String? videoUrl = channel.url;
    final String? streamType = channel.streamType;
    final String? genres = channel.genres;
    final int? parsedContentType = int.tryParse(channel.contentType);
    if (parsedContentType == 1) {
      try {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailsPage(
              channelList: searchResults,
              id: int.tryParse(channel.id) ?? 0,
              source: 'isSearchScreenViaDetailsPageChannelList',
              banner: channel.banner,
              name: channel.name,
            ),
          ),
        );
      } catch (e) {}
    }

    if (videoUrl == null || videoUrl.isEmpty || streamType == null) {
      return;
    }
    bool liveStatus = false;

    if (parsedContentType == 1) {
      setState(() {
        liveStatus = false;
      });
    } else {
      setState(() {
        liveStatus = true;
      });
    }

    try {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoScreen(
            videoUrl: videoUrl,
            startAtPosition: Duration.zero,
            bannerImageUrl: channel.banner,
            videoType: streamType,
            channelList: searchResults,
            isLive: true,
            isVOD: false,
            isBannerSlider: false,
            source: 'isSearchScreen',
            isSearch: true,
            videoId: int.tryParse(channel.id),
            unUpdatedUrl: videoUrl,
            name: channel.name,
            liveStatus: liveStatus,
            seasonId: null,
            isLastPlayedStored: false,
          ),
        ),
      );
    } catch (e) {}
  }

  void _dismissLoadingIndicator() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  void checkServerStatus() {
    int retryCount = 0;
    Timer.periodic(Duration(seconds: 10), (timer) {
      if (!_socketService.socket.connected && retryCount < _maxRetries) {
        retryCount++;
        _socketService.initSocket();
      } else {
        timer.cancel();
      }
    });
  }

  void _onSearchFieldFocusChanged() {
    setState(() {});
  }

  void _onSearchIconFocusChanged() {
    setState(() {});
  }

  void _performSearch(String searchTerm) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    if (searchTerm.trim().isEmpty) {
      setState(() {
        isLoading = false;
        searchResults.clear();
        _itemFocusNodes.clear();
        _errorMessage = '';
      });
      return;
    }

    // Check if auth key is available before searching
    if (!AuthManager.hasValidAuthKey) {
      setState(() {
        _errorMessage = 'Authentication required. Please login again.';
        isLoading = false;
        searchResults.clear();
        _itemFocusNodes.clear();
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 300), () async {
      if (!mounted) return;
      setState(() {
        isLoading = true;
        searchResults.clear();
        _itemFocusNodes.clear();
        _errorMessage = '';
      });

      try {
        final api1Results = await fetchFromApi(searchTerm);
        if (!mounted) return;
        setState(() {
          searchResults = api1Results;
          _itemFocusNodes.addAll(
              List.generate(searchResults.length, (index) => FocusNode()));
          isLoading = false;
        });

        await _preloadImages(searchResults);

        if (!mounted) return;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_itemFocusNodes.isNotEmpty &&
              _itemFocusNodes[0].context != null &&
              mounted) {
            FocusScope.of(context).requestFocus(_itemFocusNodes[0]);
          }
        });
      } catch (e) {
        if (!mounted) return;
        setState(() {
          isLoading = false;
          _errorMessage = e.toString().contains('Authentication')
              ? 'Authentication failed. Please login again.'
              : 'Search failed. Please try again.';
        });
      }
    });
  }

  Future<void> _preloadImages(List<NewsItemModel> results) async {
    for (int i = 0; i < results.length; i++) {
      final result = results[i];
      final imageUrl = result.banner;

      if (imageUrl.isNotEmpty && !imageUrl.startsWith('data:image')) {
        try {
          await precacheImage(CachedNetworkImageProvider(imageUrl), context);
        } catch (e) {}
      } else if (imageUrl.startsWith('data:image')) {
      } else {}
    }
  }

  Future<void> _updatePaletteColor(String imageUrl, bool isFocused) async {
    try {
      Color color = await _paletteColorService.getSecondaryColor(imageUrl);
      if (!mounted) return;

      setState(() {
        paletteColor = color;
      });

      // Update the provider with both color and focus state
      Provider.of<ColorProvider>(context, listen: false)
          .updateColor(color, isFocused);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        paletteColor = Colors.grey;
      });

      // Update with grey color in case of error
      Provider.of<ColorProvider>(context, listen: false)
          .updateColor(Colors.grey, isFocused);
    }
  }

  void _toggleSearchField() {
    setState(() {
      _showSearchField = !_showSearchField;
      if (_showSearchField) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _searchFieldFocusNode.requestFocus();
        });
      } else {
        _searchIconFocusNode.requestFocus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false, // Back button se page pop nahi hoga
        onPopInvoked: (didPop) {
          if (!didPop) {
            // Back button dabane par ye function call hoga
            context.read<FocusProvider>().requestWatchNowFocus();
          }
        },
        child:
            Consumer<ColorProvider>(builder: (context, colorProvider, child) {
          // Get background color based on provider state
          Color backgroundColor = colorProvider.isItemFocused
              ? colorProvider.dominantColor
              : cardColor;
          return Scaffold(
            backgroundColor: backgroundColor,
            body: Container(
              color: Colors.black54,
              child: Column(
                children: [
                  _buildSearchBar(),
                  Expanded(
                    child: _errorMessage.isNotEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                  size: 60,
                                ),
                                SizedBox(height: 20),
                                Text(
                                  _errorMessage,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                if (_errorMessage.contains('Authentication'))
                                  Padding(
                                    padding: EdgeInsets.only(top: 20),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.pushNamedAndRemoveUntil(
                                          context,
                                          '/login',
                                          (route) => false,
                                        );
                                      },
                                      child: Text('Go to Login'),
                                    ),
                                  ),
                              ],
                            ),
                          )
                        : isLoading
                            ? Center(
                                child: SpinKitFadingCircle(
                                  color: borderColor,
                                  size: 50.0,
                                ),
                              )
                            : searchResults.isEmpty
                                ? Center(
                                    child: Text(
                                      'No results found',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  )
                                : Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: screenwdt * 0.03),
                                    child: GridView.builder(
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 5,
                                      ),
                                      itemCount: searchResults.length,
                                      itemBuilder: (context, index) {
                                        return GestureDetector(
                                          onTap: () =>
                                              _onItemTap(context, index),
                                          child: _buildGridViewItem(
                                              context, index),
                                        );
                                      },
                                    ),
                                  ),
                  ),
                ],
              ),
            ),
          );
        }));
  }

  Widget _buildSearchBar() {
    return Container(
      width: screenwdt * 0.93,
      padding: EdgeInsets.only(top: screenhgt * 0.02),
      height: screenhgt * 0.1,
      child: Row(
        children: [
          if (!_showSearchField) Expanded(child: Text('')),
          if (_showSearchField)
            Expanded(
              child: TextField(
                controller: _searchController,
                focusNode: _searchFieldFocusNode,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.grey, width: 4.0),
                  ),
                  labelText: 'Search By Name',
                  labelStyle: TextStyle(color: Colors.white),
                ),
                style: TextStyle(color: Colors.white),
                textInputAction: TextInputAction.search,
                textAlignVertical: TextAlignVertical.center,
                onChanged: (value) {
                  _performSearch(value);
                },
                onSubmitted: (value) {
                  _performSearch(value);
                  _toggleSearchField();
                },
                autofocus: true,
              ),
            ),
          Focus(
            focusNode: _searchIconFocusNode,
            onKey: (node, event) {
              if (event is RawKeyDownEvent &&
                  event.logicalKey == LogicalKeyboardKey.arrowUp) {
                context.read<FocusProvider>().requestSearchNavigationFocus();
                return KeyEventResult.handled;
              } else if (event is RawKeyDownEvent &&
                  event.logicalKey == LogicalKeyboardKey.select) {
                _toggleSearchField();
                return KeyEventResult.handled;
              }
              return KeyEventResult.ignored;
            },
            child: IconButton(
              icon: Icon(
                Icons.search,
                color:
                    _searchIconFocusNode.hasFocus ? borderColor : Colors.white,
                size: _searchIconFocusNode.hasFocus ? 35 : 30,
              ),
              onPressed: _toggleSearchField,
              focusColor: Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridViewItem(BuildContext context, int index) {
    final result = searchResults[index];
    final status = result.status;
    final bool isBase64 = result.banner.startsWith('data:image');
    final colorProvider = Provider.of<ColorProvider>(context, listen: false);

    return Focus(
      focusNode: _itemFocusNodes[index],
      onFocusChange: (hasFocus) async {
        if (hasFocus) {
          // Update palette color with focus state
          await _updatePaletteColor(result.banner, true);
        } else {
          // Reset color when focus is lost
          colorProvider.resetColor();
        }

        setState(() {
          selectedIndex = hasFocus ? index : -1;
        });
      },
      onKeyEvent: (FocusNode node, KeyEvent event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.select) {
          _onItemTap(context, index);
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            width: screenwdt * 0.19,
            height: screenhgt * 0.2,
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              border: selectedIndex == index
                  ? Border.all(
                      color: paletteColor,
                      width: 3.0,
                    )
                  : Border.all(
                      color: Colors.transparent,
                      width: 3.0,
                    ),
              boxShadow: selectedIndex == index
                  ? [
                      BoxShadow(
                        color: paletteColor,
                        blurRadius: 25,
                        spreadRadius: 10,
                      )
                    ]
                  : [],
            ),
            child: () {
              if (status != '1') {
                return Container(
                  width: screenwdt * 0.19,
                  height: screenhgt * 0.2,
                  color: Colors.grey[800],
                  child: Center(
                    child: Text(
                      '',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                );
              }

              return ClipRRect(
                child: () {
                  if (isBase64) {
                    try {
                      final imageBytes =
                          _getImageFromBase64String(result.banner);
                      return Image.memory(
                        imageBytes,
                        width: screenwdt * 0.19,
                        height: screenhgt * 0.2,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: screenwdt * 0.19,
                            height: screenhgt * 0.2,
                            color: Colors.red[300],
                            child: Center(
                              child: Text(
                                'Base64\nError',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 10),
                              ),
                            ),
                          );
                        },
                      );
                    } catch (e) {
                      return Container(
                        width: screenwdt * 0.19,
                        height: screenhgt * 0.2,
                        color: Colors.red[300],
                        child: Center(
                          child: Text(
                            'Base64\nDecode Error',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ),
                      );
                    }
                  } else {
                    return CachedNetworkImage(
                      imageUrl: result.banner,
                      width: screenwdt * 0.19,
                      height: screenhgt * 0.2,
                      fit: BoxFit.cover,
                      placeholder: (context, url) {
                        return Container(
                          width: screenwdt * 0.19,
                          height: screenhgt * 0.2,
                          color: Colors.grey[700],
                          child: Center(
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        );
                      },
                      errorWidget: (context, url, error) {
                        return localImage;
                        // Container(
                        //   width: screenwdt * 0.19,
                        //   height: screenhgt * 0.2,
                        //   color: Colors.orange[300],
                        //   child: Center(
                        //     child: Column(
                        //       mainAxisAlignment: MainAxisAlignment.center,
                        //       children: [
                        //         Icon(Icons.error, color: Colors.white, size: 20),
                        //         Text(
                        //           '',
                        //           textAlign: TextAlign.center,
                        //           style: TextStyle(color: Colors.white, fontSize: 10),
                        //         ),
                        //       ],
                        //     ),
                        //   ),
                        // );
                      },
                    );
                  }
                }(),
              );
            }(),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.15,
            child: Text(
              result.name.toUpperCase(),
              style: TextStyle(
                fontSize: 15,
                color: selectedIndex == index ? paletteColor : Colors.white,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
