import 'dart:io';

import 'package:flutter/material.dart';
import 'package:framatic/core/errors/app_error.dart';
import 'package:framatic/core/extensions/error_extension.dart';
import 'package:framatic/core/widgets/circular_action_button.dart';
import 'package:framatic/features/photo_preview/presentation/photo_preview_provider.dart';
import 'package:provider/provider.dart';
import 'package:sketchy_design_lang/sketchy_design_lang.dart';

class PhotoPreviewScreen extends StatelessWidget {
  final String imagePath;

  const PhotoPreviewScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return SketchyScaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(child: Image.file(File(imagePath), fit: BoxFit.contain)),
            ),
            Consumer<PhotoPreviewProvider>(
              builder: (context, provider, _) {
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
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
                      CircularActionButton(
                        icon: Icons.check,
                        label: 'Save',
                        isPrimary: true,
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
