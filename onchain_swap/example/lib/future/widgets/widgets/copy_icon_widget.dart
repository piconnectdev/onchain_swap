import 'dart:async';
import 'package:example/app/constants/constants.dart';
import 'package:example/app/utils/method.dart';
import 'package:flutter/material.dart';
import 'package:example/app/utils/platform/utils.dart';
import 'package:example/future/state_managment/state_managment.dart';
import 'package:example/future/widgets/widgets/animated/widgets/animated_switcher.dart';
import 'widget_constant.dart';

enum _CopyTextStatus {
  idlle,
  pending,
  success,
  error;

  bool get isIdle => this == idlle;
}

mixin _CopyTextState<T extends StatefulWidget> on SafeState<T> {
  String get dataToCopy;
  String? get message;
  bool get isSensitive;
  _CopyTextStatus status = _CopyTextStatus.idlle;
  void onTap(BuildContext context) async {
    if (!status.isIdle) return;
    status = _CopyTextStatus.pending;
    updateState();
    final response = await PlatformUtils.writeClipboard(dataToCopy);
    if (response) {
      status = _CopyTextStatus.success;
      if (context.mounted) {
        context.showAlert(message ?? "copied_to_clipboard".tr);
      }
    } else {
      status = _CopyTextStatus.error;
      if (context.mounted) {
        context.showAlert("copied_to_clipboard_faild".tr);
      }
    }
    await Future.delayed(APPConst.animationDuraion);
    updateState();
    await Future.delayed(APPConst.oneSecoundDuration);
    status = _CopyTextStatus.idlle;
    updateState();

    if (!isSensitive) return;
    _resetClipoard(dataToCopy);
  }

  static void _resetClipoard(String txt) {
    MethodUtils.after(() async {
      final data = await PlatformUtils.readClipboard();
      if (data != txt) return;
      PlatformUtils.writeClipboard('');
    }, duration: APPConst.tenSecoundDuration);
  }
}

class CopyTextIcon extends StatefulWidget {
  const CopyTextIcon(
      {super.key,
      required this.dataToCopy,
      this.widget,
      this.size,
      this.messaage,
      this.color,
      this.isSensitive = false});

  final String dataToCopy;
  final double? size;
  final String? messaage;
  final Color? color;
  final Widget? widget;
  final bool isSensitive;

  @override
  State<CopyTextIcon> createState() => CopyTextIconState();
}

class CopyTextIconState extends State<CopyTextIcon>
    with SafeState, _CopyTextState {
  @override
  String get dataToCopy => widget.dataToCopy;

  @override
  bool get isSensitive => widget.isSensitive;

  @override
  String? get message => widget.messaage;

  @override
  Widget build(BuildContext context) {
    final icon = IconButton(
      onPressed: () => onTap(context),
      icon: APPAnimatedSwitcher(enable: status, widgets: {
        _CopyTextStatus.idlle: (context) =>
            Icon(Icons.copy, size: widget.size, color: widget.color),
        _CopyTextStatus.pending: (context) => SizedBox(
            width: widget.size ?? APPConst.iconSize,
            height: widget.size ?? APPConst.iconSize,
            child: CircularProgressIndicator(color: widget.color)),
        _CopyTextStatus.success: (context) =>
            Icon(Icons.check_circle, size: widget.size, color: widget.color),
        _CopyTextStatus.error: (context) =>
            Icon(Icons.error, size: widget.size, color: context.colors.error)
      }),
    );
    return InkWell(
      onTap: () => onTap(context),
      customBorder: RoundedRectangleBorder(
        borderRadius: WidgetConstant.border8,
      ),
      child: widget.widget != null
          ? Row(
              children: [
                Expanded(child: widget.widget!),
                WidgetConstant.width8,
                icon
              ],
            )
          : icon,
    );
  }
}

///
class CopyableTextWidget extends StatefulWidget {
  const CopyableTextWidget(
      {super.key,
      required this.text,
      this.maxLines = 1,
      this.size,
      this.messaage,
      this.color,
      this.widget,
      this.isSensitive = false});

  final String text;
  final double? size;
  final String? messaage;
  final Color? color;
  final Widget? widget;
  final bool isSensitive;
  final int? maxLines;

  @override
  State<CopyableTextWidget> createState() => CopyableTextWidgetState();
}

class CopyableTextWidgetState extends State<CopyableTextWidget>
    with SafeState, _CopyTextState {
  @override
  String get dataToCopy => widget.text;

  @override
  bool get isSensitive => widget.isSensitive;

  @override
  String? get message => widget.messaage;

  @override
  Widget build(BuildContext context) {
    final icon = IconButton(
      onPressed: () => onTap(context),
      icon: APPAnimatedSwitcher(enable: status, widgets: {
        _CopyTextStatus.idlle: (context) =>
            Icon(Icons.copy, size: widget.size, color: widget.color),
        _CopyTextStatus.pending: (context) => SizedBox(
            width: widget.size ?? APPConst.iconSize,
            height: widget.size ?? APPConst.iconSize,
            child: CircularProgressIndicator(color: widget.color)),
        _CopyTextStatus.success: (context) =>
            Icon(Icons.check_circle, size: widget.size, color: widget.color),
        _CopyTextStatus.error: (context) =>
            Icon(Icons.error, size: widget.size, color: context.colors.error)
      }),
    );
    return InkWell(
      onTap: () => onTap(context),
      customBorder: RoundedRectangleBorder(
        borderRadius: WidgetConstant.border8,
      ),
      child: Row(
        children: [
          Expanded(
              child: widget.widget ??
                  Text(
                    widget.text,
                    style: context.textTheme.bodyMedium
                        ?.copyWith(color: widget.color),
                    maxLines: widget.maxLines,
                    overflow: TextOverflow.ellipsis,
                  )),
          WidgetConstant.width8,
          icon
        ],
      ),
    );
  }
}
