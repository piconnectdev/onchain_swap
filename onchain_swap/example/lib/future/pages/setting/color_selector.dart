import 'package:example/app/constants/constants.dart';
import 'package:example/app/types/types.dart';
import 'package:example/future/state_managment/state_managment.dart';
import 'package:example/future/widgets/custom_widgets.dart';
import 'package:flutter/material.dart';

typedef OnSelectColor = void Function(Color?);

class ColorSelectorIconView extends StatelessWidget {
  const ColorSelectorIconView(this.onSelectColor, {super.key});
  final OnSelectColor onSelectColor;

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () {
          context
              .openSliverDialog<Color>(
                  label: "primary_color_palette".tr,
                  widget: (ctx) => const ColorSelectorModal())
              .then(onSelectColor);
        },
        icon: const Icon(Icons.color_lens));
  }
}

class BrightnessToggleIcon extends StatelessWidget {
  const BrightnessToggleIcon(
      {required this.onToggleBrightness, required this.brightness, super.key});
  final DynamicVoid onToggleBrightness;
  final Brightness brightness;

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: onToggleBrightness,
        icon: brightness == Brightness.dark
            ? const Icon(Icons.dark_mode)
            : const Icon(Icons.light_mode));
  }
}

class ColorSelectorModal extends StatelessWidget {
  const ColorSelectorModal({super.key});
  static const List<Color> defaultColors = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
    Colors.black,
  ];
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageTitleSubtitle(title: null, body: Text("select_color_from_blow".tr)),
        WidgetConstant.height20,
        Wrap(
          children: List.generate(defaultColors.length, (index) {
            return InkWell(
              onTap: () {
                context.pop(defaultColors[index]);
              },
              child: Padding(
                padding: WidgetConstant.padding10,
                child: Icon(
                  Icons.color_lens,
                  color: defaultColors[index],
                  size: APPConst.double40,
                ),
              ),
            );
          }),
        )
      ],
    );
  }
}
