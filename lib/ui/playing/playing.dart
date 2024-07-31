import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_example/data/model/song.dart';

class Playing extends StatelessWidget {
  const Playing({
    super.key,
    required this.songs,
    required this.song,
  });

  final Song song;
  final List<Song> songs;

  @override
  Widget build(BuildContext context) {
    return PlayingPage(songs: songs, song: song);
  }
}

class PlayingPage extends StatefulWidget {
  const PlayingPage({
    super.key,
    required this.songs,
    required this.song,
  });
  final List<Song> songs;
  final Song song;
  @override
  State<PlayingPage> createState() => _PlayingPageState();
}

class _PlayingPageState extends State<PlayingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 12000),
    );
  }

  @override
  Widget build(BuildContext context) {
    final widthScreen = MediaQuery.of(context).size.width;
    const delta = 64;
    final radius = (widthScreen - delta) / 2;
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text("Playing"),
        trailing: Icon(Icons.more_horiz),
      ),
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(widget.song.album),
              const SizedBox(
                height: 16,
              ),
              const Text("_ ___ _"),
              const SizedBox(
                height: 48,
              ),
              RotationTransition(
                turns:
                    Tween(begin: 0.0, end: 1.0).animate(_animationController),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(radius),
                  child: FadeInImage.assetNetwork(
                    placeholder: 'assets/iconIturn.png',
                    image: widget.song.image,
                    width: widthScreen - delta,
                    height: widthScreen - delta,
                    imageErrorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        "assets/iconIturn.png",
                        width: widthScreen - delta,
                        height: widthScreen - delta,
                      );
                    },
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
