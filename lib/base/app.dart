import 'dart:io';

import 'package:material_ui/material_ui.dart';

const String versionNumber = '4.6.1';

late final Directory appDocsDir;
late final Directory appSupportDir;
late final Directory tmpDir;
String? iosFileProviderStorage;

final isMobile = Platform.isAndroid || Platform.isIOS;
const isTV = bool.fromEnvironment('TV', defaultValue: false);

final globalNavigatorKey = GlobalKey<NavigatorState>();

/// Corner radius applied to the lyrics page while it is being dragged down.
const double dragCornerRadius = 12;

enum ThemeType { vivid, light, dark, auto }

/// 主页面主题的用户选择：auto 跟随系统亮度，light / dark 锁定。
final mainPageThemeModeNotifier = ValueNotifier(ThemeType.auto);

/// 主页面实际生效的主题，只会是 light / dark —— 渲染和配色一律读这个。
final mainPageThemeNotifier = ValueNotifier(ThemeType.light);

final lyricsPageThemeNotifier = ValueNotifier(ThemeType.vivid);

final ValueNotifier<Locale?> localeNotifier = ValueNotifier(null);

enum SourceType { local, webdav, navidrome, emby, feiniu }

SourceType sourceType = .local;

bool isStreamSource = false;
bool isNotStreamSource = !isStreamSource;

final ValueNotifier<String?> fontFamilyNotifier = ValueNotifier(null);

final List<String> importedFonts = [];

enum ViewMode { normal, mini, bigPicture }

final viewModeNotifier = ValueNotifier(ViewMode.normal);

final immersiveWideLayoutNotifier = ValueNotifier(true);

// 宽布局关闭沉浸模式时，顶/底系统条各自是否显示
final wideShowTopSystemBarNotifier = ValueNotifier(true);
final wideShowBottomSystemBarNotifier = ValueNotifier(true);
