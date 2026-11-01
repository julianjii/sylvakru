// 主页面主题解析：自动模式取系统亮度，手动模式锁定。
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sylvakru/base/app.dart';
import 'package:sylvakru/base/services/color_manager.dart';

void main() {
  test('自动模式跟随系统亮度', () {
    expect(
      resolveMainPageTheme(ThemeType.auto, Brightness.dark),
      ThemeType.dark,
    );
    expect(
      resolveMainPageTheme(ThemeType.auto, Brightness.light),
      ThemeType.light,
    );
  });

  test('手动模式不受系统影响', () {
    expect(
      resolveMainPageTheme(ThemeType.light, Brightness.dark),
      ThemeType.light,
    );
    expect(
      resolveMainPageTheme(ThemeType.dark, Brightness.light),
      ThemeType.dark,
    );
  });
}
