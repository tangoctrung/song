import 'dart:math';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_example/data/model/song.dart';
import 'package:flutter_example/ui/playing/audio_player_manager.dart';
import 'package:just_audio/just_audio.dart';

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
  late AudioPlayerManager _audioPlayerManager;
  late int _indexSong;
  late Song _song;
  late double _currentAnimationPosition;
  bool _isShuffle = false;

  @override
  void initState() {
    super.initState();
    _currentAnimationPosition = 0.0;
    _song = widget.song;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 12000),
    );
    _audioPlayerManager = AudioPlayerManager(songUrl: _song.source);
    _audioPlayerManager.init();
    _indexSong = widget.songs.indexOf(_song);
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
              Text(_song.album),
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
                    image: _song.image,
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
              ),
              Padding(
                padding: const EdgeInsets.only(top: 64, bottom: 16),
                child: SizedBox(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.share_outlined),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      Column(
                        children: [
                          Text(
                            _song.title,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .color),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Text(
                            _song.artist,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .color),
                          )
                        ],
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.favorite_outline),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    top: 32, left: 24, right: 24, bottom: 16),
                child: _progressBar(),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    top: 32, left: 24, right: 24, bottom: 16),
                child: _mediaButtons(),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayerManager.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Widget _mediaButtons() {
    return SizedBox(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          MediaButtonControl(
              function: _setShuffle,
              icon: Icons.shuffle,
              color: _getShuffleColor(),
              size: 24),
          MediaButtonControl(
              function: _setPrevSong,
              icon: Icons.skip_previous,
              color: Colors.black,
              size: 36),
          _playButton(),
          MediaButtonControl(
              function: _setNextSong,
              icon: Icons.skip_next,
              color: Colors.black,
              size: 36),
          const MediaButtonControl(
              function: null,
              icon: Icons.repeat,
              color: Colors.deepPurple,
              size: 24),
        ],
      ),
    );
  }

  StreamBuilder<DurationState> _progressBar() {
    return StreamBuilder<DurationState>(
        stream: _audioPlayerManager.durationState,
        builder: (context, snapshot) {
          final durationState = snapshot.data;
          final progress = durationState?.progress ?? Duration.zero;
          final buffered = durationState?.buffered ?? Duration.zero;
          final total = durationState?.total ?? Duration.zero;
          return ProgressBar(
            progress: progress,
            total: total,
            buffered: buffered,
            onSeek: _audioPlayerManager.player.seek,
            barHeight: 5.0,
            barCapShape: BarCapShape.round,
            baseBarColor: Colors.grey.withOpacity(0.3),
            progressBarColor: Colors.green,
            bufferedBarColor: Colors.grey.withOpacity(0.3),
            thumbColor: Colors.deepPurple,
            thumbGlowColor: Colors.green.withOpacity(0.3),
            thumbRadius: 10.0,
          );
        });
  }

  StreamBuilder<PlayerState> _playButton() {
    return StreamBuilder(
      stream: _audioPlayerManager.player.playerStateStream,
      builder: (context, snapshot) {
        final playState = snapshot.data;
        final processingState = playState?.processingState;
        final playing = playState?.playing;
        if (processingState == ProcessingState.loading ||
            processingState == ProcessingState.buffering) {
          _pauseAnimation();
          return Container(
            margin: const EdgeInsets.all(8),
            width: 48,
            height: 48,
            child: const CircularProgressIndicator(),
          );
        } else if (playing != true) {
          return MediaButtonControl(
              function: () {
                _audioPlayerManager.player.play();
              },
              icon: Icons.play_arrow,
              color: null,
              size: 48);
        } else if (processingState != ProcessingState.completed) {
          _playAnimation();
          return MediaButtonControl(
              function: () {
                _audioPlayerManager.player.pause();
                _pauseAnimation();
              },
              icon: Icons.pause,
              color: null,
              size: 48);
        } else {
          if (processingState == ProcessingState.completed) {
            _stopAnimation();
            _resetAnimation();
          }
          return MediaButtonControl(
              function: () {
                _audioPlayerManager.player.seek(Duration.zero);
                _resetAnimation();
                _playAnimation();
              },
              icon: Icons.replay,
              color: null,
              size: 48);
        }
      },
    );
  }

  void _setShuffle() {
    setState(() {
      _isShuffle = !_isShuffle;
    });
  }

  Color? _getShuffleColor() {
    return _isShuffle ? Colors.deepPurple : Colors.grey;
  }

  void _setNextSong() {
    if (_isShuffle) {
      var random = Random();
      _indexSong = random.nextInt(widget.songs.length);
    } else {
      ++_indexSong;
    }
    if (_indexSong > widget.songs.length - 1) {
      _indexSong = 0;
    }
    final nextSong = widget.songs[_indexSong];
    _audioPlayerManager.updateSongUrl(nextSong.source);
    _resetAnimation();
    setState(() {
      _song = nextSong;
    });
  }

  void _setPrevSong() {
    if (_isShuffle) {
      var random = Random();
      _indexSong = random.nextInt(widget.songs.length);
    } else {
      --_indexSong;
    }
    if (_indexSong < 0) {
      _indexSong = widget.songs.length - 1;
    }
    final nextSong = widget.songs[_indexSong];
    _audioPlayerManager.updateSongUrl(nextSong.source);
    _resetAnimation();
    setState(() {
      _song = nextSong;
    });
  }

  void _playAnimation() {
    _animationController.forward(from: _currentAnimationPosition);
    _animationController.repeat();
  }

  void _stopAnimation() {
    _animationController.stop();
  }

  void _pauseAnimation() {
    _stopAnimation();
    _currentAnimationPosition = _animationController.value;
  }

  void _resetAnimation() {
    _currentAnimationPosition = 0.0;
    _animationController.value = _currentAnimationPosition;
  }
}

class MediaButtonControl extends StatefulWidget {
  const MediaButtonControl({
    super.key,
    required this.function,
    required this.icon,
    required this.color,
    required this.size,
  });
  final void Function()? function;
  final IconData icon;
  final double? size;
  final Color? color;

  @override
  State<StatefulWidget> createState() => _MediaButtonControlState();
}

class _MediaButtonControlState extends State<MediaButtonControl> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: widget.function,
      icon: Icon(widget.icon),
      iconSize: widget.size,
      color: widget.color ?? Theme.of(context).colorScheme.primary,
    );
  }
}
