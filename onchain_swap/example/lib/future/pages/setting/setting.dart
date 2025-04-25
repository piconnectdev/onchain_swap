import 'package:example/app/constants/constants.dart';
import 'package:example/app/constants/state.dart';
import 'package:example/app/uri/utils.dart';
import 'package:example/future/pages/swap/controller/controller.dart';
import 'package:example/future/router/router.dart';
import 'package:example/future/state_managment/state_managment.dart';
import 'package:example/future/theme/theme.dart';
import 'package:example/future/widgets/custom_widgets.dart';
import 'package:example/marketcap/prices/currency.dart';
import 'package:flutter/material.dart';
import 'color_selector.dart';
import 'providers.dart';

class AppSettingView extends StatelessWidget {
  const AppSettingView({super.key});

  @override
  Widget build(BuildContext context) {
    final wallet = context.mainController;
    return MrtViewBuilder<HomeStateController>(
        controller: () => context.mainController,
        repositoryId: StateConst.main,
        removable: false,
        builder: (controller) {
          return ScaffoldPageView(
            appBar: AppBar(title: Text("settings".tr)),
            child: SingleChildScrollView(
              child: ConstraintsBoxView(
                padding: WidgetConstant.paddingHorizontal20,
                child: Column(
                  children: [
                    AppListTile(
                      onTap: () {
                        context.to(PageRouter.providers);
                      },
                      leading: const Icon(Icons.account_tree),
                      title: Text("update_network_providers".tr),
                      subtitle: Text("add_provider_desc".tr),
                    ),
                    AppListTile(
                      onTap: () {
                        controller.updateProviders(() {
                          return context.openSliverDialog(
                            label: 'update_services'.tr,
                            sliver: (context) => SelectSwapProvidersView(),
                          );
                        });
                      },
                      leading: const Icon(Icons.account_tree),
                      title: Text("swap_services".tr),
                      subtitle: Text("enable_disable_swap_service_desc".tr),
                    ),
                    const Divider(),
                    AppListTile(
                      leading: const Icon(Icons.currency_bitcoin),
                      title: AppDropDownBottom(
                        items: {
                          for (final i in Currency.values)
                            i: RichText(
                              overflow: TextOverflow.ellipsis,
                              text: TextSpan(
                                  style: context.textTheme.labelLarge,
                                  text: i.name.toUpperCase(),
                                  children: [
                                    TextSpan(
                                        text: " (${i.currencyName})",
                                        style: context.textTheme.bodyMedium)
                                  ]),
                            )
                        },
                        label: "toggle_currency".tr,
                        value: wallet.appSetting.currency,
                        onChanged: wallet.changeCurrency,
                        isExpanded: true,
                      ),
                    ),
                    AppListTile(
                      onTap: controller.toggleBrightness,
                      leading:
                          ThemeController.appTheme.brightness == Brightness.dark
                              ? const Icon(Icons.dark_mode)
                              : const Icon(Icons.light_mode),
                      trailing: Switch(
                        value: ThemeController.appTheme.brightness ==
                            Brightness.dark,
                        onChanged: (value) => controller.toggleBrightness(),
                      ),
                      title: Text("dark_mode".tr),
                      subtitle: Text("adjust_app_brightness".tr),
                    ),
                    AppListTile(
                      onTap: () {
                        controller.changeColor(() async {
                          return context.openSliverDialog<Color>(
                            label: "primary_color_palette".tr,
                            widget: (ctx) => const ColorSelectorModal(),
                          );
                        });
                      },
                      leading: const Icon(Icons.color_lens),
                      title: Text("primary_color_palette".tr),
                      subtitle: Text("define_primary_of_app".tr),
                    ),
                    const Divider(),
                    AppListTile(
                      title: Text("home_page".tr),
                      leading: const Icon(Icons.home),
                      onTap: () {
                        UriUtils.lunch(APPConst.homepage);
                      },
                    ),
                    WidgetConstant.height20,
                  ],
                ),
              ),
            ),
          );
        });
  }
}
