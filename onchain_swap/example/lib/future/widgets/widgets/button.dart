import 'package:example/app/types/types.dart';
import 'package:flutter/material.dart';

class FixedElevatedButton extends StatelessWidget {
  const FixedElevatedButton({
    required this.onPressed,
    required this.child,
    this.activePress,
    this.padding = EdgeInsets.zero,
    this.focusNode,
    this.height,
    this.width,
    super.key,
  }) : icon = null;
  const FixedElevatedButton.icon({
    required Widget label,
    required this.onPressed,
    required Icon this.icon,
    this.height,
    this.width,
    this.padding = EdgeInsets.zero,
    this.focusNode,
    this.activePress,
    super.key,
  }) : child = label;
  final DynamicVoid? onPressed;
  final Widget child;
  final EdgeInsets padding;
  final Icon? icon;
  final FocusNode? focusNode;
  final bool? activePress;
  final double? height;
  final double? width;
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: padding,
        child: SizedBox(
          height: height,
          width: width,
          child: icon != null
              ? ElevatedButton.icon(
                  focusNode: focusNode,
                  onPressed: (activePress ?? true) ? onPressed : null,
                  autofocus: true,
                  icon: icon!,
                  label: child)
              : ElevatedButton(
                  onPressed: (activePress ?? true) ? onPressed : null,
                  focusNode: focusNode,
                  autofocus: true,
                  child: child,
                ),
        ));
  }
}
