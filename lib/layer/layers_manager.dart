import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:mymusic/base/data/artist_album.dart';
import 'package:mymusic/base/data/folder.dart';
import 'package:mymusic/base/services/color_manager.dart';
import 'package:mymusic/base/app.dart';
import 'package:mymusic/base/utils/dynamic_detail_route.dart';
import 'package:mymusic/base/utils/media_query.dart';
import 'package:mymusic/landscape_view/sidebar.dart';
import 'package:mymusic/layer/about_layer.dart';
import 'package:mymusic/layer/albums_layer.dart';
import 'package:mymusic/layer/artists_layer.dart';
import 'package:mymusic/layer/folders_layer.dart';
import 'package:mymusic/layer/font_picker_layer.dart';
import 'package:mymusic/layer/home_layer.dart';
import 'package:mymusic/layer/license_layer.dart';
import 'package:mymusic/layer/playlists_layer.dart';
import 'package:mymusic/layer/frequently_layer.dart';
import 'package:mymusic/layer/recently_layer.dart';
import 'package:mymusic/layer/settings_layer.dart';
import 'package:mymusic/layer/single_album_layer.dart';
import 'package:mymusic/layer/single_artist_layer.dart';
import 'package:mymusic/layer/single_folder_layer.dart';
import 'package:mymusic/layer/single_playlist_layer.dart';
import 'package:mymusic/layer/songs_layer.dart';
import 'package:mymusic/base/data/playlist.dart';

final layersManager = LayersManager();

class LayersManager {
  // lable -> rootLayer
  final Map<String, Widget> rootLayerMap = {};
  // rootLayer -> rootPage
  final Map<Widget, Widget> rootPageMap = {};

  // root -> detail
  final Map<Widget, Widget?> detailWidgetMap = {};
  final Map<Widget, Widget> parentWidgetMap = {};

  Widget? topRootLayer;

  Widget? topRootPage;

  final switchNotifier = ValueNotifier(0);

  // bumped whenever a detail page is pushed / popped, so the narrow layout can
  // hide its top bar and tab bar behind a full screen detail page
  final detailChangeNotifier = ValueNotifier(0);

  Widget createPage(Widget layer) {
    return Stack(
      key: GlobalKey(),
      fit: .expand,
      children: [
        ValueListenableBuilder(
          valueListenable: pageBackgroundColor.valueNotifier,
          builder: (context, value, child) {
            return Material(color: value, child: layer);
          },
        ),
      ],
    );
  }

  Widget getRootLayer(String label) {
    return rootLayerMap.putIfAbsent(label, () {
      if (label == 'artists') {
        return ArtistsLayer(key: GlobalKey());
      } else if (label == 'albums') {
        return AlbumsLayer(key: GlobalKey());
      } else if (label == 'folders') {
        return FoldersLayer(key: GlobalKey());
      } else if (label == 'home') {
        return HomeLayer(key: GlobalKey());
      } else if (label == 'songs') {
        return SongsLayer(key: GlobalKey());
      } else if (label == 'frequently') {
        return FrequentlyLayer(key: GlobalKey());
      } else if (label == 'recently') {
        return RecentlyLayer(key: GlobalKey());
      } else if (label == 'playlists') {
        return PlaylistsLayer(key: GlobalKey());
      } else if (label == 'settings') {
        return SettingsLayer(key: GlobalKey());
      } else {
        return SinglePlaylistLayer(
          key: GlobalKey(),
          playlist: playlistManager.getPlaylistByName(label.substring(1))!,
          isRoot: true,
        );
      }
    });
  }

  /// The page of a root layer, created once and cached, so switching to a layer
  /// keeps its state.
  Widget rootPageFor(String label) {
    final layer = getRootLayer(label);
    return rootPageMap.putIfAbsent(layer, () => createPage(layer));
  }

  void switchRootLayer(String label) {
    Widget layer = getRootLayer(label);
    if (layer == topRootLayer) {
      return;
    }

    topRootLayer = layer;
    topRootPage = rootPageFor(label);

    sidebarHighlighLabel.value = label;
    switchNotifier.value++;
  }

  // in a narrow layout settings is not a root layer but a route pushed on the
  // root navigator, so it can be popped back to whatever was on screen before
  bool settingsPagePushed = false;

