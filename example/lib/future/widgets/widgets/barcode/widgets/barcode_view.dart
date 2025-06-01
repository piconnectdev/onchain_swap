import 'package:onchain_swap_example/app/constants/constants.dart';
import 'package:onchain_swap_example/app/utils/share/utils.dart';
import 'package:onchain_swap_example/future/state_managment/state_managment.dart';
import 'package:onchain_swap_example/future/widgets/widgets/barcode/qr_code/qr_view.dart';
import 'package:onchain_swap_example/future/widgets/widgets/constraints_box_view.dart';
import 'package:onchain_swap_example/future/widgets/widgets/progress_bar/progress.dart';
import 'package:onchain_swap_example/future/widgets/widgets/widget_constant.dart';
import 'package:flutter/material.dart';
import 'package:on_chain_bridge/models/share/share.dart';

class BarcodeView extends StatefulWidget {
  const BarcodeView(
      {super.key,
      required this.title,
      required this.barcodeData,
      this.underBarcodeWidget,
      this.shareSubject,
      this.shareText,
      this.underBarcode,
      this.secure = false});
  final Widget title;
  final String barcodeData;
  final String? underBarcode;
  final Widget? underBarcodeWidget;
  final String? shareText;
  final String? shareSubject;
  final bool secure;

  @override
  State<BarcodeView> createState() => _BarcodeViewState();
}

class _BarcodeViewState extends State<BarcodeView> with SafeState {
  final buttonState = GlobalKey<StreamWidgetState>();
  bool showBarcode = false;
  Future<void> share() async {
    buttonState.process();
    try {
      final toFile = await QrUtils.qrCodeToFile(
          data: widget.barcodeData,
          uderImage: widget.underBarcode ?? widget.barcodeData,
          color: context.theme.colorScheme);

      if (!context.mounted) return;
      await ShareUtils.shareFile(toFile!.$1, toFile.$2,
          subject: widget.shareSubject,
          text: widget.shareText,
          mimeType: FileMimeTypes.imagePng);
      // buttonState.success();
    } catch (e) {
      // buttonState.error();
    }
  }

  void show() {
    showBarcode = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.title,
        WidgetConstant.divider,
        WidgetConstant.height20,
        ConstraintsBoxView(
          maxHeight: APPConst.qrCodeWidth,
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: WidgetConstant.border8,
                child: QrImageView(
                  data: widget.barcodeData,
                  backgroundColor: context.colors.secondary,
                  errorStateBuilder: (context, error) =>
                      WidgetConstant.errorIcon,
                  eyeStyle: QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: context.theme.colorScheme.onSecondary,
                  ),
                  dataModuleStyle: QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: context.theme.colorScheme.onSecondary,
                  ),
                ),
              ),
              if (widget.secure)
                Positioned.fill(
                    child: AnimatedSwitcher(
                  duration: APPConst.animationDuraion,
                  child: SizedBox(
                    width: context.mediaQuery.size.width,
                    key: ValueKey(showBarcode),
                    child: !showBarcode
                        ? Container(
                            decoration: BoxDecoration(
                                borderRadius: WidgetConstant.border8,
                                color: context.colors.secondaryContainer
                                    .wOpacity(0.98)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FilledButton.icon(
                                    onPressed: show,
                                    icon: const Icon(Icons.remove_red_eye),
                                    label: Text("show_barcode".tr))
                              ],
                            ),
                          )
                        : WidgetConstant.sizedBox,
                  ),
                ))
            ],
          ),
        ),
        WidgetConstant.height20,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ButtonProgress(
              backToIdle: APPConst.animationDuraion,
              key: buttonState,
              child: (context) => IconButton.filled(
                onPressed: share,
                icon: const Icon(Icons.share),
              ),
            )
          ],
        ),
        widget.underBarcodeWidget ?? WidgetConstant.sizedBox,
      ],
    );
  }
}

class BarcodeImageView extends StatelessWidget {
  final String data;
  const BarcodeImageView({required this.data, super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: WidgetConstant.border8,
      child: SizedBox(
        width: APPConst.qrCodeWidth,
        child: QrImageView(
          data: data,
          backgroundColor: context.colors.secondary,
          errorStateBuilder: (context, error) => WidgetConstant.errorIcon,
          eyeStyle: QrEyeStyle(
            eyeShape: QrEyeShape.square,
            color: context.theme.colorScheme.onSecondary,
          ),
          dataModuleStyle: QrDataModuleStyle(
            dataModuleShape: QrDataModuleShape.square,
            color: context.theme.colorScheme.onSecondary,
          ),
        ),
      ),
    );
  }
}

class BarcodeImageIconView extends StatelessWidget {
  const BarcodeImageIconView({required this.data, this.color, super.key});
  final String data;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return IconButton(
        color: color,
        onPressed: () {
          context.openSliverDialog(
            label: '',
            maxWidth: APPConst.qrCodeWidth,
            widget: (context) => BarcodeImageView(data: data),
            actions: (p0) => [
              IconButton(
                  onPressed: () async {
                    await QrUtils.qrCodeToFile(
                        data: data,
                        uderImage: '',
                        color: context.theme.colorScheme);
                  },
                  icon: Icon(Icons.share))
            ],
          );
        },
        icon: Icon(Icons.qr_code_2));
  }
}
