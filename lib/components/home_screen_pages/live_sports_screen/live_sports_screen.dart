// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as https;
// import 'package:mobi_tv_entertainment/components/services/professional_colors_for_home_pages.dart';
// import 'package:mobi_tv_entertainment/main.dart';
// import 'package:mobi_tv_entertainment/components/video_widget/video_screen.dart';
// import 'package:mobi_tv_entertainment/components/services/history_service.dart';
// import 'package:mobi_tv_entertainment/components/widgets/smart_common_horizontal_list.dart';

// class LiveSportsScreen extends StatefulWidget {
//   const LiveSportsScreen({super.key});
//   @override
//   State<LiveSportsScreen> createState() => _LiveSportsScreenState();
// }

// class _LiveSportsScreenState extends State<LiveSportsScreen> with AutomaticKeepAliveClientMixin {
//   @override
//   bool get wantKeepAlive => true;

//   Future<List<CommonContentModel>> fetchSportsAPI() async {
//     var url = Uri.parse(SessionManager.baseUrl + 'getAllSportsLive');
//     final response = await https.get(url, headers: {
//       'auth-key': SessionManager.authKey, 
//       'Content-Type': 'application/json', 
//       'domain': SessionManager.savedDomain
//     }).timeout(const Duration(seconds: 30));

//     if (response.statusCode == 200) {
//       final dynamic responseBody = json.decode(response.body);
//       List<dynamic> jsonData = (responseBody is List) ? responseBody : (responseBody['data'] as List);
//       var activeData = jsonData.where((m) => m['status'] == 1 || m['status'] == '1').toList();

//       return activeData.map((item) {
//         // Genres me se sirf pehla part uthana aur uppercase karna
//         String rawGenres = (item['genres'] ?? '').toString().trim();
//         String badge = 'LIVE'; // Default badge for sports
        
//         if (rawGenres.isNotEmpty) {
//           badge = rawGenres.split(',').first.trim().toUpperCase();
//         }

//         return CommonContentModel(
//           id: item['id'].toString(), 
//           title: item['channel_name'] ?? 'Unknown', 
//           imageUrl: item['channel_logo'] ?? item['channel_bg'] ?? '', 
//           badgeText: badge, 
//           originalData: item
//         );
//       }).toList();
//     } else { 
//       throw Exception('Failed to load live sports'); 
//     }
//   }

//   Future<void> _onItemTap(CommonContentModel item) async {
//     final channelData = item.originalData;
    
//     // History update
//     try { 
//       await HistoryService.updateUserHistory(
//         userId: SessionManager.userId!, 
//         contentType: channelData['content_type'] ?? 3, 
//         eventId: int.parse(item.id), 
//         eventTitle: item.title, 
//         url: channelData['channel_link'] ?? '', 
//         categoryId: 0
//       ); 
//     } catch (e) {}
    
//     // Video Player par navigate karna
//     await Navigator.push(context, MaterialPageRoute(builder: (context) => VideoScreen(
//       videoUrl: channelData['channel_link'] ?? '', 
//       bannerImageUrl: item.imageUrl, 
//       channelList: const [], 
//       source: 'isLive', 
//       videoId: int.parse(item.id), 
//       name: item.title, 
//       liveStatus: true, 
//       updatedAt: channelData['updated_at'] ?? '', 
//       streamType: channelData['stream_type'] ?? ''
//     )));
//   }

//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
//     return SmartCommonHorizontalList(
//       sectionTitle: "LIVE SPORTS",
//       titleGradient: const [ProfessionalColorsForHomePages.accentBlue, ProfessionalColorsForHomePages.accentPurple],
//       accentColor: ProfessionalColorsForHomePages.accentBlue,
//       placeholderIcon: Icons.sports_cricket, 
//       badgeDefaultText: 'LIVE',
//       focusIdentifier: 'liveSports',
//       fetchApiData: fetchSportsAPI,
//       onItemTap: _onItemTap,
//       maxVisibleItems: 50, 
//     );
//   }
// }





import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as https;
import 'package:mobi_tv_entertainment/components/services/professional_colors_for_home_pages.dart';
import 'package:mobi_tv_entertainment/main.dart';
import 'package:mobi_tv_entertainment/components/video_widget/video_screen.dart';
import 'package:mobi_tv_entertainment/components/services/history_service.dart';
import 'package:mobi_tv_entertainment/components/widgets/smart_common_horizontal_list.dart';
// Make sure NewsItemModel is imported
import 'package:mobi_tv_entertainment/components/widgets/models/news_item_model.dart'; 

