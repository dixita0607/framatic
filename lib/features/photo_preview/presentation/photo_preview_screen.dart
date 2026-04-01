import 'dart:io';

import 'package:flutter/material.dart';
import 'package:framatic/core/widgets/circular_action_button.dart';
import 'package:framatic/features/photo_preview/presentation/photo_preview_provider.dart';
import 'package:provider/provider.dart';

/// Screen to preview captured photo with Save/Retake options
class PhotoPreviewScreen extends StatelessWidget {
  final String imagePath;

  const PhotoPreviewScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Preview image
            Expanded(
              child: Center(
                child: Image.file(File(imagePath), fit: BoxFit.contain),
              ),
            ),

            // Action buttons
            Consumer<PhotoPreviewProvider>(
              builder: (context, provider, _) {
                return Container(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Retake button
                      CircularActionButton(
                        icon: Icons.close,
                        label: 'Retake',
                        onPressed: provider.isSaving
                            ? null
                            : () {
                                provider.retakePhoto(imagePath);
                                Navigator.of(context).pop(false);
                              },
                      ),

                      // Save button
                      CircularActionButton(
                        icon: Icons.check,
                        label: 'Save',
                        onPressed: provider.isSaving
                            ? null
                            : () async {
                                try {
                                  await provider.savePhoto(imagePath);

                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          provider.successMessage,
                                        ),
                                        duration:
                                            const Duration(seconds: 2),
                                      ),
                                    );
                                    Navigator.of(context).pop(true);
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      SnackBar(
                                        content: Text(e.toString()),
                                      ),
                                    );
                                  }
                                }
                              },
                        isLoading: provider.isSaving,
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
