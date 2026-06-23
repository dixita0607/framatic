import 'package:flutter/widgets.dart';
import 'package:framatic/core/errors/app_error.dart';
import 'package:framatic/core/sketch_ui/sketch_ui.dart';
import 'package:framatic/core/services/permission_service.dart';

class CameraErrorWidget extends StatelessWidget {
  final AppError? error;
  final VoidCallback onRetry;

  const CameraErrorWidget({
    super.key,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SketchTheme.of(context);
    return Center(
      child: Padding(
        padding: const .all(24.0),
        child: Column(
          mainAxisAlignment: .center,
          children: [
            SketchIcon(
              type: SketchIconType.error,
              size: 64,
              color: theme.danger,
            ),
            const SizedBox(height: 16),
            Text(
              error?.userMessage ?? 'An error occurred',
              style: theme.bodyText,
              textAlign: .center,
            ),
            const SizedBox(height: 16),
            SketchButton(label: 'Retry', onPressed: onRetry, filled: true),
            if (error is PermissionError)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: SketchButton(
                  label: 'Open Settings',
                  onPressed: () => PermissionService.openSettings(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
