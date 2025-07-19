// Fixed YouTube Frame - Video will be visible
import 'package:flutter/material.dart';
import 'package:mobi_tv_entertainment/video_widget/custom_youtube_player_4k.dart';

class YoutubeeeFrame extends StatelessWidget {
  final String videoUrl;
  final Widget? child;
  final double? topBarHeight;
  final double? bottomBarHeight;
  final Color barColor;
  final bool showBars;

  const YoutubeeeFrame({
    Key? key,
    required this.videoUrl,
    this.child,
    this.topBarHeight,
    this.bottomBarHeight,
    this.barColor = Colors.black26,
    this.showBars = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final defaultBarHeight = screenHeight / 6;

    return Scaffold(
      backgroundColor: Colors.black, // Ensure black background
      body: Stack(
        children: [
          // 1. Video Player - Full screen (Bottom layer)
                    Container(color: Colors.black),
          
          // Video in center with constraints
          Center(
            child: AspectRatio(
              aspectRatio: 16/9,
              child: Container(
                // margin: EdgeInsets.symmetric(
                //   vertical: MediaQuery.of(context).size.height / 6
                // ),
                child: CustomYoutubePlayer(videoUrl: videoUrl),
              ),
            ),
          ),
          
          // // Top overlay - Force using Positioned
          // Positioned(
          //   top: 0,
          //   left: 0,
          //   right: 0,
          //   height: MediaQuery.of(context).size.height / 6,
          //   child: Container(
          //     color: Colors.black,
          //     child: IgnorePointer(child: SizedBox.expand()),
          //   ),
          // ),
          
          // // Bottom overlay
          // Positioned(
          //   bottom: 0,
          //   left: 0,
          //   right: 0,
          //   height: MediaQuery.of(context).size.height / 6,
          //   child: Container(
          //     color: Colors.black,
          //     child: IgnorePointer(child: SizedBox.expand()),
          //   ),
          // ),
        ],
      ),
    );
  }
}