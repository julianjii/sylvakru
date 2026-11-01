import 'package:material_ui/material_ui.dart';
import 'package:sylvakru/base/app.dart';
import 'package:sylvakru/base/utils/contrast_color_generator.dart';
import 'package:sylvakru/layer/lyrics_page_layer.dart';

final colorManager = ColorManager();

Color currentCoverArtColor = Colors.grey;

ContrastColorTextTheme contrastColorTheme = ContrastColorGenerator.generate(
  currentCoverArtColor,
);

final lightHoverFocusColorNotifier = ValueNotifier(false);

/// auto 取系统亮度，light / dark 直接锁定。
ThemeType resolveMainPageTheme(ThemeType mode, Brightness platformBrightness) {
  return switch (mode) {
    .light => .light,
    .dark => .dark,
    _ => platformBrightness == .dark ? .dark : .light,
  };
}

/// 把当前模式解析进 [mainPageThemeNotifier]，生效值变化会自动重算主页面配色。
void applyMainPageTheme() {
  mainPageThemeNotifier.value = resolveMainPageTheme(
    mainPageThemeModeNotifier.value,
    WidgetsBinding.instance.platformDispatcher.platformBrightness,
  );
}

void _onMainPageThemeChanged() {
  colorManager.updateMainPageColors();
  updateHoverFocusColor();
}

class _SystemBrightnessObserver with WidgetsBindingObserver {
  @override
  void didChangePlatformBrightness() {
    if (mainPageThemeModeNotifier.value == .auto) {
      applyMainPageTheme();
    }
  }
}

final _systemBrightnessObserver = _SystemBrightnessObserver();

/// 启动时调用一次：解析初始主题，并跟随系统亮度 / 生效值变化更新配色。
void initMainPageTheme() {
  applyMainPageTheme();
  mainPageThemeNotifier.addListener(_onMainPageThemeChanged);
  WidgetsBinding.instance.addObserver(_systemBrightnessObserver);
}

void updateHoverFocusColor() {
  if ((displayLyricsPage && lyricsPageThemeNotifier.value == .vivid) ||
      viewModeNotifier.value == .mini) {
    double r = currentCoverArtColor.r;
    double g = currentCoverArtColor.g;
    double b = currentCoverArtColor.b;
    final luminance = 0.299 * r + 0.587 * g + 0.114 * b;

    lightHoverFocusColorNotifier.value = luminance < 0.5;
  } else {
    lightHoverFocusColorNotifier.value = mainPageThemeNotifier.value == .dark;
  }
}

final MyColor pageBackgroundColor = MyColor(
  lightModeValue: Colors.grey.shade100,
  darkModeValue: Color.fromARGB(255, 50, 50, 50),
);

final MyColor iconColor = MyColor(
  lightModeValue: Colors.black,
  darkModeValue: Colors.grey.shade400,
);

final MyColor textColor = MyColor(
  lightModeValue: Colors.grey.shade900,
  darkModeValue: Colors.grey.shade400,
);

final MyColor highlightTextColor = MyColor(
  lightModeValue: Colors.black,
  darkModeValue: Color.fromARGB(255, 230, 230, 230),
);

final MyColor switchColor = MyColor(
  lightModeValue: Colors.black87,
  darkModeValue: Color.fromARGB(221, 0, 0, 0),
);

final MyColor glassColor = MyColor(
  lightModeValue: Color.fromARGB(128, 255, 255, 255),
  darkModeValue: Color.fromARGB(128, 30, 30, 30),
);

final MyColor panelColor = MyColor(
  lightModeValue: Colors.white,
  darkModeValue: Color.fromARGB(255, 50, 50, 50),
);

final MyColor sidebarColor = MyColor(
  lightModeValue: Colors.grey.shade50,
  darkModeValue: Color.fromARGB(255, 55, 55, 55),
);

final MyColor bottomColor = MyColor(
  lightModeValue: Colors.grey.shade100,
  darkModeValue: Color.fromARGB(255, 60, 60, 60),
);

final MyColor searchFieldColor = MyColor(
  lightModeValue: Colors.grey.shade200,
  darkModeValue: Colors.grey.shade700,
);

final MyColor buttonColor = MyColor(
  lightModeValue: Colors.grey.shade200,
  darkModeValue: Colors.grey.shade700,
);

