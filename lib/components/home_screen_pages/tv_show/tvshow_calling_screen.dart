import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as https;
import 'package:mobi_tv_entertainment/components/widgets/smart_show_details_screen.dart';
import 'package:mobi_tv_entertainment/main.dart';
import 'package:mobi_tv_entertainment/components/services/history_service.dart';
import 'package:mobi_tv_entertainment/components/video_widget/video_screen.dart';

class TvShowCallingScreen extends StatefulWidget {
  final int showId; final String showName; final String bannerUrl;
  const TvShowCallingScreen({Key? key, required this.showId, required this.showName, required this.bannerUrl}) : super(key: key);
  @override
  State<TvShowCallingScreen> createState() => _TvShowCallingScreenState();
}

class _TvShowCallingScreenState extends State<TvShowCallingScreen> {
  Future<List<CommonSeasonModel>> fetchSeasons() async {
    var url = Uri.parse(SessionManager.baseUrl + 'getShowSeasons/${widget.showId}');
    final response = await https.get(url, headers: {'auth-key': SessionManager.authKey, 'domain': SessionManager.savedDomain});
    final List<dynamic> data = jsonDecode(response.body);
    return data.where((m) => m['status'] == 1).map((item) => CommonSeasonModel(
      id: item['id'].toString(), title: item['title'] ?? 'Season',
      order: item['id'] ?? 1, bannerUrl: item['poster'] ?? '', originalData: item
    )).toList();
  }

  Future<List<CommonEpisodeModel>> fetchEpisodes(String seasonId) async {
    var url = Uri.parse(SessionManager.baseUrl + 'getShowSeasonsEpisodes/$seasonId');
    final response = await https.get(url, headers: {'auth-key': SessionManager.authKey, 'domain': SessionManager.savedDomain});
    final List<dynamic> data = jsonDecode(response.body);
    return data.where((m) => m['status'] == 1).map((item) => CommonEpisodeModel(
      id: item['id'].toString(), title: item['title'] ?? 'Episode', description: item['description'] ?? '',
      imageUrl: item['thumbnail'] ?? '', order: item['episode_number'] ?? 0, originalData: item
    )).toList();
  }

  Future<void> _onEpisodeTap(CommonEpisodeModel episode) async {
    final epData = episode.originalData;
    String playUrl = epData['video_url'] ?? '';
    
    try { await HistoryService.updateUserHistory(userId: SessionManager.userId!, contentType: 4, eventId: int.parse(episode.id), eventTitle: episode.title, url: playUrl, categoryId: 0); } catch (e) {}

    await Navigator.push(context, MaterialPageRoute(builder: (context) => VideoScreen(
      videoUrl: playUrl, bannerImageUrl: episode.imageUrl, channelList: const [], source: 'isTvShow', videoId: int.parse(episode.id), name: episode.title, liveStatus: false, updatedAt: epData['updated_at'] ?? '', streamType: epData['streaming_type'] ?? ''
    )));
  }

  @override
  Widget build(BuildContext context) {
    return SmartShowDetailsScreen(
      showName: widget.showName, bannerUrl: widget.bannerUrl, focusIdentifier: 'tvShowDetails',
      fetchSeasons: fetchSeasons, fetchEpisodes: fetchEpisodes, onEpisodeTap: _onEpisodeTap,
    );
  }
}