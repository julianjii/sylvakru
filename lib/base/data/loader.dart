import 'dart:convert';
import 'dart:io';

import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:mymusic/base/audio_handler.dart';
import 'package:mymusic/base/data/config.dart';
import 'package:mymusic/base/data/artist_album.dart';
import 'package:mymusic/base/data/font_manager.dart';
import 'package:mymusic/base/services/bookmark_service.dart';
import 'package:mymusic/base/app.dart';
import 'package:mymusic/base/data/history.dart';
import 'package:mymusic/base/services/color_manager.dart';
import 'package:mymusic/base/data/library.dart';
import 'package:mymusic/base/data/playlist.dart';
import 'package:mymusic/base/data/setting.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mymusic/base/services/logger.dart';
import 'package:mymusic/base/services/picture_load_scheduler.dart';
import 'package:mymusic/base/services/picture_service.dart';
import 'package:mymusic/base/services/stream_client.dart';
import 'package:mymusic/base/utils/common_utils.dart';
import 'package:mymusic/base/utils/path.dart';
import 'package:mymusic/layer/layers_manager.dart';

bool firstLaunch = true;

class Loader {
  static bool _busy = false;

  static bool get busy => _busy;

  static final stateNotifier = ValueNotifier(0);

  static Future<void> init() async {
    if (Platform.isAndroid) {
      await Permission.storage.request();
      await Permission.audio.request();
    } else if (Platform.isIOS) {
      await BookmarkService.init();
      File keepFile = File('${appDocsDir.path}/mymusic.keep');
      if (!keepFile.existsSync()) {
        keepFile.createSync();
      }
    }

    _handleLegacyVersionData();

    await config.load();
    await setting.load();
    initMainPageTheme();

    colorManager.updateColors();

    await fontManager.loadFonts();
    library = Library();
  }

  static Future<void> load() async {
    _busy = true;
    stateNotifier.value++;

    if (isStreamSource && streamClient != null) {
      if (!File(getSyncedFilePath(sourceType)).existsSync()) {
        await firstSync();
        return;
      }
    }

    await library.load();

    audioHandler.loadStates();

    artistAlbumManager.classify();

    await history.load();

    await playlistManager.load();

    _busy = false;
    stateNotifier.value++;
  }

  static Future<void> reload() async {
    if (viewModeNotifier.value == .normal) {
      layersManager.clearDataLayers();
    }
    pictureLoadScheduler.clear();
    audioHandler.justClear();

    globalPictureList = [];

    library = Library();
    artistAlbumManager.clear();
    history.clear();
    playlistManager.reset();

    await load();
  }

  static Future<void> sync() async {
    _busy = true;
    stateNotifier.value++;

    if (viewModeNotifier.value == .normal) {
      layersManager.clearDataLayers();
    }

    globalPictureList = [];

    artistAlbumManager.clear();

    history.clear();

    playlistManager.reset();

    await library.sync();

    audioHandler.sync();

    artistAlbumManager.classify();

    await history.load();

    await playlistManager.sync();

    if (isStreamSource) {
      File syncedFile = File(getSyncedFilePath(sourceType));

      if (streamClient != null && !syncedFile.existsSync()) {
        syncedFile.createSync(recursive: true);
      }

      if (streamClient == null && syncedFile.existsSync()) {
        syncedFile.deleteSync(recursive: true);
      }
    }

    _busy = false;
    stateNotifier.value++;
  }

  static Future<void> firstSync() async {
    _busy = true;
    stateNotifier.value++;

    logger.output('${sourceType.name} first sync');

    layersManager.switchRootLayer('songs');

    playlistManager.reset();

    await library.sync();

    audioHandler.loadStates();

    artistAlbumManager.classify();

    await history.load();

    await playlistManager.sync();

    if (isStreamSource) {
      File syncedFile = File(getSyncedFilePath(sourceType));

      if (streamClient != null && !syncedFile.existsSync()) {
        syncedFile.createSync(recursive: true);
      }

      if (streamClient == null && syncedFile.existsSync()) {
        syncedFile.deleteSync(recursive: true);
      }
    }

    _busy = false;
    stateNotifier.value++;
  }

  static void _handleLegacyVersionData() {
    File tmp = File('${appSupportDir.path}/version.json');
    if (tmp.existsSync()) {
      firstLaunch = false;
      if (compareVersion('4.0.1', jsonDecode(tmp.readAsStringSync())) > 0) {
        File playlistsFile = File(
          "${getPlaylistConfigPath(.local)}/mymusic_playlists.json",
        );
        if (playlistsFile.existsSync()) {
          final content = playlistsFile.readAsStringSync();
          final list = jsonDecode(content) as List;
          if (list.isNotEmpty && list[0] == 'Favorite') {
            playlistsFile.writeAsStringSync(jsonEncode(list.skip(1).toList()));
          }
        }

        playlistsFile = File(
          "${getPlaylistConfigPath(.webdav)}/mymusic_playlists.json",
        );
        if (playlistsFile.existsSync()) {
          final content = playlistsFile.readAsStringSync();
          final list = jsonDecode(content) as List;
          if (list.isNotEmpty && list[0] == 'Favorite') {
            playlistsFile.writeAsStringSync(jsonEncode(list.skip(1).toList()));
          }
        }
      }

      if (compareVersion('4.2.0', jsonDecode(tmp.readAsStringSync())) > 0) {
        Directory tmpDir = Directory('${appSupportDir.path}/subsonic');
        if (tmpDir.existsSync()) {
          tmpDir.deleteSync(recursive: true);
        }

        tmpDir = Directory('${appSupportDir.path}/navidrome');
        if (tmpDir.existsSync()) {
          tmpDir.deleteSync(recursive: true);
        }

        tmpDir = Directory('${appSupportDir.path}/emby');
        if (tmpDir.existsSync()) {
          tmpDir.deleteSync(recursive: true);
        }
      }
    }
    tmp.writeAsStringSync(jsonEncode(versionNumber));
  }
}
