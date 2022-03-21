import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:music_pool_app/global/global.dart';
import 'package:music_pool_app/global/session/session.dart';
import 'package:music_pool_app/ui/config.dart';
import 'package:provider/provider.dart';

class Second extends StatefulWidget {
  const Second({Key? key}) : super(key: key);

  @override
  State<Second> createState() => _Second();
}

class _Second extends State<Second> {
  // const Second({Key? key}) : super(key: key);
  var database;
  int index = -1;

  @override
  void initState() {
    database = FirebaseFirestore.instance.collection('default').snapshots();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (Provider.of<SessionNotifier>(context).session.isNotEmpty) {
      database = FirebaseFirestore.instance
          .collection(Provider.of<SessionNotifier>(context).session)
          .snapshots();
    } else {
      database = FirebaseFirestore.instance.collection('default').snapshots();
    }

    index = Provider.of<GlobalNotifier>(context).playing;

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(25), topRight: Radius.circular(25)),
            child: SizedBox(
              height: MediaQuery.of(context).size.height - 50,
              child: Scaffold(
                backgroundColor: Colors.black,
                body: Column(
                  children: [
                    Center(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          primary: Colors.transparent,
                          fixedSize: const Size(double.maxFinite, 60),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Icon(
                          Icons.arrow_drop_down_sharp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    StreamBuilder(
                      stream: database,
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (snapshot.hasError) {
                          return const Text('Something went wrong',
                              textAlign: TextAlign.center);
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const SizedBox(
                            height: 80,
                            child: Text('loading', textAlign: TextAlign.center),
                          );
                        }

                        if (snapshot.data.docs.isEmpty || index == -1) {
                          return const SizedBox();
                        }

                        return Column(
                          children: [
                            Hero(
                              tag: 'icon',
                              child: Center(
                                child: Image.network(
                                  snapshot.data!.docs
                                      .toList()[index]
                                      .data()['icon'],
                                  width: MediaQuery.of(context).size.width < 600
                                      ? MediaQuery.of(context).size.width - 20
                                      : 580,
                                  loadingBuilder: (BuildContext context,
                                      Widget child,
                                      ImageChunkEvent? loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!
                                            : null,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Hero(
                              tag: 'track',
                              child: Text(
                                snapshot.data!.docs
                                    .toList()[index]
                                    .data()['track'],
                                textScaleFactor: 2,
                                style: const TextStyle(
                                  color: Color.fromARGB(230, 255, 255, 255),
                                  overflow: TextOverflow.clip,
                                ),
                              ),
                            ),
                            Hero(
                              tag: 'artist',
                              child: Text(
                                snapshot.data!.docs
                                    .toList()[index]
                                    .data()['artist'],
                                style: const TextStyle(
                                  color: Color.fromARGB(150, 255, 255, 255),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton(
                                  style: TextButton.styleFrom(
                                    primary: Config.colorStyle,
                                  ),
                                  onPressed: () {},
                                  child: const Icon(
                                    Icons.skip_previous,
                                    color: Colors.white,
                                    size: 50,
                                  ),
                                ),
                                const SizedBox(width: 40),
                                TextButton(
                                  style: TextButton.styleFrom(
                                    primary: Config.colorStyle,
                                  ),
                                  onPressed: () {},
                                  child: const Icon(
                                    Icons.play_arrow,
                                    color: Colors.white,
                                    size: 50,
                                  ),
                                ),
                                // CONSIDERING PLAY STATE, DECIDE IF SHOW PAUSE OR PLAY
                                // TextButton(
                                //   style: TextButton.styleFrom(
                                //     primary: Config.colorStyle,
                                //   ),
                                //   onPressed: () {},
                                //   child: const Icon(
                                //     Icons.pause,
                                //     color: Colors.white,
                                //     size: 50,
                                //   ),
                                // ),
                                const SizedBox(width: 40),
                                TextButton(
                                  style: TextButton.styleFrom(
                                    primary: Config.colorStyle,
                                  ),
                                  onPressed: () {},
                                  child: const Icon(
                                    Icons.skip_next,
                                    color: Colors.white,
                                    size: 50,
                                  ),
                                )
                              ],
                            )
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 100),
                    const LinearProgressIndicator(
                      value: 1,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
