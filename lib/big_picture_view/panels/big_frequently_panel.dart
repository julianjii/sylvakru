import 'package:material_ui/material_ui.dart';
import 'package:mymusic/base/data/history.dart';
import 'package:mymusic/base/my_audio_metadata.dart';

import 'package:mymusic/big_picture_view/panels/big_song_list_base_panel.dart';

class BigFrequentlyPanel extends StatelessWidget {
  const BigFrequentlyPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return _BigFrequentlySongListPanel();
  }
}

class _BigFrequentlySongListPanel extends BigSongListBasePanel {
  const _BigFrequentlySongListPanel();

  @override
  State<StatefulWidget> createState() => _BigFrequentlySongListPanelState();
}

class _BigFrequentlySongListPanelState extends BigSongListBasePanelState {
  @override
  List<MyAudioMetadata> get songList => history.frequentlySongList;

  @override
  bool get isFrequently => true;
}