  // pages opened from settings (about / license / fonts / premium) must be
  // pushed onto the same navigator that holds the settings route
  GlobalKey<NavigatorState> get settingsNavigatorKey =>
      settingsPagePushed ? globalNavigatorKey : settingsKey;

  /// Opens settings: a narrow layout gets a full screen route that can be
  /// popped back, a wide layout keeps switching the root layer.
  void openSettings() {
    final layoutContext = globalNavigatorKey.currentContext;

    if (layoutContext == null || !isTooNarrow(layoutContext)) {
      switchRootLayer('settings');
      return;
    }

    final navigator = globalNavigatorKey.currentState;
    if (navigator == null || settingsPagePushed) {
      return;
    }

    settingsPagePushed = true;

    final layer = SettingsPage();
    final page = createPage(layer);

    navigator.push(MaterialPageRoute(builder: (context) => page)).whenComplete(
      () {
        settingsPagePushed = false;
      },
    );
  }

  /// Closes the pushed settings route. Returns whether a route was popped; it
  /// is false in a wide layout, where settings is a root layer instead.
  Future<bool> closeSettings() async {
    if (!settingsPagePushed) {
      return false;
    }

    final navigator = globalNavigatorKey.currentState;
    if (navigator == null || !navigator.canPop()) {
      return false;
    }

    navigator.pop();
    return true;
  }

  void removeLayerIfNeed(dynamic target) async {
    if (target is Playlist) {
      String key = '_${target.name}';
      final rootLayer = getRootLayer('playlists');
      if ((detailWidgetMap[rootLayer] as SinglePlaylistLayer?)?.playlist ==
          target) {
        popDetail('playlists');
      }
      final removedLayer = rootLayerMap.remove(key);
      if (removedLayer == topRootLayer) {
        switchRootLayer('songs');
      }
      // prevent black screen appear
      await Future.delayed(Duration(milliseconds: 500));
      rootPageMap.remove(removedLayer);
    } else if (target is Artist) {
      final rootLayer = getRootLayer('artists');
      if ((detailWidgetMap[rootLayer] as SingleArtistLayer?)?.artist ==
          target) {
        popDetail('artists');
      }
    } else if (target is Album) {
      final rootLayer = getRootLayer('albums');
      if ((detailWidgetMap[rootLayer] as SingleAlbumLayer?)?.album == target) {
        popDetail('albums');
      }
    } else if (target is Folder) {
      final rootLayer = getRootLayer('folders');
      if ((detailWidgetMap[rootLayer] as SingleFolderLayer?)?.folder ==
          target) {
        popDetail('folders');
      }
    } else {
      assert(false);
    }
  }

  void pushDetail(String label, dynamic detail) async {
    if (viewModeNotifier.value == .bigPicture) {
      return;
    }
    final rootLayer = getRootLayer(label);

    late GlobalKey<NavigatorState> rootKey;
    late ValueNotifier<bool> visibleNotifier;
    late Widget detailLayer;
    if (label == 'artists') {
      rootKey = artistsKey;
      visibleNotifier = artistsVisibleNotifier;
      detailLayer = SingleArtistLayer(artist: detail);
    } else if (label == 'albums') {
      rootKey = albumsKey;
      visibleNotifier = albumsVisibleNotifier;
      detailLayer = SingleAlbumLayer(album: detail);
    } else if (label == 'folders') {
      rootKey = foldersKey;
      visibleNotifier = foldersVisibleNotifier;
      detailLayer = SingleFolderLayer(folder: detail);
    } else if (label == 'home') {
      rootKey = homeKey;
      visibleNotifier = homeVisibleNotifier;
      if (detail is Album) {
        detailLayer = SingleAlbumLayer(album: detail, isHomeDetaile: true);
      } else {
        detailLayer = SinglePlaylistLayer(
          playlist: detail,
          isRoot: false,
          isHomeDetaile: true,
        );
      }
    } else if (label == 'playlists') {
      rootKey = playlistsKey;
      visibleNotifier = playlistsVisibleNotifier;
      detailLayer = SinglePlaylistLayer(playlist: detail, isRoot: false);
    } else {
      rootKey = settingsNavigatorKey;
      visibleNotifier = settingsVisibleNotifier;
      if (detail == 'about') {
        detailLayer = AboutLayer();
      } else if (detail == 'license') {
        visibleNotifier = aboutVisibleNotifier;
        detailLayer = LicenseLayer();
      } else {
        detailLayer = FontPickerLayer();
      }
    }
    if (detailWidgetMap[rootLayer] == null) {
      parentWidgetMap[detailLayer] = rootLayer;
    } else {
      parentWidgetMap[detailLayer] = detailWidgetMap[rootLayer]!;
    }
    detailWidgetMap[rootLayer] = detailLayer;

    final detailPage = createPage(detailLayer);
    rootKey.currentState?.push(
      DynamicDetailRoute(
        builder: (context) {
          if (isTooNarrow(context)) {
            return detailPage;
          }
          return detailLayer;
        },
        label: label,
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      visibleNotifier.value = false;
    });
    detailChangeNotifier.value++;
  }

