import 'package:example/app/constants/constants.dart';
import 'package:example/app/types/types.dart';
import 'package:example/app/uri/utils.dart';
import 'package:example/future/state_managment/state_managment.dart';
import 'package:example/future/widgets/widgets/assets_image.dart';
import 'package:example/future/widgets/widgets/constraints_box_view.dart';
import 'package:example/future/widgets/widgets/container_with_border.dart';
import 'package:example/future/widgets/widgets/copy_icon_widget.dart';
import 'package:example/future/widgets/widgets/error_text_container.dart';
import 'package:example/future/widgets/widgets/large_text_view.dart';
import 'package:example/future/widgets/widgets/progress_bar/progress.dart';
import 'package:example/future/widgets/widgets/secure_content_view.dart';
import 'package:example/future/widgets/widgets/widget_constant.dart';
import 'package:flutter/material.dart';
import 'package:onchain_swap/onchain_swap.dart';

Widget get initializeProgressWidget =>
    ProgressWithTextView(text: "initializing_requirements".tr);

class SuccessTransactionTextView extends StatelessWidget {
  const SuccessTransactionTextView(
      {super.key,
      required this.txIds,
      required this.network,
      this.additionalWidget,
      this.error});
  final List<String> txIds;
  final SwapNetwork network;
  final WidgetContext? additionalWidget;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final Widget successTrText = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleNetworkImageView(network, radius: APPConst.double80),
        Text(network.name, style: context.textTheme.labelLarge),
        WidgetConstant.height20,
        ListView.separated(
            shrinkWrap: true,
            itemBuilder: (context, index) {
              final id = txIds[index];
              final txUrl = network.txUrl(id);
              return ContainerWithBorder(
                  child: Row(
                children: [
                  Expanded(
                    child: CopyableTextWidget(
                        isSensitive: false,
                        text: txIds[index],
                        color: context.onPrimaryContainer),
                  ),
                  if (txUrl != null)
                    IconButton(
                        onPressed: () {
                          UriUtils.lunch(txUrl);
                        },
                        icon: Icon(Icons.open_in_new,
                            color: context.colors.onPrimaryContainer))
                ],
              ));
            },
            separatorBuilder: (context, index) => WidgetConstant.divider,
            itemCount: txIds.length),
        WidgetConstant.height20,
        if (additionalWidget != null) additionalWidget!(context),
        ErrorTextContainer(error: error),
      ],
    );

    return _ProgressWithTextView(
        text: successTrText, icon: WidgetConstant.sizedBox);
  }
}

class ProgressWithTextView extends StatelessWidget {
  const ProgressWithTextView(
      {super.key,
      required this.text,
      this.icon,
      this.style,
      this.bottomWidget});
  final String text;
  final Widget? icon;
  final TextStyle? style;
  final Widget? bottomWidget;

  @override
  Widget build(BuildContext context) {
    return _ProgressWithTextView(
        text: Column(
          children: [
            LargeTextView([text],
                maxLine: 3, textAligen: TextAlign.center, style: style),
            if (bottomWidget != null) bottomWidget!
          ],
        ),
        icon: icon);
  }
}

class ErrorWithTextView extends StatelessWidget {
  const ErrorWithTextView({super.key, required this.text, this.progressKey});
  final String text;
  final GlobalKey<PageProgressBaseState>? progressKey;

  @override
  Widget build(BuildContext context) {
    return _ProgressWithTextView(
        text: Column(
          children: [
            ConstraintsBoxView(
              maxHeight: 120,
              child: Container(
                padding: WidgetConstant.padding10,
                decoration: BoxDecoration(
                    borderRadius: WidgetConstant.border8,
                    color: context.colors.errorContainer),
                child: SingleChildScrollView(
                  child: SelectableText(
                    text,
                    textAlign: TextAlign.center,
                    style: context.textTheme.bodyMedium
                        ?.copyWith(color: context.colors.onErrorContainer),
                  ),
                ),
              ),
            ),
            if (progressKey != null) ...[
              WidgetConstant.height20,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FilledButton.icon(
                      onPressed: () {
                        progressKey?.backToIdle();
                      },
                      icon: const Icon(Icons.arrow_back),
                      label: Text("back_to_the_page".tr))
                ],
              )
            ],
          ],
        ),
        icon: WidgetConstant.errorIconLarge);
  }
}

