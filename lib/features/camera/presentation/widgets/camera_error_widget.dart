import 'package:flutter/material.dart';
import 'package:framatic/core/services/permission_service.dart';
import 'package:framatic/features/camera/domain/camera_error.dart';

class CameraErrorWidget extends StatelessWidget {
  final CameraError? error;
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
            const Icon(Icons.error_outline, size: 64),
            const SizedBox(height: 16),
            Text(
              error?.message ?? 'An error occurred',
              style: const TextStyle(fontSize: 16),
              textAlign: .center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
            if (error is PermissionError)
              TextButton(
                onPressed: () => PermissionService.openSettings(),
                child: const Text('Open Settings'),
              ),
          ],
        ),
      ),
    );
  }
}
