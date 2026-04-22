






import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as https;
import 'package:mobi_tv_entertainment/components/services/professional_colors_for_home_pages.dart';
import 'package:mobi_tv_entertainment/main.dart';
import 'package:mobi_tv_entertainment/components/video_widget/video_screen.dart';
import 'package:mobi_tv_entertainment/components/services/history_service.dart';
import 'package:mobi_tv_entertainment/components/widgets/smart_common_horizontal_list.dart';

class SdMoviesScreen extends StatefulWidget {
  const SdMoviesScreen({super.key});
  @override
  State<SdMoviesScreen> createState() => _SdMoviesScreenState();
}

class _SdMoviesScreenState extends State<SdMoviesScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  // Future<List<CommonContentModel>> fetchMoviesAPI() async {
  //   var url = Uri.parse(SessionManager.baseUrl + 'getAllMovies?records=50');
  //   final response = await https.get(url, headers: {'auth-key': SessionManager.authKey, 'Content-Type': 'application/json', 'domain': SessionManager.savedDomain}).timeout(const Duration(seconds: 30));

  //   if (response.statusCode == 200) {
  //     final dynamic responseBody = json.decode(response.body);
  //     List<dynamic> jsonData = (responseBody is List) ? responseBody : (responseBody['data'] as List);
  //     var activeData = jsonData.where((m) => m['status'] == 1 || m['status'] == '1').toList();
  //     activeData.sort((a, b) => (a['recent_index'] ?? 0).compareTo(b['recent_index'] ?? 0));

  //     return activeData.map((item) {
  //       String badge = 'HD';
  //       String rawGenres = (item['genres'] ?? '').toString().toLowerCase();
  //       if (rawGenres.contains('comedy')) badge = 'COMEDY';
  //       else if (rawGenres.contains('action')) badge = 'ACTION';
  //       else if (rawGenres.contains('romantic')) badge = 'ROMANCE';

  //       return CommonContentModel(id: item['id'].toString(), title: item['name'] ?? 'Unknown', imageUrl: item['banner'] ?? item['poster'] ?? '', badgeText: badge, originalData: item);
  //     }).toList();
  //   } else { throw Exception('Failed to load movies'); }
  // }



Future<List<CommonContentModel>> fetchMoviesAPI() async {
    var url = Uri.parse(SessionManager.baseUrl + 'getAllRecentSDMovies?records=50');
    final response = await https.get(url, headers: {
      'auth-key': SessionManager.authKey, 
      'Content-Type': 'application/json', 
      'domain': SessionManager.savedDomain
    }).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final dynamic responseBody = json.decode(response.body);
      List<dynamic> jsonData = (responseBody is List) ? responseBody : (responseBody['data'] as List);
      var activeData = jsonData.where((m) => m['status'] == 1 || m['status'] == '1').toList();
      activeData.sort((a, b) => (a['recent_index'] ?? 0).compareTo(b['recent_index'] ?? 0));

      return activeData.map((item) {
        String rawGenres = (item['genres'] ?? '').toString().trim();
        String badge = '';
        
        if (rawGenres.isNotEmpty) {
          // Split by comma, take the first item, remove extra spaces, and make it uppercase
          badge = rawGenres.split(',').first.trim().toUpperCase();
        }

        return CommonContentModel(
          id: item['id'].toString(), 
          title: item['name'] ?? 'Unknown', 
          imageUrl: item['banner'] ?? item['poster'] ?? '', 
          badgeText: badge, 
          originalData: item
        );
      }).toList();
    } else { 
      throw Exception('Failed to load movies'); 
    }
  }

  Future<void> _onItemTap(CommonContentModel item) async {
    final movieData = item.originalData;
    try { await HistoryService.updateUserHistory(userId: SessionManager.userId!, contentType: 1, eventId: int.parse(item.id), eventTitle: item.title, url: movieData['movie_url'] ?? '', categoryId: 0); } catch (e) {}
    await Navigator.push(context, MaterialPageRoute(builder: (context) => VideoScreen(videoUrl: movieData['movie_url'] ?? '', bannerImageUrl: item.imageUrl, channelList: const [], source: 'isRecentlyAdded', videoId: int.parse(item.id), name: item.title, liveStatus: false, updatedAt: movieData['updated_at'] ?? '', streamType: '')));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SmartCommonHorizontalList(
      sectionTitle: "LATEST SD MOVIES",
      titleGradient: const [ProfessionalColorsForHomePages.accentBlue, ProfessionalColorsForHomePages.accentPurple],
      accentColor: ProfessionalColorsForHomePages.accentBlue,
      placeholderIcon: Icons.movie_outlined, badgeDefaultText: 'HD',
      focusIdentifier: 'manageSdMovies',
      fetchApiData: fetchMoviesAPI,
      onItemTap: _onItemTap,
      maxVisibleItems: 50, // No view all
    );
  }
}




