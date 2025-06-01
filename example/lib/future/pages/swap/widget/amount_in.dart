import 'package:blockchain_utils/utils/numbers/rational/big_rational.dart';
import 'package:onchain_swap/onchain_swap.dart';
import 'package:onchain_swap_example/app/types/types.dart';
import 'package:onchain_swap_example/future/state_managment/state_managment.dart';
import 'package:onchain_swap_example/future/text_field/input_formaters.dart';
import 'package:onchain_swap_example/future/widgets/custom_widgets.dart';
import 'package:flutter/material.dart';

class SetupSwapAmoutView extends StatelessWidget {
  final BaseSwapAsset? sourceAsset;
  final DynamicVoid onChangeAsset;
  const SetupSwapAmoutView(
      {super.key, required this.onChangeAsset, required this.sourceAsset});

  @override
  Widget build(BuildContext context) {
    final controller = context.mainController;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ContainerWithBorder(
          onRemove: onChangeAsset,
          onRemoveIcon: IconButton(
              onPressed: onChangeAsset,
              icon: Icon(Icons.edit, color: context.colors.onPrimaryContainer)),
          child: Stack(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 70,
                    height: 70,
                    child: Material(
                      elevation: 5,
                      color: context.colors.primaryContainer,
                      shape: CircleBorder(),
                      child: Stack(
                        children: [
                          CircleTokenImageView(sourceAsset, radius: 35),
                          // Align(
                          //   alignment: Alignment.bottomCenter,
                          //   child: Container(
                          //     width: 70,
                          //     height: 35,
                          //     decoration: BoxDecoration(
                          //         borderRadius: BorderRadius.only(
                          //             bottomRight: Radius.circular(35),
                          //             bottomLeft: Radius.circular(35)),
                          //         // shape: BoxShape.circle,
                          //         color: context.colors.onSurface.wOpacity(0.8)),
                          //     child: InkWell(
                          //         hoverColor: context.colors.transparent,
                          //         onTap: onChangeAsset,
                          //         child: Icon(
                          //           Icons.edit,
                          //           color: context.colors.surface,
                          //         )),
                          //   ),
                          // ),

                          Align(
                            alignment: Alignment.topRight,
                            child: CircleNetworkImageView(sourceAsset?.network,
                                radius: 10),
                          )
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: controller.amountController,
                      style: context.textTheme.titleLarge?.copyWith(
                          color: context.colors.onSecondaryContainer,
                          fontSize: 30,
                          fontWeight: FontWeight.bold),
                      maxLines: 1,
                      cursorColor: context.colors.onSecondaryContainer,
                      inputFormatters: [
                        BigRetionalRangeTextInputFormatter(
                            min: BigRational.zero,
                            allowSign: false,
                            allowDecimal: true,
                            maxScale: sourceAsset?.decimal),
                      ],
                      textAlign: TextAlign.start,
                      decoration: InputDecoration(
                          hintText: "0.0",
                          fillColor: context.colors.onSecondaryContainer,
                          filled: false,
                          focusedBorder:
                              OutlineInputBorder(borderSide: BorderSide.none),
                          enabledBorder:
                              OutlineInputBorder(borderSide: BorderSide.none)),
                    ),
                  ),
                ],
              ),
              LiveWidget(() {
                final amount = controller.inputPrice.value;
                return Positioned(
                  bottom: 0,
                  left: 85,
                  child: APPAnimated(
                    isActive: true,
                    onActive: (context) => CoinStringPriceView(
                      key: ValueKey(amount),
                      balance: amount,
                      style: context.onPrimaryTextTheme.labelMedium,
                      symbolColor: context.onPrimaryContainer,
                    ),
                    onDeactive: (context) => WidgetConstant.sizedBox,
                  ),
                );
              })
            ],
          ),
        ),
      ],
    );
  }
}
