import 'package:onchain_swap_example/future/state_managment/state_managment.dart';
import 'package:onchain_swap_example/future/widgets/widgets/animated/animation.dart';
import 'package:onchain_swap_example/future/widgets/widgets/container_with_border.dart';
import 'package:onchain_swap_example/future/widgets/widgets/widget_constant.dart';
import 'package:flutter/widgets.dart';

typedef SHIMMERBUILDER = Widget Function(bool enable, BuildContext context);

class Shimmer extends StatelessWidget {
  final int count;
  final bool sliver;
  final bool enable;
  final SHIMMERBUILDER onActive;
  const Shimmer(
      {this.count = 3,
      required this.onActive,
      this.sliver = false,
      required this.enable,
      super.key});
  // final Widget shimmerBox;
  @override
  Widget build(BuildContext context) {
    return APPAnimated(
        isActive: enable,
        onDeactive: (context) => IgnorePointer(
            child:
                ShimmerWidget(count: count, child: onActive(enable, context))),
        onActive: (context) => onActive(enable, context));
  }
}

class ShimmerWidget extends StatefulWidget {
  final Widget child;
  final int count;

  const ShimmerWidget(
      {super.key, this.child = const ShimmerBox(), required this.count});

  @override
  State<ShimmerWidget> createState() => _ShimmerWidgetState();
}

class _ShimmerWidgetState extends State<ShimmerWidget>
    with SafeState<ShimmerWidget>, SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                context.colors.inverseSurface.wOpacity(0.1),
                context.colors.inverseSurface.wOpacity(0.3),
                context.colors.inverseSurface.wOpacity(0.5),
                context.colors.inverseSurface.wOpacity(0.7),
                context.colors.inverseSurface.wOpacity(0.9),
              ],
              stops: [0.1, 0.3, 0.6, 0.8, 1],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              transform: _GradientTransform(_animation.value),
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: ListView.builder(
            itemBuilder: (context, index) {
              return widget.child;
            },
            itemCount: widget.count,
            shrinkWrap: true,
            physics: WidgetConstant.noScrollPhysics,
          ),
        );
      },
      child: widget.child,
    );
  }
}

class _GradientTransform extends GradientTransform {
  final double slideValue;
  const _GradientTransform(this.slideValue);

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slideValue, 0.0, 0.0);
  }
}

class ShimmerBox extends StatelessWidget {
  final BoxConstraints? constraints;
  const ShimmerBox(
      {super.key, this.constraints = WidgetConstant.constraintsMinHeight80});

  @override
  Widget build(BuildContext context) {
    return ContainerWithBorder(
      constraints: constraints,
      child: Row(children: []),
    );
  }
}
