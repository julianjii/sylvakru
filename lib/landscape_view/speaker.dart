import 'package:material_ui/material_ui.dart';
import 'package:mymusic/base/audio_handler.dart';
import 'package:mymusic/base/asset_images.dart';

class Speaker extends StatelessWidget {
  final Color color;
  const Speaker({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: volumeNotifier,
      builder: (_, value, _) {
        if (value == 0) {
          return IconButton(
            color: color,
            onPressed: () {
              // 恢复静音前的音量。这个值改成了持久化的（原来只是本文件里的
              // 内存变量，重启后为 null，静音状态下点这个图标毫无反应）。
              final restore = lastNonZeroVolumeNotifier.value;
              final target = restore > 0 && restore <= 1 ? restore : 0.5;
              volumeNotifier.value = target;
              audioHandler.setVolume(target);
              audioHandler.savePlayState();
            },
            icon: ImageIcon(speakerOffImage, size: 25),
          );
        }

        return IconButton(
          color: color,
          onPressed: () {
            volumeNotifier.value = 0;
            audioHandler.setVolume(0);
            audioHandler.savePlayState();
          },
          icon: ImageIcon(speakerImage, size: 25),
        );
      },
    );
  }
}
