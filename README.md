# MusicPoolApp

## Goal of the app

MusicPoolApp is an application for joining multiple anonymous(at the moment) users in a public session where they can play audio/video sources in a queue from multiple platforms.

The main goal of the application is the public session that is able to join multiple platforms in one place.

### Why?

When playing music, either at a party or in the car, etc... I personally find it very annoying that you can't play the songs as a group or from different platform(Spotify allows group sessions but can't connect with other platforms).

The currently supported platforms are:

- Spotify
- YouTube

## How do you get the app?

At the moment there is no release version for the application, besides that at the moment it does not have an expanded quota from Spotify or the GoogleAPI. This means the only users able to test the app are manually declared users by the owner of the applications(me).

If you would want to use the application I would have to add the user to the limited testing users.

Also the application needs a `.dart` file for the secret client details(meant for Spotify and GoogleAPI login) of the application, this of course is only needed in case you want to clone the repository and build the app yourself.

In the future there will be a release version after fixing a release issue.

## How the app looks and is used

The application U.I. contains on the main page a header showing the current session the user is in, if he is in no session then the name of the application is displayed.

### What is this "session"?

This session is basically a list contained on the Firebase database Firestore. This database holds multiple folders(the session, with the identifier being the `code` generated in the application), each session containing multiple files(the data for the `audio`/`video` sources used to play in the app).

---

Under the header there is a button for adding the audio/video sources from a chosen platform(via a popup window).

---

Also on the main page there is a list and a player, the list displays the list of audio/video sources held on the database, meaning the items in queue. The player is platform based and for each platform show a certain display of data concerning the items playing.

- For Spotify the player displays:
  -- the icon, name and artist of the song
  -- a play/pause button and a progress bar
  -- a button for raising the mini player into a bigger player(second page) that also shows the skip options(previous/next)

- For YouTube the player displays:
  -- the video player
  -- the skip/previous buttons
  -- the title of the video

---

On the left of the page there is a drawer, this options drawer allows the user to:

- Create a session(with a randomly generated `code`)
- Join a custom session(with a user introduced code)
- Empty the current session of all its contents(deletes all data from the session on the database)
- Leave the current session

- Log in to one of the platforms(via a popup window)
- Log out of one of the platforms(via a popup window)

## Main components

The main components this app would not work without are:

- The Firebase database and free hosting(for the web app)
- The Provider, a library from Flutter made for live updates across multiple pages/widgets
- The GoogleAPI library, this makes using the YoutubeApi easy
- The SpotifySDK and SpotifyWebSDK

## Getting Started with flutter

A few resources to get you started if this is the first time you use flutter:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
