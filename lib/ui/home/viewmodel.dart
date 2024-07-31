import 'dart:async';

import 'package:flutter_example/data/model/song.dart';
import 'package:flutter_example/data/repository/repository.dart';

class MusicAppViewModel {
  StreamController<List<Song>> streamController = StreamController();
  void loadSongs() {
    final repository = DefaultRepository();
    repository.loadData().then((value) => streamController.add(value!));
  }
}
