import 'package:example/future/state_managment/state_managment.dart';
import 'package:example/future/widgets/widgets/sliver/widgets/sliver_cross_axis_constrained.dart';
import 'package:flutter/material.dart';
import 'widget_constant.dart';

class ConstraintsBoxView extends StatelessWidget {
  final Widget child;
  const ConstraintsBoxView(
      {required this.child,
      this.maxWidth = 650,
      this.maxHeight = double.infinity,
      this.alignment = Alignment.topCenter,
      super.key,
      this.padding = EdgeInsets.zero});
  final double? maxWidth;
  final double? maxHeight;
  final EdgeInsets padding;
  final Alignment alignment;
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(
            maxWidth: maxWidth ?? double.infinity,
            maxHeight: maxHeight ?? double.infinity),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

class PageConstraintsBoxView extends StatelessWidget {
  final Widget child;
  const PageConstraintsBoxView(
      {required this.child,
      this.maxWidth = 650,
      this.maxHeight = double.infinity,
      this.alignment = Alignment.topCenter,
      super.key});
  final double? maxWidth;
  final double? maxHeight;
  final Alignment alignment;
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(
            maxWidth: maxWidth ?? double.infinity,
            maxHeight: maxHeight ?? double.infinity),
        child: Padding(
          padding: WidgetConstant.paddingHorizontal20,
          child: child,
        ),
      ),
    );
  }
}

class SliverConstraintsBoxView extends StatelessWidget {
  final Widget sliver;
  const SliverConstraintsBoxView(
      {required this.sliver,
      this.maxWidth = 650,
      super.key,
      this.padding = EdgeInsets.zero,
      this.alignment = 0});
  final double? maxWidth;
  final EdgeInsets padding;
  final double alignment;
  @override
  Widget build(BuildContext context) {
    return SliverCrossAxisConstrained(
      alignment: alignment,
      maxCrossAxisExtent: maxWidth ?? context.mediaQuery.size.width,
      child: SliverPadding(padding: padding, sliver: sliver),
    );
  }
}

class SliverPageConstraintsBoxView extends StatelessWidget {
  final Widget sliver;
  const SliverPageConstraintsBoxView(
      {required this.sliver,
      this.maxWidth = 650,
      super.key,
      this.alignment = 0});
  final double? maxWidth;
  final double alignment;
  @override
  Widget build(BuildContext context) {
    return SliverCrossAxisConstrained(
      alignment: alignment,
      maxCrossAxisExtent: maxWidth ?? context.mediaQuery.size.width,
      child: SliverPadding(
          padding: WidgetConstant.paddingHorizontal20, sliver: sliver),
    );
  }
}