class LiveSportsScreen extends StatefulWidget {
  const LiveSportsScreen({super.key});
  @override
  State<LiveSportsScreen> createState() => _LiveSportsScreenState();
}

class _LiveSportsScreenState extends State<LiveSportsScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  // 🔥 1. Ek variable banayein jisme hum poori list store karenge
  List<CommonContentModel> _allSportsList = [];

  Future<List<CommonContentModel>> fetchSportsAPI() async {
    var url = Uri.parse(SessionManager.baseUrl + 'getAllSportsLive');
    final response = await https.get(url, headers: {
      'auth-key': SessionManager.authKey, 
      'Content-Type': 'application/json', 
      'domain': SessionManager.savedDomain
    }).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final dynamic responseBody = json.decode(response.body);
      List<dynamic> jsonData = (responseBody is List) ? responseBody : (responseBody['data'] as List);
      var activeData = jsonData.where((m) => m['status'] == 1 || m['status'] == '1').toList();

      var mappedList = activeData.map((item) {
        String rawGenres = (item['genres'] ?? '').toString().trim();
        String badge = 'LIVE'; 
        
        if (rawGenres.isNotEmpty) {
          badge = rawGenres.split(',').first.trim().toUpperCase();
        }

        return CommonContentModel(
          id: item['id'].toString(), 
          title: item['channel_name'] ?? 'Unknown', 
          imageUrl: item['channel_logo'] ?? item['channel_bg'] ?? '', 
          badgeText: badge, 
          originalData: item
        );
      }).toList();

      // 🔥 2. Return karne se pehle list ko state mein save kar lein
      _allSportsList = mappedList;
      return mappedList;

    } else { 
      throw Exception('Failed to load live sports'); 
    }
  }

  Future<void> _onItemTap(CommonContentModel item) async {
    final channelData = item.originalData;
    
    // History update
    try { 
      await HistoryService.updateUserHistory(
        userId: SessionManager.userId!, 
        contentType: channelData['content_type'] ?? 3, 
        eventId: int.parse(item.id), 
        eventTitle: item.title, 
        url: channelData['channel_link'] ?? '', 
        categoryId: 0
      ); 
    } catch (e) {}
    
    // 🔥 3. _allSportsList ko NewsItemModel mein convert karke ek swipeable list banayein
    List<NewsItemModel> playerList = _allSportsList.map((c) {
      final data = c.originalData; // json data wapas nikalna
      return NewsItemModel(
        id: data['id'].toString(),
        channelNumber: data['channel_number']?.toString() ?? '', 
        name: data['channel_name'] ?? '',
        banner: data['channel_logo'] ?? data['channel_bg'] ?? '',
        url: data['channel_link'] ?? '',
        streamType: data['stream_type'] ?? '',
        status: data['status']?.toString() ?? '1',
        genres: data['genres'] ?? '',
        videoId: '',
        description: '',
        poster: data['channel_logo'] ?? data['channel_bg'] ?? '',
        category: data['genres'] ?? '',
        type: data['stream_type'] ?? '',
        index: '0',
        image: data['channel_logo'] ?? data['channel_bg'] ?? '',
        unUpdatedUrl: data['channel_link'] ?? '',
        updatedAt: data['updated_at'] ?? ''
      );
    }).toList();

    // Video Player par navigate karna
    await Navigator.push(context, MaterialPageRoute(builder: (context) => VideoScreen(
      videoUrl: channelData['channel_link'] ?? '', 
      bannerImageUrl: item.imageUrl, 
      channelList: playerList, // 🔥 Yahan tayar ki gayi list pass kar di
      source: 'isLive', 
      videoId: int.parse(item.id), 
      name: item.title, 
      liveStatus: true, 
      updatedAt: channelData['updated_at'] ?? '', 
      streamType: channelData['stream_type'] ?? ''
    )));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SmartCommonHorizontalList(
      sectionTitle: "LIVE SPORTS",
      titleGradient: const [ProfessionalColorsForHomePages.accentBlue, ProfessionalColorsForHomePages.accentPurple],
      accentColor: ProfessionalColorsForHomePages.accentBlue,
      placeholderIcon: Icons.sports_cricket, 
      badgeDefaultText: 'LIVE',
      focusIdentifier: 'liveSports',
      fetchApiData: fetchSportsAPI,
      onItemTap: _onItemTap,
      maxVisibleItems: 50, 
    );
  }
}