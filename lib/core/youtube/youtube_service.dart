import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class YouTubeService {
  final yt = YoutubeExplode();

  Future<String> getStreamUrl(String url) async {
    final video = await yt.videos.get(url);

    final manifest =
        await yt.videos.streamsClient.getManifest(video.id);

    final streamInfo =
        manifest.muxed.withHighestBitrate();

    return streamInfo.url.toString();
  }
}
