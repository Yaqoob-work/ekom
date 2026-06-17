import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as https;
import 'package:mobi_tv_entertainment/components/widgets/smart_show_details_screen.dart';
import 'package:mobi_tv_entertainment/main.dart';
import 'package:mobi_tv_entertainment/components/services/history_service.dart';
import 'package:mobi_tv_entertainment/components/video_widget/video_screen.dart';


class WebSeriesCallingScreen extends StatefulWidget {
  final int showId; final String showName; final String bannerUrl;
  const WebSeriesCallingScreen({Key? key, required this.showId, required this.showName, required this.bannerUrl}) : super(key: key);
  @override
  State<WebSeriesCallingScreen> createState() => _WebSeriesCallingScreenState();
}

class _WebSeriesCallingScreenState extends State<WebSeriesCallingScreen> {
  Future<List<CommonSeasonModel>> fetchSeasons() async {
    var url = Uri.parse(SessionManager.baseUrl + 'getSeasons/${widget.showId}');
    final response = await https.get(url, headers: {'auth-key': SessionManager.authKey, 'domain': SessionManager.savedDomain});
    final List<dynamic> data = jsonDecode(response.body);
    return data.where((m) => m['status'] == 1).map((item) => CommonSeasonModel(
      id: item['id'].toString(), title: item['Session_Name'] ?? 'Season',
      order: item['season_order'] ?? 1, bannerUrl: item['banner'] ?? '', originalData: item
    )).toList();
  }

  Future<List<CommonEpisodeModel>> fetchEpisodes(String seasonId) async {
    var url = Uri.parse(SessionManager.baseUrl + 'getEpisodes/$seasonId/0');
    final response = await https.get(url, headers: {'auth-key': SessionManager.authKey, 'domain': SessionManager.savedDomain});
    final List<dynamic> data = jsonDecode(response.body);
    return data.where((m) => m['status'] == 1).map((item) => CommonEpisodeModel(
      id: item['id'].toString(), title: item['Episoade_Name'] ?? 'Episode', description: item['episoade_description'] ?? '',
      imageUrl: item['episoade_image'] ?? '', order: item['episoade_order'] ?? 0, originalData: item
    )).toList();
  }

  Future<void> _onEpisodeTap(CommonEpisodeModel episode) async {
    final epData = episode.originalData;
    String playUrl = epData['url'] ?? '';
    
    try { await HistoryService.updateUserHistory(userId: SessionManager.userId!, contentType: 2, eventId: int.parse(episode.id), eventTitle: episode.title, url: playUrl, categoryId: 0); } catch (e) {}

    await Navigator.push(context, MaterialPageRoute(builder: (context) => VideoScreen(
      videoUrl: playUrl, bannerImageUrl: episode.imageUrl, channelList: const [], source: 'isWebSeries', videoId: int.parse(episode.id), name: episode.title, liveStatus: false, updatedAt: epData['updated_at'] ?? '', streamType: ''
    )));
  }

  @override
  Widget build(BuildContext context) {
    return SmartShowDetailsScreen(
      showName: widget.showName, bannerUrl: widget.bannerUrl, focusIdentifier: 'webSeriesDetails',
      fetchSeasons: fetchSeasons, fetchEpisodes: fetchEpisodes, onEpisodeTap: _onEpisodeTap,
    );
  }
}