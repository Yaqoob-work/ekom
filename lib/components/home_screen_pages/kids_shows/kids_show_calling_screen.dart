import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as https;
import 'package:mobi_tv_entertainment/components/widgets/smart_show_details_screen.dart';
import 'package:mobi_tv_entertainment/main.dart';
import 'package:mobi_tv_entertainment/components/services/history_service.dart';
import 'package:mobi_tv_entertainment/components/video_widget/video_screen.dart';
import 'package:mobi_tv_entertainment/components/video_widget/custom_youtube_player.dart';
// Upar wale Generic Model aur Master UI widget ko import karein...

class KidsShowCallingScreen extends StatefulWidget {
  final int showId; final String showName; final String bannerUrl;
  const KidsShowCallingScreen({Key? key, required this.showId, required this.showName, required this.bannerUrl}) : super(key: key);
  @override
  State<KidsShowCallingScreen> createState() => _KidsShowCallingScreenState();
}

class _KidsShowCallingScreenState extends State<KidsShowCallingScreen> {

  Future<List<CommonSeasonModel>> fetchSeasons() async {
    var url = Uri.parse(SessionManager.baseUrl + 'getKidsShowSeasons/${widget.showId}');
    final response = await https.get(url, headers: {'auth-key': SessionManager.authKey, 'domain': SessionManager.savedDomain});
    final List<dynamic> data = jsonDecode(response.body);
    return data.where((m) => m['status'] == 1).map((item) => CommonSeasonModel(
      id: item['id'].toString(), title: item['season_name'] ?? 'Season',
      order: item['season_order'] ?? 1, bannerUrl: item['banner'] ?? '', originalData: item
    )).toList();
  }

  Future<List<CommonEpisodeModel>> fetchEpisodes(String seasonId) async {
    var url = Uri.parse(SessionManager.baseUrl + 'getKidsShowSeasonsEpisodes/$seasonId');
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
    String source = epData['source'] ?? 'youtube';

    try { await HistoryService.updateUserHistory(userId: SessionManager.userId!, contentType: 4, eventId: int.parse(episode.id), eventTitle: episode.title, url: playUrl, categoryId: 0); } catch (e) {}

    if (source.toLowerCase() == 'youtube') {
      await Navigator.push(context, MaterialPageRoute(builder: (context) => CustomYoutubePlayer(
        videoData: VideoData(id: playUrl, title: episode.title, youtubeUrl: playUrl, thumbnail: episode.imageUrl, description: episode.description), playlist: []
      )));
    } else {
      await Navigator.push(context, MaterialPageRoute(builder: (context) => VideoScreen(
        videoUrl: playUrl, bannerImageUrl: episode.imageUrl, channelList: const [], source: 'isKidsShow', videoId: int.parse(episode.id), name: episode.title, liveStatus: false, updatedAt: '', streamType: ''
      )));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SmartShowDetailsScreen(
      showName: widget.showName, bannerUrl: widget.bannerUrl, focusIdentifier: 'kidsShowDetails',
      fetchSeasons: fetchSeasons, fetchEpisodes: fetchEpisodes, onEpisodeTap: _onEpisodeTap,
    );
  }
}