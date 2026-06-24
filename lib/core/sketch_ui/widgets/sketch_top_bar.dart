import 'package:flutter/widgets.dart';
import 'package:framatic/core/sketch_ui/sketch_icons.dart';
import 'package:framatic/core/sketch_ui/sketch_theme.dart';

class SketchTopBar extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;

  const SketchTopBar({super.key, required this.title, this.onBack});

  @override
  Widget build(BuildContext context) {
    final theme = SketchTheme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 16, 8),
      child: Row(
        children: [
          if (onBack != null) ...[
            Semantics(
              button: true,
              label: 'Back',
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onBack,
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: Center(
                    child: SketchIcon(
                      type: SketchIconType.back,
                      size: 18,
                      color: theme.ink,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Text(
              title,
              style: theme.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
