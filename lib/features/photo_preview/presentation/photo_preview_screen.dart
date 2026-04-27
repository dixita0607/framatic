import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:framatic/core/errors/app_error.dart';
import 'package:framatic/core/extensions/error_extension.dart';
import 'package:framatic/features/photo_preview/presentation/photo_preview_provider.dart';
import 'package:provider/provider.dart';
import 'package:sketchy_design_lang/sketchy_design_lang.dart';

/// Screen to preview captured photo with Save/Retake options
class PhotoPreviewScreen extends StatelessWidget {
  final String imagePath;

  const PhotoPreviewScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return SketchyScaffold(
      body: SafeArea(
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
                  child: Row(
                    mainAxisAlignment: .spaceEvenly,
                    children: [
                      // Retake button
                      SketchyIconButton(
                        icon: SketchySymbol(symbol: .x),
                        onPressed: provider.isSaving
                            ? null
                            : () {
                                provider.retakePhoto(imagePath);
                                Navigator.of(context).pop(false);
                              },
                      ),

                      // Save button
                      SketchyIconButton(
                        icon: SketchySymbol(symbol: .check),
                        onPressed: provider.isSaving
                            ? null
                            : () async {
                                try {
                                  await provider.savePhoto(imagePath);

                                  if (context.mounted) {
                                    SketchySnackBar.show(
                                      context,
                                      message: provider.successMessage,
                                    );
                                    Navigator.of(context).pop(true);
                                  }
                                } on AppError catch (e) {
                                  if (context.mounted) {
                                    context.showErrorSnackBar(e);
                                  }
                                }
                              },
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
