import 'package:onchain_swap_example/future/pages/setting/setting.dart';
import 'package:onchain_swap_example/future/pages/swap/widget/home.dart';
import 'package:onchain_swap_example/future/pages/swap/widget/import_provider.dart';
import 'package:onchain_swap_example/future/widgets/widgets/material_page.dart';
import 'package:flutter/material.dart';

class PageRouter {
  static const String home = '/';
  static const String settings = '/settings';
  static const String providers = '/providers';
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return MaterialPageView(child: _page(settings.name));
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
        settings: settings,
        reverseTransitionDuration: const Duration(milliseconds: 300),
        allowSnapshotting: false,
        fullscreenDialog: false,
        opaque: false);
  }

  static Widget _page(String? name) {
    switch (name) {
      case providers:
        return const HTTPServiceProviderFields();
      case settings:
        return const AppSettingView();
      default:
        return const HomeScreen();
    }
  }
}
