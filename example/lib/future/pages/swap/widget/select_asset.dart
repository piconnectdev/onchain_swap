import 'package:onchain_swap_example/future/pages/swap/controller/controller.dart';
import 'package:on_chain_swap/on_chain_swap.dart';
import 'package:onchain_swap_example/app/constants/constants.dart';
import 'package:onchain_swap_example/future/state_managment/state_managment.dart';
import 'package:onchain_swap_example/future/widgets/custom_widgets.dart';
import 'package:flutter/material.dart';

class SwapSelectAssetView extends StatefulWidget {
  final bool isSource;
  const SwapSelectAssetView(this.isSource, {super.key});

  @override
  State<SwapSelectAssetView> createState() => _AsseetsState();
}

class _AsseetsState extends State<SwapSelectAssetView>
    with SafeState<SwapSelectAssetView> {
  Map<SwapNetwork, Set<BaseSwapAsset>> _assets = {};
  Set<BaseSwapAsset> allAssets = {};
  Set<BaseSwapAsset> assets = {};
  int selectedIndex = 0;
  List<SwapNetwork> networks = [];
  late HomeStateController controller;
  String name = '';

  @override
  void onInitOnce() {
    super.onInitOnce();
    controller = context.mainController;
    if (widget.isSource) {
      _assets = controller.sourceAssets;
    } else {
      _assets = controller.destinationAssets;
    }
    networks = _assets.keys.toList();
    onDestinationSelected(0);
  }

  void filterAssets() {
    final n = name.trim().toLowerCase();
    if (name.isEmpty) {
      assets = allAssets;
    } else {
      assets = allAssets
          .where((e) =>
              e.symbol.toLowerCase().contains(n) ||
              (e.fullName?.toLowerCase().contains(n) ?? false))
          .toSet();
    }
    updateState();
  }

  void onChange(String v) {
    name = v;
    filterAssets();
  }

  void onSelectAsset(BaseSwapAsset asset) {
    if (widget.isSource) {
      controller.updateSourceAsset(asset);
    } else {
      controller.updateDestinationAsset(asset);
    }
    context.pop();
  }

  void onDestinationSelected(int index) {
    selectedIndex = index;
    final network = networks.elementAt(index);
    allAssets = _assets[network] ?? {};
    filterAssets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          onChanged: onChange,
          decoration: InputDecoration(
              filled: true,
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(borderSide: BorderSide.none)),
        ),
      ),
      body: Row(children: [
        Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                      maxWidth: APPConst.naviationRailWidth),
                  child: IntrinsicHeight(
                    child: NavigationRail(
                        useIndicator: true,
                        onDestinationSelected: onDestinationSelected,
                        labelType: NavigationRailLabelType.none,
                        destinations: List.generate(networks.length, (index) {
                          final network = networks[index];
                          return _NavigationRailDestination(
                              network: network, disabled: false);
                        }),
                        selectedIndex: selectedIndex),
                  ),
                ),
              ),
            ),
          ],
        ),
        Expanded(
            child: APPAnimated(
                isActive: true,
                onActive: (context) => CustomScrollView(
                      key: ValueKey(assets.length),
                      slivers: [
                        EmptyItemSliverWidgetView(
                          isEmpty: assets.isEmpty,
                          icon: Icons.token,
                          subject: 'no_token_found'.tr,
                          itemBuilder: (context) {
                            return SliverList.builder(
                              itemBuilder: (context, index) {
                                final asset = assets.elementAt(index);
                                final url = asset.assetUrl();
                                return ContainerWithBorder(
                                  onRemoveIcon: ConditionalWidget(
                                      enable: url != null,
                                      onActive: (context) => LaunchBrowserIcon(
                                          url: url,
                                          color: context.onPrimaryContainer)),
                                  onRemove: () => onSelectAsset(asset),
                                  child: Row(children: [
                                    Stack(
                                      children: [
                                        CircleTokenImageView(asset,
                                            radius: APPConst.circleRadius25),
                                        Align(
                                            alignment: Alignment.bottomRight,
                                            child: CircleNetworkImageView(
                                                asset.network,
                                                radius: 10))
                                      ],
                                    ),
                                    WidgetConstant.width8,
                                    Expanded(
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                          Text(asset.symbol,
                                              style: context.onPrimaryTextTheme
                                                  .titleMedium),
                                          Text(asset.fullName ?? '',
                                              style: context.onPrimaryTextTheme
                                                  .bodySmall),
                                        ])),
                                  ]),
                                );
                              },
                              // separatorBuilder: (context, index) => WidgetConstant.divider,
                              itemCount: assets.length,
                              addAutomaticKeepAlives: false,
                              addRepaintBoundaries: false,
                              addSemanticIndexes: false,
                            );
                          },
                        ),
                        WidgetConstant.sliverPaddingVertial40,
                      ],
                    ),
                onDeactive: (context) => WidgetConstant.sizedBox))
      ]),
    );
  }
}

class _NavigationRailDestination extends NavigationRailDestination {
  _NavigationRailDestination(
      {required SwapNetwork? network, required super.disabled})
      : super(
            label: WidgetConstant.sizedBox,
            icon: Opacity(
                opacity: disabled ? 0.3 : 1,
                child: CircleNetworkImageView(network, radius: 15)));
}

// class _AssetProviderView extends StatelessWidget {
//   final SwapServiceProvider provider;
//   const _AssetProviderView({required this.provider, super.key});

//   @override
//   Widget build(BuildContext context) {
//     return TappedTooltipView(
//       tooltipWidget: ToolTipView(
//           message: provider.name,
//           child: Opacity(
//             opacity: 0.7,
//             child: CircleServiceProviderImageView(provider,
//                 radius: APPConst.circleRadius10),
//           )),
//     );
//   }
// }