final MyColor dividerColor = MyColor(
  lightModeValue: Colors.grey,
  darkModeValue: Colors.grey.shade700,
);

final MyColor selectedItemColor = MyColor(
  lightModeValue: Colors.grey.shade200,
  darkModeValue: Colors.grey.shade700,
);

final MyColor menuColor = MyColor(
  lightModeValue: Colors.grey.shade50,
  darkModeValue: Colors.grey.shade800,
);

final MyColor seekBarColor = MyColor(
  lightModeValue: Colors.black,
  darkModeValue: Colors.grey.shade400,
);

final MyColor volumeBarColor = MyColor(
  lightModeValue: Colors.black,
  darkModeValue: Colors.grey.shade400,
);

final MyColor lyricsPageBackgroundColor = MyColor(
  vividModeValue: Colors.transparent,
  lightModeValue: Colors.grey.shade200,
  darkModeValue: Color.fromARGB(255, 50, 50, 50),
  pageType: 1,
);

final MyColor lyricsPageForegroundColor = MyColor(
  getVividValue: () {
    return contrastColorTheme.regular;
  },
  lightModeValue: Colors.grey.shade900,
  darkModeValue: Colors.grey.shade300,
  pageType: 1,
);

final MyColor lyricsPageHighlightTextColor = MyColor(
  getVividValue: () {
    return contrastColorTheme.accent;
  },
  lightModeValue: Colors.black,
  darkModeValue: Colors.grey.shade200,
  pageType: 1,
);

final MyColor lyricsPageButtonColor = MyColor(
  getVividValue: () {
    return contrastColorTheme.regular.withAlpha(50);
  },
  lightModeValue: Colors.white70,
  darkModeValue: Colors.grey.shade700,
  pageType: 1,
);

final MyColor lyricsPageDividerColor = MyColor(
  getVividValue: () {
    return contrastColorTheme.regular;
  },
  lightModeValue: Colors.grey,
  darkModeValue: Colors.grey.shade700,
  pageType: 1,
);

final MyColor lyricsPageSelectedItemColor = MyColor(
  getVividValue: () {
    return contrastColorTheme.regular.withAlpha(50);
  },
  lightModeValue: Colors.white,
  darkModeValue: Colors.grey.shade700,
  pageType: 1,
);

final MyColor lyricsPageMenuColor = MyColor(
  vividModeValue: Colors.white10,
  lightModeValue: Colors.grey.shade50,
  darkModeValue: Colors.grey.shade800,
  pageType: 1,
);

final MyColor miniViewForegroundColor = MyColor(
  getVividValue: () {
    return contrastColorTheme.regular;
  },
  pageType: 2,
);

final MyColor miniViewHighlightTextColor = MyColor(
  getVividValue: () {
    return contrastColorTheme.accent;
  },

  pageType: 2,
);

final MyColor miniViewButtonColor = MyColor(
  getVividValue: () {
    return contrastColorTheme.regular.withAlpha(50);
  },
  pageType: 2,
);

final MyColor miniViewDividerColor = MyColor(
  getVividValue: () {
    return contrastColorTheme.regular;
  },
  pageType: 2,
);

final MyColor miniViewSelectedItemColor = MyColor(
  getVividValue: () {
    return contrastColorTheme.regular.withAlpha(50);
  },

  pageType: 2,
);

final MyColor miniViewMenuColor = MyColor(
  vividModeValue: Colors.white10,
  pageType: 2,
);

class ColorManager {
  late final List<MyColor> myMainPageColors;
  late final List<MyColor> myLyricsPageColors;
  late final List<MyColor> myMiniViewColors;

  ColorManager() {
    myMainPageColors = [
      pageBackgroundColor,
      iconColor,
      textColor,
      highlightTextColor,
      switchColor,
      glassColor,
      panelColor,
      sidebarColor,
      bottomColor,
      searchFieldColor,
      buttonColor,
      dividerColor,
      selectedItemColor,
      menuColor,
      seekBarColor,
      volumeBarColor,
    ];

    myLyricsPageColors = [
      lyricsPageBackgroundColor,
      lyricsPageForegroundColor,
      lyricsPageHighlightTextColor,
      lyricsPageDividerColor,
      lyricsPageButtonColor,
      lyricsPageSelectedItemColor,
      lyricsPageMenuColor,
    ];

    if (!isMobile) {
      myMiniViewColors = [
        miniViewForegroundColor,
        miniViewHighlightTextColor,
        miniViewDividerColor,
        miniViewButtonColor,
        miniViewSelectedItemColor,
        miniViewMenuColor,
      ];
    }
  }

