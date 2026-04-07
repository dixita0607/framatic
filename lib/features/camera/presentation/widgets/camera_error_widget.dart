import 'package:flutter/material.dart';
import 'package:framatic/core/errors/app_error.dart';
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64),
            const SizedBox(height: 16),
            Text(
              error?.userMessage ?? 'An error occurred',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
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
