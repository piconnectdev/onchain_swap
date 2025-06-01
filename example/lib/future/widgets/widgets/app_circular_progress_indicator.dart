import 'package:onchain_swap_example/future/widgets/custom_widgets.dart';
import 'package:flutter/material.dart';

class APPCircularProgressIndicator extends StatelessWidget {
  const APPCircularProgressIndicator(
      {super.key,
      this.color,
      this.size = WidgetConstant.circularProgressIndicatorSize});
  final Color? color;
  final Size size;
  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
        size: size, child: CircularProgressIndicator(color: color));
  }
}
