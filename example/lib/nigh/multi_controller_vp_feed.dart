import 'package:video_player/video_player.dart';
import 'package:better_player_example/nigh/simple_button.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class MultiControllerVideoPlayerFeed extends StatefulWidget {
  const MultiControllerVideoPlayerFeed({
    required this.videoList,
    required this.onReset,
    Key? key,
  }) : super(key: key);

  final List<String> videoList;
  final void Function() onReset;

  @override
  State<MultiControllerVideoPlayerFeed> createState() =>
      _MultiControllerVideoPlayerFeedState();
}

class _MultiControllerVideoPlayerFeedState
    extends State<MultiControllerVideoPlayerFeed> {
  int videoIndex = 0;
  bool pendingRestart = false;
  List<VideoPlayerController>? controllers;

  @override
  void initState() {
    super.initState();
    loadControllers();
  }

  @override
  void dispose() {
    controllers?.forEach((controller) => controller.dispose());
    super.dispose();
  }

  void loadControllers() {
    controllers = widget.videoList.mapIndexed((index, url) {
      var playerController =
          VideoPlayerController.network(widget.videoList[index]);
      playerController.addListener(() => onVideoEvent(playerController));
      playerController.initialize();
      return playerController;
    }).toList();
  }

  void onVideoEvent(VideoPlayerController controller) {
    if (controller == activeController) {
      if (!controller.value.isPlaying && controller.value.isInitialized) {
        print('Playing video');
        controller.play();
        controller.setLooping(true);
        setState(() {});
      } else if (controller.value.position > Duration(seconds: 5)) {
        print('Marking pending restart');
        pendingRestart = true;
      } else if (pendingRestart &&
          controller.value.position > Duration(seconds: 2)) {
        print('Loading next video');
        loadNextVideo();
      }
    } else if (controller.value.isPlaying) {
      controller.pause();
    }
  }

  void loadNextVideo() async {
    if (activeController?.value.isInitialized ?? false) {
      await activeController!.seekTo(Duration.zero);
      activeController!.pause();
    }

    pendingRestart = false;
    videoIndex += 1;
    if (videoIndex >= widget.videoList.length) {
      videoIndex = 0;
    }

    if (activeController?.value.isInitialized ?? false) {
      activeController!.play();
    }
    setState(() {});
  }

  VideoPlayerController? get activeController {
    return controllers?[videoIndex];
  }

  @override
  Widget build(BuildContext context) {
    if (activeController?.value.isInitialized ?? false) {
      return Column(
        children: [
          Spacer(),
          SimpleButton(
            text: 'Multi-Controller Video Player: Back to Selector',
            onTap: widget.onReset,
          ),
          SimpleButton(
            text: 'Swap Video',
            onTap: loadNextVideo,
          ),
          SimpleButton(
            text: 'Play/Pause',
            onTap: () {
              if (activeController != null) {
                activeController!.value.isPlaying
                    ? activeController!.pause()
                    : activeController!.play();
              }
            },
          ),
          // VideoProgressIndicator(
          //   activeController!.videoPlayerController!,
          //   allowScrubbing: false,
          //   colors: VideoProgressColors(
          //     backgroundColor: Colors.white54,
          //     playedColor: Colors.white,
          //   ),
          // ),
          Container(
            constraints: BoxConstraints.expand(
              width: 270,
              height: 480,
            ),
            child: VideoPlayer(activeController!),
          ),
          Spacer(),
        ],
      );
    } else {
      return const Text('Loading...');
    }
  }
}
