import 'package:example/app/constants/constants.dart';
import 'package:example/app/types/types.dart';
import 'package:flutter/material.dart';
import 'container_with_border.dart';
import 'widget_constant.dart';
import 'package:example/future/state_managment/state_managment.dart';

class ErrorTextContainer extends StatelessWidget {
  const ErrorTextContainer(
      {super.key,
      required this.error,
      this.errorWidget,
      this.errorIcon,
      this.padding = WidgetConstant.padding10,
      this.margin = WidgetConstant.padding5,
      this.verticalMargin = EdgeInsets.zero,
      this.showErrorIcon = true,
      this.oTapError,
      this.enableTap = true,
      this.maxLine});
  final EdgeInsets margin;
  final EdgeInsets padding;
  final String? error;
  final EdgeInsets verticalMargin;
  final bool showErrorIcon;
  final DynamicVoid? oTapError;
  final IconData? errorIcon;
  final Widget? errorWidget;
  final bool enableTap;
  final int? maxLine;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: APPConst.animationDuraion,
      child: error == null
          ? WidgetConstant.sizedBox
          : Padding(
              padding: verticalMargin,
              child: ContainerWithBorder(
                constraints: null,
                enableTap: enableTap,
                onRemove: showErrorIcon
                    ? () {
                        oTapError?.call();
                      }
                    : null,
                margin: margin,
                padding: padding,
                onRemoveWidget: errorWidget,
                onRemoveIcon: Icon(errorIcon ?? Icons.error,
                    color: context.colors.onErrorContainer),
                backgroundColor: context.colors.errorContainer,
                child: Text(
                  error ?? "",
                  maxLines: maxLine,
                  overflow: maxLine == null ? null : TextOverflow.ellipsis,
                  style: context.textTheme.labelMedium
                      ?.copyWith(color: context.colors.onErrorContainer),
                ),
              ),
            ),
    );
  }
}

// class InsufficientBalanceErrorView extends StatelessWidget {
//   const InsufficientBalanceErrorView(
//       {required this.balance,
//       required this.token,
//       super.key,
//       this.padding = WidgetConstant.padding10,
//       this.margin = WidgetConstant.padding5,
//       this.verticalMargin = EdgeInsets.zero});
//   final BalanceCore balance;
//   final Token token;
//   final EdgeInsets margin;
//   final EdgeInsets padding;
//   final EdgeInsets verticalMargin;

//   @override
//   Widget build(BuildContext context) {
//     if (!balance.isNegative) return WidgetConstant.sizedBox;
//     final String absBalance = balance.price.replaceFirst("-", "");
//     return Padding(
//       padding: verticalMargin,
//       child: ContainerWithBorder(
//           onRemove: () {},
//           margin: margin,
//           padding: padding,
//           onRemoveIcon: const Icon(Icons.error),
//           backgroundColor: context.colors.errorContainer,
//           child: Text(
//             "insufficient_balance_error".tr.replaceOne(
//                   "$absBalance ${token.symbol}",
//                 ),
//             style: context.textTheme.labelMedium
//                 ?.copyWith(color: context.colors.onErrorContainer),
//           )),
//     );
//   }
// }
