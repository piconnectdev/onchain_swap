import 'package:example/app/constants/constants.dart';
import 'package:example/future/state_managment/state_managment.dart';
import 'package:example/future/widgets/widgets/animated/widgets/animated_switcher.dart';
import 'package:flutter/material.dart';

import 'widget_constant.dart';

class EmptyItemSliverWidgetView extends StatelessWidget {
  const EmptyItemSliverWidgetView({
    required this.isEmpty,
    required this.itemBuilder,
    super.key,
    this.icon,
    this.subject,
  });
  final bool isEmpty;
  final IconData? icon;
  final String? subject;
  final WidgetContext itemBuilder;
  @override
  Widget build(BuildContext context) {
    return APPSliverAnimatedSwitcher<bool>(enable: isEmpty, widgets: {
      true: (context) => SliverFillRemaining(
          child: NoItemFoundWidget(icon: icon, message: subject)),
      false: itemBuilder
    });
  }
}

class EmptyItemWidgetView extends StatelessWidget {
  const EmptyItemWidgetView({
    required this.isEmpty,
    required this.builder,
    super.key,
    this.icon,
    this.subject,
  });
  final bool isEmpty;
  final IconData? icon;
  final String? subject;
  final WidgetContext builder;
  @override
  Widget build(BuildContext context) {
    return APPAnimatedSwitcher(
        height: context.mediaQuery.size.height,
        enable: isEmpty,
        widgets: {
          true: (c) => Row(
                children: [
                  Expanded(
                    child: NoItemFoundWidget(),
                  ),
                ],
              ),
          false: (c) => builder(context)
        });
  }
}

class NoItemFoundWidget extends StatelessWidget {
  const NoItemFoundWidget({this.icon, this.message, super.key});
  final IconData? icon;
  final String? message;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon ?? Icons.hourglass_empty, size: APPConst.double80),
        WidgetConstant.height8,
        Text(message ?? "no_items_found".tr,
            style: context.textTheme.titleMedium),
      ],
    );
  }
}
