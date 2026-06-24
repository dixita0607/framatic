import 'package:flutter/widgets.dart';
import 'package:framatic/core/sketch_ui/sketch_theme.dart';
import 'package:framatic/core/sketch_ui/widgets/sketch_surface.dart';

class SketchDialog extends StatelessWidget {
  final String title;
  final Widget child;
  final List<Widget> actions;

  const SketchDialog({
    super.key,
    required this.title,
    required this.child,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SketchTheme.of(context);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return SafeArea(
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        padding: EdgeInsets.fromLTRB(22, 22, 22, 22 + bottomInset),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SketchSurface(
              fillColor: theme.panelStrong,
              hachure: true,
              padding: const EdgeInsets.all(20),
              seed: title.hashCode,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.title),
                    const SizedBox(height: 18),
                    child,
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        for (var i = 0; i < actions.length; i++) ...[
                          if (i > 0) const SizedBox(width: 10),
                          actions[i],
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Future<T?> showSketchDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) {
  return Navigator.of(context).push<T>(_SketchDialogRoute<T>(builder: builder));
}

class _SketchDialogRoute<T> extends PopupRoute<T> {
  final WidgetBuilder builder;

  _SketchDialogRoute({required this.builder});

  @override
  Color? get barrierColor => const Color(0x99000000);

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => 'Dismiss';

  @override
  Duration get transitionDuration => const Duration(milliseconds: 140);

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return FadeTransition(
      opacity: animation,
      child: DefaultTextStyle(
        style: SketchTheme.of(context).bodyText,
        child: builder(context),
      ),
    );
  }
}
