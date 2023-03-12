import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';

const hundredMb = 100 * 1024 * 1024;

class NighVideoPlayerController extends BetterPlayerController {
  static const Duration durationFromEndToTriggerCompletion =
      Duration(milliseconds: 500);

  NighVideoPlayerController.network_(
      BetterPlayerConfiguration playerConfig, BetterPlayerDataSource dataSource)
      : super(playerConfig, betterPlayerDataSource: dataSource);

  factory NighVideoPlayerController.network(String videoUrl) {
    bool canUseCache = true;

    final BetterPlayerConfiguration playerConfig = BetterPlayerConfiguration(
      looping: true,
      fit: BoxFit.cover,
      autoDispose: false,
      allowedScreenSleep: false,
      aspectRatio: 9 / 16,
      controlsConfiguration: const BetterPlayerControlsConfiguration(
        enablePip: false,
        enableSkips: false,
        enableMute: false,
        enableSubtitles: false,
        enablePlaybackSpeed: false,
        enableOverflowMenu: false,
        enableFullscreen: false,
        enableProgressText: false,
        enableProgressBarDrag: false,
        showControls: false,
        showControlsOnInitialize: false,
      ),
    );

    final BetterPlayerDataSource dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      videoUrl,
      useAsmsTracks: false,
      useAsmsSubtitles: false,
      useAsmsAudioTracks: false,
      cacheConfiguration: BetterPlayerCacheConfiguration(
        key: videoUrl,
        useCache: canUseCache,
        preCacheSize: hundredMb,
        maxCacheSize: hundredMb,
        maxCacheFileSize: hundredMb,
      ),
      bufferingConfiguration: const BetterPlayerBufferingConfiguration(
        minBufferMs: 1000,
        maxBufferMs: 4000,
        bufferForPlaybackMs: 500,
        bufferForPlaybackAfterRebufferMs: 1000,
      ),
    );

    var controller = NighVideoPlayerController.network_(
      playerConfig,
      dataSource,
    );

    controller.addEventsListener((BetterPlayerEvent event) async {
      if (event.betterPlayerEventType == BetterPlayerEventType.progress) {
        controller.updateVideoProgress_();
      }
    });

    return controller;
  }

  bool get isInitialized {
    return videoPlayerController?.value.initialized ?? false;
  }

  List<Function(int)> videoCompletionListeners = [];
  Duration lastProgress = Duration.zero;
  int currentLoop = 0;
  int lastCompleteLoop = -1;
  int activeSeeks = 0;

  VideoPlayerValue get value {
    return videoPlayerController!.value;
  }

  String? get dataSourceUrl {
    return betterPlayerDataSource?.url;
  }

  void updateVideoProgress_() {
    if (videoPlayerController?.value.duration != null) {
      Duration totalDuration = videoPlayerController!.value.duration!;
      Duration currentProgress = videoPlayerController!.value.position;
      if (activeSeeks > 0) {
        return;
      }

      bool isApproximatelyComplete = totalDuration > Duration.zero &&
          currentProgress + durationFromEndToTriggerCompletion > totalDuration;

      if (currentProgress < lastProgress) {
        if (currentLoop > lastCompleteLoop) {
          onComplete_();
        }

        currentLoop += 1;
      } else if (isApproximatelyComplete && lastCompleteLoop < currentLoop) {
        onComplete_();
      }

      lastProgress = currentProgress;
    }
  }

  // Future<void>? pauseIfActive() async {
  //   if (isInitialized || !isDisposed) {
  //     await pause();
  //   }
  // }

  void onComplete_() {
    lastCompleteLoop = currentLoop;
    for (var callback in videoCompletionListeners) {
      callback(currentLoop);
    }
  }

  void onVideoCompletion(Function(int) callback) {
    videoCompletionListeners.add(callback);
  }

  Future<void> resetProgress() {
    currentLoop = 0;
    lastCompleteLoop = -1;
    return seekTo(Duration.zero);
  }

  @override
  Future<void> seekTo(Duration moment) async {
    activeSeeks++;
    lastProgress = moment;
    if (isInitialized) {
      return super.seekTo(moment).then((value) => activeSeeks--);
    }
  }
}