class SuccessWithTextView extends StatelessWidget {
  const SuccessWithTextView({super.key, required this.text, this.icon});
  final String text;
  final IconData? icon;
  @override
  Widget build(BuildContext context) {
    return _ProgressWithTextView(
        text: Text(text, textAlign: TextAlign.center),
        icon: icon != null
            ? Icon(icon, size: APPConst.double80)
            : WidgetConstant.checkCircleLarge);
  }
}

class SuccessBarcodeProgressView extends StatefulWidget {
  const SuccessBarcodeProgressView(
      {super.key,
      required this.text,
      required this.bottomWidget,
      this.secure = false,
      this.secureButtonText});
  final String text;
  final Widget bottomWidget;
  final bool secure;
  final String? secureButtonText;

  @override
  State<SuccessBarcodeProgressView> createState() =>
      _SuccessBarcodeProgressViewState();
}

class _SuccessBarcodeProgressViewState extends State<SuccessBarcodeProgressView>
    with SafeState {
  late bool isSecure = widget.secure;
  void onShowContent() {
    isSecure = !isSecure;
    updateState();
  }

  @override
  Widget build(BuildContext context) {
    return _ProgressWithTextView(
        text: Column(
          children: [
            SecureContentView(
              show: !isSecure,
              showButtonTitle: widget.secureButtonText?.tr ?? "show_content".tr,
              onTapShow: onShowContent,
              widgetContent: ContainerWithBorder(
                  child: CopyTextIcon(
                      isSensitive: widget.secure,
                      dataToCopy: widget.text,
                      widget: Text(widget.text, maxLines: 3))),
            ),
            WidgetConstant.height8,
            widget.bottomWidget
          ],
        ),
        icon: WidgetConstant.checkCircleLarge);
  }
}

class SuccessWithButtonView extends StatelessWidget {
  const SuccessWithButtonView(
      {super.key,
      this.text,
      required this.buttonText,
      this.buttonWidget,
      required this.onPressed})
      : assert(text != null || buttonWidget != null,
            "use text or buttonWidget for child");
  final String? text;
  final String buttonText;
  final Widget? buttonWidget;
  final DynamicVoid onPressed;

  @override
  Widget build(BuildContext context) {
    return _ProgressWithTextView(
        text: Column(
          children: [
            buttonWidget ?? Text(text!, textAlign: TextAlign.center),
            WidgetConstant.height8,
            FilledButton(onPressed: onPressed, child: Text(buttonText))
          ],
        ),
        icon: WidgetConstant.checkCircleLarge);
  }
}

class _ProgressWithTextView extends StatelessWidget {
  const _ProgressWithTextView({required this.text, this.icon});
  final Widget text;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        icon ?? const CircularProgressIndicator(),
        WidgetConstant.height8,
        text,
      ],
    );
  }
}

enum ProgressMultipleTextViewStatus { error, success }

class ProgressMultipleTextViewObject {
  final ProgressMultipleTextViewStatus status;
  final String text;
  final bool enableCopy;
  final String? openUrl;
  bool get isSuccess => status == ProgressMultipleTextViewStatus.success;
  const ProgressMultipleTextViewObject(
      {required this.status,
      required this.text,
      required this.enableCopy,
      this.openUrl});
  factory ProgressMultipleTextViewObject.success({
    required String message,
    String? openUrl,
    bool enableCopy = true,
  }) {
    return ProgressMultipleTextViewObject(
        status: ProgressMultipleTextViewStatus.success,
        text: message,
        enableCopy: enableCopy,
        openUrl: openUrl);
  }
  factory ProgressMultipleTextViewObject.error(
      {required String message, bool enableCopy = false}) {
    return ProgressMultipleTextViewObject(
        status: ProgressMultipleTextViewStatus.error,
        text: message,
        enableCopy: enableCopy);
  }
}
