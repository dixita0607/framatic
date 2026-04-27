import 'package:flutter/widgets.dart';
import 'package:framatic/core/errors/app_error.dart';
import 'package:framatic/core/services/permission_service.dart';
import 'package:sketchy_design_lang/sketchy_design_lang.dart';

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
    return Center(
      child: Padding(
        padding: const .all(24.0),
        child: Column(
          mainAxisAlignment: .center,
          children: [
            const SketchySymbol(symbol: .hash),
            const SizedBox(height: 16),
            SketchyText(
              error?.userMessage ?? 'An error occurred',
              style: const TextStyle(fontSize: 16),
              textAlign: .center,
            ),
            const SizedBox(height: 16),
            SketchyButton(
              onPressed: onRetry,
              child: const SketchyText('Retry'),
            ),
            if (error is PermissionError)
              SketchyButton(
                onPressed: () => PermissionService.openSettings(),
                child: const SketchyText('Open Settings'),
              ),
          ],
        ),
      ),
    );
  }
}