  void updateMainPageColors() {
    for (final color in myMainPageColors) {
      color.updateColor();
    }
  }

  void updateLyricsPageColors() {
    for (final color in myLyricsPageColors) {
      color.updateColor();
    }
  }

  void updateMiniViewColors() {
    for (final color in myMiniViewColors) {
      color.updateColor();
    }
  }

  void updateColors() {
    updateMainPageColors();
    updateLyricsPageColors();
    if (!isMobile) {
      updateMiniViewColors();
    }
  }

  Color getSpecificMainPageCoverArtBaseColor() {
    return isMobile ? pageBackgroundColor.value : panelColor.value;
  }

  Color getSpecificLyricsPageCoverArtBaseColor() {
    return lyricsPageThemeNotifier.value == .vivid
        ? currentCoverArtColor
        : lyricsPageBackgroundColor.value;
  }

  Color getSpecificBgBaseColor() {
    return viewModeNotifier.value == .mini || displayLyricsPage
        ? currentCoverArtColor
        : isMobile
        ? pageBackgroundColor.value
        : panelColor.value;
  }

  Color getSpecificBgColor() {
    return viewModeNotifier.value == .mini
        ? Colors.transparent
        : displayLyricsPage
        ? lyricsPageBackgroundColor.value
        : isMobile
        ? pageBackgroundColor.value
        : panelColor.value;
  }

  Color getSpecificTextColor() {
    return viewModeNotifier.value == .mini
        ? miniViewForegroundColor.value
        : displayLyricsPage
        ? lyricsPageForegroundColor.value
        : textColor.value;
  }

  Color getSpecificHighlightTextColor() {
    return viewModeNotifier.value == .mini
        ? miniViewHighlightTextColor.value
        : displayLyricsPage
        ? lyricsPageHighlightTextColor.value
        : highlightTextColor.value;
  }

  Color getSpecificIconColor() {
    return viewModeNotifier.value == .mini
        ? miniViewForegroundColor.value
        : displayLyricsPage
        ? lyricsPageForegroundColor.value
        : iconColor.value;
  }

  Color getSpecificButtonColor() {
    return viewModeNotifier.value == .mini
        ? miniViewButtonColor.value
        : displayLyricsPage
        ? lyricsPageButtonColor.value
        : buttonColor.value;
  }

  Color getSpecificDividerColor() {
    return viewModeNotifier.value == .mini
        ? miniViewDividerColor.value
        : displayLyricsPage
        ? lyricsPageDividerColor.value
        : dividerColor.value;
  }

  Color getSpecificSelectedItemColor() {
    return viewModeNotifier.value == .mini
        ? miniViewSelectedItemColor.value
        : displayLyricsPage
        ? lyricsPageSelectedItemColor.value
        : selectedItemColor.value;
  }

  Color getSpecificMenuColor() {
    if (viewModeNotifier.value == .mini) {
      return miniViewMenuColor.value;
    }
    return displayLyricsPage ? lyricsPageMenuColor.value : menuColor.value;
  }
}

class MyColor {
  // fixed
  final Color? vividModeValue;
  // dynamic
  final Color Function()? getVividValue;
  final Color lightModeValue;
  final Color darkModeValue;

  // main: 0, lyrics: 1, mini mode: 2
  final int pageType;

  ValueNotifier<Color> valueNotifier = ValueNotifier(Colors.transparent);

  MyColor({
    this.vividModeValue,
    this.getVividValue,
    this.lightModeValue = Colors.transparent,
    this.darkModeValue = Colors.transparent,
    this.pageType = 0,
  });

  void updateColor() {
    // 主页面只有浅色 / 深色两种，迷你播放器固定走封面取色。
    if (pageType == 0) {
      valueNotifier.value = mainPageThemeNotifier.value == .light
          ? lightModeValue
          : darkModeValue;
      return;
    }

    if (pageType == 2 || lyricsPageThemeNotifier.value == .vivid) {
      valueNotifier.value = vividModeValue ?? getVividValue!.call();
      return;
    }

    valueNotifier.value = lyricsPageThemeNotifier.value == .light
        ? lightModeValue
        : darkModeValue;
  }

  Color get value => valueNotifier.value;
}
