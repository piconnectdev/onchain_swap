import 'package:example/app/constants/constants.dart';
import 'package:example/future/state_managment/state_managment.dart';
import 'package:flutter/material.dart';

class APPAnimatedContainer extends StatelessWidget {
  const APPAnimatedContainer(
      {required this.isActive,
      required this.onActive,
      required this.onDeactive,
      this.duration = APPConst.animationDuraion,
      this.alignment = Alignment.topCenter,
      super.key});
  final bool isActive;
  final WidgetContext onActive;
  final WidgetContext onDeactive;
  final Duration duration;
  final Alignment alignment;
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: duration,
      alignment: alignment,
      child: isActive ? onActive(context) : onDeactive(context),
    );
  }
}
