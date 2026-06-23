import 'package:flutter/widgets.dart';
import 'package:framatic/core/sketch_ui/sketch_background.dart';
import 'package:framatic/core/sketch_ui/widgets/sketch_top_bar.dart';

class SketchScreen extends StatelessWidget {
  final String? title;
  final Widget child;
  final Widget? floatingActionButton;
  final VoidCallback? onBack;

  const SketchScreen({
    super.key,
    this.title,
    required this.child,
    this.floatingActionButton,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return SketchPageBackground(
      child: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                if (title != null) SketchTopBar(title: title!, onBack: onBack),
                Expanded(child: child),
              ],
            ),
            if (floatingActionButton != null)
              Positioned(right: 18, bottom: 18, child: floatingActionButton!),
          ],
        ),
      ),
    );
  }
}
