import 'package:flutter/material.dart';
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
    final ink = SketchyTheme.of(context).inkColor;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: ink),
            const SizedBox(height: 16),
            Text(
              error?.userMessage ?? 'An error occurred',
              style: TextStyle(fontSize: 16, color: ink),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            SketchyButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
            if (error is PermissionError)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: SketchyButton(
                  onPressed: () => PermissionService.openSettings(),
                  child: const Text('Open Settings'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
