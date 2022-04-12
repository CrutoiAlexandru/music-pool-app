import 'package:flutter/material.dart';
import 'package:music_pool_app/global/global.dart';
import 'package:music_pool_app/ui/config.dart';
import 'package:provider/provider.dart';

// the ListView item for the youtube player in queue
Widget listItemYT(snapshot, context, index) {
  return Container(
    color: Colors.transparent,
    margin: const EdgeInsets.only(top: 10),
    child: TextButton(
      onPressed: () {
        // WHEN PRESSED JUST OPEN THE VIDEO PLAYER WITH AUTOPLAY ON
        if (!Provider.of<GlobalNotifier>(context, listen: false).playState ||
            Provider.of<GlobalNotifier>(context, listen: false).playing !=
                index) {
          Provider.of<GlobalNotifier>(context, listen: false).setPlaying(index);
          Provider.of<GlobalNotifier>(context, listen: false)
              .setPlayingState(true);
        } else {
          Provider.of<GlobalNotifier>(context, listen: false).setPlaying(-1);
          Provider.of<GlobalNotifier>(context, listen: false)
              .setPlayingState(false);
        }
      },
      style: TextButton.styleFrom(
        primary: Config.colorStyle,
        backgroundColor: Colors.transparent,
      ),
      child: Row(
        children: [
          Image.network(
            snapshot.data!.docs.toList()[index].data()['icon'],
            height: 40,
            width: 40,
            loadingBuilder: (BuildContext context, Widget child,
                ImageChunkEvent? loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            },
          ),
          const SizedBox(
            width: 10,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                snapshot.data!.docs.toList()[index].data()['track'],
                textScaleFactor: 1.25,
                style: index ==
                        Provider.of<GlobalNotifier>(context, listen: false)
                            .playing // not working to listen?
                    ? const TextStyle(
                        color: Config.colorStyle1,
                        overflow: TextOverflow.ellipsis)
                    : const TextStyle(
                        color: Color.fromARGB(200, 255, 255, 255),
                        overflow: TextOverflow.ellipsis,
                      ),
              ), // LIVE DATA UPDATE
              const SizedBox(height: 5),
            ],
          ),
        ],
      ),
    ),
  );
}
