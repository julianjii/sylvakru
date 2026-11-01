import 'package:material_ui/material_ui.dart';
import 'package:sylvakru/base/services/color_manager.dart';
import 'package:sylvakru/landscape_view/bottom_control.dart';
import 'package:sylvakru/landscape_view/sidebar.dart';
import 'package:sylvakru/layer/layers_manager.dart';

class LandscapeView extends StatelessWidget {
  const LandscapeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Sidebar(),

                  Expanded(
                    child: ValueListenableBuilder(
                      valueListenable: panelColor.valueNotifier,
                      builder: (context, value, child) {
                        return Material(color: value, child: child);
                      },
                      child: ValueListenableBuilder(
                        valueListenable: layersManager.switchNotifier,
                        builder: (context, value, child) {
                          return Stack(
                            children: layersManager.rootLayerMap.values.map((
                              layer,
                            ) {
                              return Visibility(
                                visible: layer == layersManager.topRootLayer,
                                maintainState: true,
                                child: layer,
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            BottomControl(),
          ],
        ),
      ],
    );
  }
}
