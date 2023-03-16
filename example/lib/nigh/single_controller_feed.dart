import 'package:better_player/better_player.dart';
import 'package:better_player_example/nigh/nigh_video_player_controller.dart';
import 'package:better_player_example/nigh/simple_button.dart';
import 'package:flutter/material.dart';

class SingleControllerFeed extends StatefulWidget {
  const SingleControllerFeed({
    required this.videoList,
    required this.onReset,
    Key? key,
  }) : super(key: key);

  final List<String> videoList;
  final void Function() onReset;

  @override
  State<SingleControllerFeed> createState() => _SingleControllerFeedState();
}

class _SingleControllerFeedState extends State<SingleControllerFeed> {
  int videoIndex = 0;
  bool pendingRestart = false;
  NighVideoPlayerController? activeController;

  @override
  void initState() {
    super.initState();
    loadNextVideo();
  }

  @override
  void dispose() {
    activeController?.dispose(forceDispose: true);
    super.dispose();
  }

  void onVideoEvent(
      NighVideoPlayerController controller, BetterPlayerEvent event) {
    bool shouldLog = true;
    switch (event.betterPlayerEventType) {
      case BetterPlayerEventType.initialized:
        if (controller == activeController) {
          controller!.play();
          setState(() {});
        }
        break;
      case BetterPlayerEventType.exception:
        Map<String, dynamic?>? maybeDetail = event.parameters?['exception'];
        if (maybeDetail != null &&
            (maybeDetail as String) ==
                'Failed to load video: Segment exceeds specified bandwidth for variant') {
          shouldLog = false;
        }
        break;
      case BetterPlayerEventType.finished:
        if (pendingRestart) {
          loadNextVideo();
        } else {
          pendingRestart = true;
        }
        break;
      case BetterPlayerEventType.progress:
        if (controller != activeController) {
          shouldLog = false;
        } else {
          var maybeProgress = event.parameters?['progress'] as Duration?;
          var maybeDuration = event.parameters?['duration'] as Duration?;
          if (maybeProgress != null &&
              maybeDuration != null &&
              (maybeProgress > maybeDuration)) {
            print('Seeking to beginning of video...');
            controller.seekTo(Duration.zero);
          }

          if (maybeProgress != null &&
              maybeDuration != null &&
              (maybeProgress + Duration(milliseconds: 1500) > maybeDuration)) {
            pendingRestart = true;
          } else if ((maybeProgress?.inSeconds ?? 0) > 2) {
            if (pendingRestart) {
              loadNextVideo();
            }
          }
        }
        break;
      default:
      // pass
    }
    if (shouldLog) {
      print(
          '[${DateTime.now().toIso8601String()}] BetterPlayerEvent: ${controller.dataSourceUrl} ${event.betterPlayerEventType} | ${event.parameters}');
    }
  }

  void loadNextVideo() async {
    if (activeController?.isInitialized ?? false) {
      await activeController?.pause();
    }
    activeController?.dispose(forceDispose: true);

    pendingRestart = false;
    videoIndex += 1;
    if (videoIndex >= widget.videoList.length) {
      videoIndex = 0;
    }

    activeController =
        NighVideoPlayerController.network(widget.videoList[videoIndex]);
    activeController!
        .addEventsListener((event) => onVideoEvent(activeController!, event));

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (activeController?.isInitialized ?? false) {
      return Column(
        children: [
          Spacer(),
          SimpleButton(
            text: 'Single-Controller Better Player: Back to Selector',
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
                activeController!.isPlaying() ?? true
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
          BetterPlayer(controller: activeController!),
          Spacer(),
        ],
      );
    } else {
      return const Text('Loading...');
    }
  }
}
