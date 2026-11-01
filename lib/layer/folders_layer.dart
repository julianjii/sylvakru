import 'package:material_ui/material_ui.dart';
import 'package:path/path.dart' as p;
import 'package:smooth_corner/smooth_corner.dart';
import 'package:mymusic/base/asset_images.dart';
import 'package:mymusic/base/data/library.dart';
import 'package:mymusic/base/services/color_manager.dart';
import 'package:mymusic/base/utils/metadata_utils.dart';
import 'package:mymusic/base/widgets/cover_art_widget.dart';
import 'package:mymusic/base/widgets/my_divider.dart';
import 'package:mymusic/base/widgets/my_navigator.dart';
import 'package:mymusic/l10n/generated/app_localizations.dart';
import 'package:mymusic/landscape_view/title_bar.dart';
import 'package:mymusic/layer/layers_manager.dart';
import 'package:mymusic/portrait_view/root_tab_bar.dart';

part '../landscape_view/panels/folders_panel.dart';
part '../portrait_view/pages/folders_page.dart';

final GlobalKey<NavigatorState> foldersKey = GlobalKey();
final foldersVisibleNotifier = ValueNotifier(true);

class FoldersLayer extends StatelessWidget {
  const FoldersLayer({super.key});

  @override
  Widget build(BuildContext context) {
    return myNavigator(
      key: foldersKey,
      visibleNotifier: foldersVisibleNotifier,
      pageViewBuilder: () => pageView(context),
      panelViewBuilder: () => panelView(context),
    );
  }
}
