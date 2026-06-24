import 'package:flutter/widget_previews.dart';
import 'package:flutter/widgets.dart';
import 'package:framatic/core/sketch_ui/sketch_ui.dart';

/// Supplies the app's sketch theme and a local overlay to every preview.
Widget wrapSketchPreview(Widget child) {
  return Builder(
    builder: (context) {
      final theme = MediaQuery.platformBrightnessOf(context) == Brightness.dark
          ? SketchThemeCatalog.graphiteDark
          : SketchThemeCatalog.graphiteLight;

      return SketchTheme(
        data: theme,
        background: SketchBackgroundCatalog.isometricDots,
        child: DefaultTextStyle(
          style: theme.bodyText,
          child: ColoredBox(
            color: theme.background,
            child: Overlay(
              initialEntries: [
                OverlayEntry(
                  builder: (context) =>
                      Padding(padding: const EdgeInsets.all(16), child: child),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

@Preview(
  group: 'Sketch UI · Controls',
  name: 'Controls · Light',
  size: Size(390, 620),
  brightness: Brightness.light,
  wrapper: wrapSketchPreview,
)
@Preview(
  group: 'Sketch UI · Controls',
  name: 'Controls · Dark',
  size: Size(390, 620),
  brightness: Brightness.dark,
  wrapper: wrapSketchPreview,
)
Widget sketchControlsPreview() => const _SketchControlsCatalog();

@Preview(
  group: 'Sketch UI · Forms',
  name: 'Form fields · Light',
  size: Size(390, 360),
  brightness: Brightness.light,
  wrapper: wrapSketchPreview,
)
@Preview(
  group: 'Sketch UI · Forms',
  name: 'Form fields · Dark',
  size: Size(390, 360),
  brightness: Brightness.dark,
  wrapper: wrapSketchPreview,
)
Widget sketchFormFieldsPreview() => const _SketchFormCatalog();

@Preview(
  group: 'Sketch UI · Feedback',
  name: 'Dialog and toast · Light',
  size: Size(390, 430),
  brightness: Brightness.light,
  wrapper: wrapSketchPreview,
)
@Preview(
  group: 'Sketch UI · Feedback',
  name: 'Dialog and toast · Dark',
  size: Size(390, 430),
  brightness: Brightness.dark,
  wrapper: wrapSketchPreview,
)
Widget sketchFeedbackPreview() => const _SketchFeedbackCatalog();

class _SketchControlsCatalog extends StatefulWidget {
  const _SketchControlsCatalog();

  @override
  State<_SketchControlsCatalog> createState() => _SketchControlsCatalogState();
}

class _SketchControlsCatalogState extends State<_SketchControlsCatalog> {
  bool _selected = true;
  double _sliderValue = 0.6;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PreviewHeading('Buttons'),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              SketchButton(label: 'Enabled', onPressed: () {}),
              SketchButton(
                label: 'Primary',
                primary: true,
                filled: true,
                onPressed: () {},
              ),
              SketchButton(
                label: 'Danger',
                danger: true,
                filled: true,
                onPressed: () {},
              ),
              const SketchButton(label: 'Disabled', onPressed: null),
            ],
          ),
          const _PreviewGap(),
          const _PreviewHeading('Icon buttons'),
          Row(
            children: [
              SketchIconButton(
                icon: SketchIconType.add,
                tooltip: 'Add frame',
                primary: true,
                filled: true,
                onPressed: () {},
              ),
              const SizedBox(width: 12),
              SketchIconButton(
                icon: SketchIconType.edit,
                tooltip: 'Edit frame',
                onPressed: () {},
              ),
              const SizedBox(width: 12),
              const SketchIconButton(
                icon: SketchIconType.delete,
                tooltip: 'Delete disabled',
                danger: true,
                onPressed: null,
              ),
            ],
          ),
          const _PreviewGap(),
          const _PreviewHeading('Selection'),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              SketchChip(
                label: '4:3',
                selected: _selected,
                onSelected: () => setState(() => _selected = !_selected),
              ),
              SketchChip(label: '16:9', selected: false, onSelected: () {}),
            ],
          ),
          const SizedBox(height: 14),
          SketchSlider(
            value: _sliderValue,
            semanticLabel: 'Preview value',
            onChanged: (value) => setState(() => _sliderValue = value),
          ),
          const _PreviewGap(),
          const _PreviewHeading('Loading'),
          const Row(
            children: [
              SketchProgress(),
              SizedBox(width: 12),
              Text('Preparing preview…'),
            ],
          ),
        ],
      ),
    );
  }
}

class _SketchFormCatalog extends StatefulWidget {
  const _SketchFormCatalog();

  @override
  State<_SketchFormCatalog> createState() => _SketchFormCatalogState();
}

class _SketchFormCatalogState extends State<_SketchFormCatalog> {
  final _errorFormKey = GlobalKey<FormState>();
  late final TextEditingController _filledController;
  late final TextEditingController _emptyController;

  @override
  void initState() {
    super.initState();
    _filledController = TextEditingController(text: 'Landscape');
    _emptyController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _errorFormKey.currentState?.validate();
    });
  }

  @override
  void dispose() {
    _filledController.dispose();
    _emptyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PreviewHeading('Filled'),
          SketchFormInput(
            controller: _filledController,
            label: 'Frame name',
            hint: 'Give the frame a name',
          ),
          const _PreviewGap(),
          const _PreviewHeading('Validation error'),
          Form(
            key: _errorFormKey,
            child: SketchFormInput(
              controller: _emptyController,
              label: 'Width',
              hint: 'Enter a positive number',
              validator: (value) =>
                  value == null || value.isEmpty ? 'Width is required' : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _SketchFeedbackCatalog extends StatelessWidget {
  const _SketchFeedbackCatalog();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SketchDialog(
            title: 'Delete frame?',
            actions: [
              SketchButton(label: 'Cancel', onPressed: () {}),
              SketchButton(
                label: 'Delete',
                danger: true,
                filled: true,
                onPressed: () {},
              ),
            ],
            child: const Text('This action cannot be undone.'),
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: [
              SketchButton(
                label: 'Success toast',
                onPressed: () => SketchToast.show(context, 'Frame saved'),
              ),
              SketchButton(
                label: 'Error toast',
                danger: true,
                onPressed: () => SketchToast.show(
                  context,
                  'Could not save frame',
                  isError: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PreviewHeading extends StatelessWidget {
  const _PreviewHeading(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(label, style: SketchTheme.of(context).title),
    );
  }
}

class _PreviewGap extends StatelessWidget {
  const _PreviewGap();

  @override
  Widget build(BuildContext context) => const SizedBox(height: 24);
}
