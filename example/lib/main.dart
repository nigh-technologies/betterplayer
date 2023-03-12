import 'package:better_player_example/nigh/multi_controller_feed.dart';
import 'package:better_player_example/nigh/simple_button.dart';
import 'package:better_player_example/nigh/single_controller_feed.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shortcuts(
        shortcuts: <LogicalKeySet, Intent>{
          LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
        },
        child: MaterialApp(
          title: 'Better player demo',
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: [
            const Locale('en', 'US'),
            const Locale('pl', 'PL'),
          ],
          theme: ThemeData(
            primarySwatch: Colors.green,
          ),
          home: MyWidget(),
        ));
  }
}

enum FeedVersion {
  single,
  multi,
}

class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  static const List<String> videoList = [
    'https://d3kka8xq7lpxgb.cloudfront.net/videos/4e77a60f-adf5-4bd8-b9c9-a6538147dad8/playlist.m3u8',
    'https://d1hkrdhrucu1j5.cloudfront.net/videos/f7f56c43-79d5-437d-a7ec-f0d697549ce2/playlist.m3u8',
    'https://d1hkrdhrucu1j5.cloudfront.net/videos/858b2e0a-507a-40f0-8c55-634246e139b8/playlist.m3u8',
    'https://d1hkrdhrucu1j5.cloudfront.net/videos/48c4af05-440b-418b-a02e-81ff7e6e2620/playlist.m3u8',
    'https://d1hkrdhrucu1j5.cloudfront.net/videos/14ce8c54-0223-438f-99a5-747e18c398d5/playlist.m3u8',
    'https://d1hkrdhrucu1j5.cloudfront.net/videos/24a5efad-67a4-423e-8be9-a6599a75ea48/playlist.m3u8',
    'https://d1hkrdhrucu1j5.cloudfront.net/videos/034540a9-67a9-4f41-b803-ba31d82a3383/playlist.m3u8',
    'https://d1hkrdhrucu1j5.cloudfront.net/videos/68b4bf9d-0266-4ce1-997d-4564e64bc1d4/playlist.m3u8',
    'https://d1hkrdhrucu1j5.cloudfront.net/videos/6d1bbdce-04db-47ec-8b16-4908e8451b15/playlist.m3u8',
    'https://d1hkrdhrucu1j5.cloudfront.net/videos/f7f56c43-79d5-437d-a7ec-f0d697549ce2/playlist.m3u8',
    'https://d1hkrdhrucu1j5.cloudfront.net/videos/ab7f096e-4abc-46c2-aee1-4d839e7a264c/playlist.m3u8',
    'https://d1hkrdhrucu1j5.cloudfront.net/videos/50243518-1900-4cd0-aa4c-61ee3b6bc9c3/playlist.m3u8',
    'https://d1hkrdhrucu1j5.cloudfront.net/videos/dba8088d-5d77-4564-9a4e-df79c4350a1a/playlist.m3u8',
    'https://d1hkrdhrucu1j5.cloudfront.net/videos/3cbf2c64-8736-4f09-84ed-0d9134b0c556/playlist.m3u8',
  ];

  FeedVersion? feedVersion;

  void resetSelection() {
    setState(() {
      feedVersion = null;
    });
  }

  Widget typeSelector() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SimpleButton(
          text: 'Single',
          onTap: () {
            setState(() {
              feedVersion = FeedVersion.single;
            });
          },
        ),
        SimpleButton(
          text: 'Multi',
          onTap: () {
            setState(() {
              feedVersion = FeedVersion.multi;
            });
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (feedVersion) {
      case FeedVersion.single:
        return SingleControllerFeed(
          videoList: videoList,
          onReset: resetSelection,
        );
      case FeedVersion.multi:
        return MultiControllerFeed(
          videoList: videoList,
          onReset: resetSelection,
        );
      case null:
        return typeSelector();
    }
  }
}
