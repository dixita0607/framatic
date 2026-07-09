import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:framatic/core/errors/app_error.dart';
import 'package:framatic/core/extensions/error_extension.dart';
import 'package:framatic/core/sketch_ui/sketch_ui.dart';
import 'package:framatic/core/widgets/circular_action_button.dart';
import 'package:framatic/features/photo_preview/presentation/photo_preview_provider.dart';
import 'package:provider/provider.dart';

/// Screen to preview captured photo with Save/Retake options
class PhotoPreviewScreen extends StatelessWidget {
  final String imagePath;

  const PhotoPreviewScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return SketchScreen(
      child: Column(
        children: [
          // Preview the processed image (frame border is already baked in)
          Expanded(
            child: Center(child: Image.file(File(imagePath), fit: .contain)),
          ),

          // Action buttons
          Consumer<PhotoPreviewProvider>(
            builder: (context, provider, _) {
              return Container(
                padding: const .all(24),
                child: Column(
                  mainAxisSize: .min,
                  children: [
                    Row(
                      mainAxisAlignment: .spaceEvenly,
                      children: [
                        CircularActionButton(
                          key: const ValueKey('preview_discard_button'),
                          icon: SketchIconType.close,
                          label: 'Retake',
                          onPressed: provider.isSaving
                              ? null
                              : () {
                                  provider.retakePhoto(imagePath);
                                  Navigator.of(context).pop(false);
                                },
                        ),
                        CircularActionButton(
                          key: const ValueKey('preview_save_button'),
                          icon: SketchIconType.check,
                          label: 'Save',
                          onPressed: provider.isSaving
                              ? null
                              : () async {
                                  try {
                                    await provider.savePhoto(imagePath);

                                    if (context.mounted) {
                                      Navigator.of(context).pop(true);
                                    }
                                  } on AppError catch (e) {
                                    if (context.mounted) {
                                      context.showErrorToast(e);
                                    }
                                  }
                                },
                          isLoading: provider.isSaving,
                          filled: true,
                          primary: true,
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
