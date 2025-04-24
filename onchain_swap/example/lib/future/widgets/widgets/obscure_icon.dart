import 'package:example/app/constants/constants.dart';
import 'package:example/app/types/types.dart';
import 'package:flutter/material.dart';

class ObscureIcon extends StatelessWidget {
  const ObscureIcon({required this.show, required this.onTap, super.key});
  final bool show;
  final DynamicVoid onTap;
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: AnimatedSwitcher(
        duration: APPConst.animationDuraion,
        child: show
            ? const Icon(Icons.password, key: ValueKey<bool>(false))
            : const Icon(Icons.remove_red_eye, key: ValueKey<bool>(true)),
      ),
    );
  }
}