  Future<bool> popDetail(String label, {bool executePop = true}) async {
    if (rootLayerMap[label] == null) {
      return false;
    }
    final rootLayer = getRootLayer(label);
    if (detailWidgetMap[rootLayer] == null) {
      return false;
    }

    final detailLayer = detailWidgetMap.remove(rootLayer);
    final parentLayer = parentWidgetMap.remove(detailLayer);

    late GlobalKey<NavigatorState> rootKey;
    late ValueNotifier<bool> visibleNotifier;
    if (label == 'artists') {
      rootKey = artistsKey;
      visibleNotifier = artistsVisibleNotifier;
    } else if (label == 'albums') {
      rootKey = albumsKey;
      visibleNotifier = albumsVisibleNotifier;
    } else if (label == 'folders') {
      rootKey = foldersKey;
      visibleNotifier = foldersVisibleNotifier;
    } else if (label == 'home') {
      rootKey = homeKey;
      visibleNotifier = homeVisibleNotifier;
    } else if (label == 'playlists') {
      rootKey = playlistsKey;
      visibleNotifier = playlistsVisibleNotifier;
    } else {
      rootKey = settingsNavigatorKey;
      visibleNotifier = settingsVisibleNotifier;
      if (detailLayer is LicenseLayer) {
        detailWidgetMap[rootLayer] = parentLayer;
        visibleNotifier = aboutVisibleNotifier;
      }
    }

    if ((rootKey.currentState?.canPop() ?? false) && executePop) {
      rootKey.currentState?.pop();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      visibleNotifier.value = true;
    });
    detailChangeNotifier.value++;

    return true;
  }

  Future<void> pushDetailIfNeed(dynamic detail) async {
    if (detail is Artist) {
      if ((detailWidgetMap[getRootLayer('artists')] as SingleArtistLayer?)
              ?.artist !=
          detail) {
        await Future.delayed(Duration(milliseconds: 500));
        if (await popDetail('artists')) {
          await Future.delayed(Duration(milliseconds: 500));
        }
        pushDetail('artists', detail);
      }
    } else {
      if ((detailWidgetMap[getRootLayer('albums')] as SingleAlbumLayer?)
              ?.album !=
          detail) {
        await Future.delayed(Duration(milliseconds: 500));
        if (await popDetail('albums')) {
          await Future.delayed(Duration(milliseconds: 500));
        }

        pushDetail('albums', detail);
      }
    }
  }

  void clearAll() async {
    popDetail('artists', executePop: false);
    popDetail('albums', executePop: false);
    popDetail('folders', executePop: false);
    popDetail('playlists', executePop: false);
    popDetail('home', executePop: false);
    while (await layersManager.popDetail('settings')) {}

    rootLayerMap.clear();
    rootPageMap.clear();

    topRootLayer = null;
    topRootPage = null;

    switchNotifier.value++;
  }

  void clearDataLayers() {
    popDetail('artists', executePop: false);
    popDetail('albums', executePop: false);
    popDetail('folders', executePop: false);
    popDetail('playlists', executePop: false);
    popDetail('home', executePop: false);

    rootLayerMap.removeWhere((k, v) => v != topRootLayer);
    rootPageMap.removeWhere((k, v) => k != topRootLayer);

    switchNotifier.value++;
  }

  void clearArtistAlbum() {
    popDetail('artists', executePop: false);
    popDetail('albums', executePop: false);

    final artistsLayer = rootLayerMap['artists'];
    final albumLayer = rootLayerMap['albums'];

    rootPageMap.removeWhere((k, v) => k == artistsLayer || k == albumLayer);
    rootLayerMap.removeWhere((k, v) => k == 'artists' || k == 'albums');

    switchNotifier.value++;
  }
}
