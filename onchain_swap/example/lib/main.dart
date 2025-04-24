import 'dart:async';

import 'package:example/app/constants/constants.dart';
import 'package:example/app/constants/state.dart';
import 'package:example/app/logging/logging.dart';
import 'package:example/app/models/models/setting.dart';
import 'package:example/future/pages/swap/controller/controller.dart';
import 'package:example/future/router/router.dart';
import 'package:example/future/widgets/widgets/scroll_behavior.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mrt_native_support/platform_interface.dart';

import 'future/state_managment/state_managment.dart';
import 'future/theme/theme.dart';

Future<APPSetting> _readSetting() async {
  final config = await PlatformInterface.instance.getConfig();
  final settings =
      await PlatformInterface.instance.readSecure('ST_app_setting');
  return APPSetting.fromHex(settings, config);
}

void main() async {
  runZonedGuarded(_runApplication, (error, stack) {
    APPLogging.error("Guarded $error $stack");
  });
}

void _runApplication() async {
  WidgetsFlutterBinding.ensureInitialized();
  final setting = await _readSetting();
  ThemeController.fromAppSetting(setting);

  runApp(StateRepository(child: OnChainSwap(setting)));
}

class OnChainSwap extends StatelessWidget {
  final APPSetting setting;
  const OnChainSwap(this.setting, {super.key});

  @override
  Widget build(BuildContext context) {
    return MrtViewBuilder<HomeStateController>(
      controller: () => HomeStateController(appSetting: setting),
      removable: false,
      stateId: StateConst.main,
      repositoryId: StateConst.main,
      builder: (m) {
        final appPlatform = PlatformInterface.appPlatform;
        return MaterialApp(
            scaffoldMessengerKey: StateRepository.messengerKey(context),
            title: APPConst.name,
            scrollBehavior: AppScrollBehavior(platform: appPlatform),
            builder: (context, child) {
              ThemeController.updatePrimary(context.theme);
              return MediaQuery(
                  data: context.mediaQuery.copyWith(
                      textScaler: context.mediaQuery.textScaler
                          .clamp(maxScaleFactor: 1.4)),
                  child: child!);
            },
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: ThemeController.appTheme,
            darkTheme: ThemeController.appTheme,
            locale: ThemeController.locale,
            onGenerateRoute: PageRouter.onGenerateRoute,
            initialRoute: PageRouter.home,
            navigatorObservers: [MyRouteObserver()],
            showSemanticsDebugger: false,
            debugShowCheckedModeBanner: false,
            color: ThemeController.appTheme.colorScheme.primary,
            navigatorKey: StateRepository.navigatorKey(context));
      },
    );
  }
}

class MyRouteObserver extends RouteObserver<PageRoute<dynamic>> {}
