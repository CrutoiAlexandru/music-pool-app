// Called when the Spotify Web Playback SDK is ready to use
window.logger = (token) => {
  // window.onSpotifyWebPlaybackSDKReady = () => {
  // window.onSpotifyPlayerAPIReady = () => {
  // Define the Spotify Connect device, getOAuthToken has an actual token
  // hardcoded for the sake of simplicity
  var player = new Spotify.Player({
    name: "A Spotify Web SDK Player",
    getOAuthToken: (callback) => {
      callback(token);
    },
    volume: 0.5,
  });

  // Called when connected to the player created beforehand successfully
  player.addListener("ready", ({ device_id }) => {
    console.log("Ready with Device ID", device_id);

    const play = ({
      spotify_uri,
      playerInstance: {
        _options: { getOAuthToken, id },
      },
    }) => {
      getOAuthToken((access_token) => {
        fetch(`https://api.spotify.com/v1/me/player/play?device_id=${id}`, {
          method: "PUT",
          body: JSON.stringify({ uris: [spotify_uri] }),
          headers: {
            "Content-Type": "application/json",
            Authorization: `Bearer ${access_token}`,
          },
        });
      });
    };

    play({
      playerInstance: player,
      spotify_uri: "spotify:track:7xGfFoTpQ2E7fRF5lN10tr",
    });
  });

  player.addListener("not_ready", ({ device_id }) => {
    console.log("Device ID has gone offline", device_id);
  });

  player.addListener("initialization_error", ({ message }) => {
    console.error(message);
  });

  player.addListener("authentication_error", ({ message }) => {
    console.error(message);
  });

  player.addListener("account_error", ({ message }) => {
    console.error(message);
  });

  // // Connect to the player created beforehand, this is equivalent to
  // // creating a new device which will be visible for Spotify Connect
  player.connect();
  // };
};
