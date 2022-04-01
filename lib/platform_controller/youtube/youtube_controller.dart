// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:googleapis/youtube/v3.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:music_pool_app/.config_for_app.dart';

class YoutubeController {
  var httpClient;
  var youTubeApi;
  final _googleSignIn = GoogleSignIn(
    scopes: <String>[YouTubeApi.youtubeReadonlyScope],
    clientId: GoogleConfig.clientID,
  );

  // auth to google and connect to youtube api
  apiConnect() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      print(error);
    }

    httpClient = (await _googleSignIn.authenticatedClient())!;

    youTubeApi = YouTubeApi(httpClient);

    var list = await searchFor('only you freestyle');

    for (int i = 0; i < 5; i++) {
      print(list[i].snippet.title);
      print(list[i].id.videoId);

      var video = await getVideo(list[i].id.videoId);
      print(video[0].contentDetails.duration);
    }
  }

  // get a search list result for our query
  searchFor(String input) async {
    var list = await youTubeApi.search.list(
      ['id,snippet'],
      q: input,
    );
    // only return the items, this is the data we are interested in
    // video title and id
    // we get the id for the player later
    return list.items;
  }

  // get video data for specific videoId got by ^ upper search method
  getVideo(String videoId) async {
    var video = await youTubeApi.videos.list(
      ['id,snippet,player,contentDetails'],
      id: [videoId],
    );

    return video.items;
  }
}
