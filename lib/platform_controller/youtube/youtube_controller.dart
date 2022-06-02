import 'package:flutter/foundation.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:http/http.dart';
import 'package:MusicPool/.config_for_app.dart';

// class that handles all methods concerning youtube: connection, data receiving
class YoutubeController {
  // client for connecting to google api
  static late Client httpClient;
  // client for connecting to the youtube api
  static late YouTubeApi youTubeApi;
  // the url from which the video is playing
  static const url = 'https://www.youtube.com/watch?v=';
  // google sign in requesting wanted scope(api)
  static final _googleSignIn = GoogleSignIn(
    scopes: <String>[YouTubeApi.youtubeReadonlyScope],
    clientId: GoogleConfig.clientID,
  );

  // method for authenticating to google and connecting to the youtube api
  static apiConnect() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
    }

    httpClient = (await _googleSignIn.authenticatedClient())!;

    youTubeApi = YouTubeApi(httpClient);
  }

  // method for disconnecting from the google and youtube api
  static apiDisconnect() async {
    try {
      await _googleSignIn.disconnect();
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
    }
  }

  // method for receiving a search list result for our query
  // gets the top [x] results for our video search
  static searchFor(String input) async {
    var list = await youTubeApi.search.list(
      ['id,snippet'],
      maxResults: 10,
      q: input,
    );
    // only return the items, this is the data we are interested in
    // video title and id
    // we get the id for the player later
    return list.items;
  }

  // method for retrieving the icon for out youtube video(based on the youtube video id)
  static getIcon(String videoId) async {
    var video = await youTubeApi.videos.list(
      ['snippet'],
      id: [videoId],
    );

    return video.items![0].snippet!.thumbnails!.default_?.url;
  }
}
