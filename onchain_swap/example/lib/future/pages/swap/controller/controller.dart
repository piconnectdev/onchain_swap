import 'package:example/app/constants/state.dart' show StateConst;
import 'package:example/app/http/impl/impl.dart';
import 'package:example/app/models/models/setting.dart';
import 'package:example/future/pages/swap/controller/swap.dart';
import 'package:example/future/state_managment/state_managment.dart';
import 'package:example/future/theme/theme.dart';
import 'package:example/marketcap/prices/currency.dart';
import 'package:example/marketcap/prices/live_currency.dart';
import 'package:example/repository/network.dart';
import 'package:flutter/material.dart';

typedef ONUPDATEPROVIDERS = Future<void> Function();
typedef ONUPDATECOLOR = Future<Color?> Function();

class HomeStateController extends StateController
    with NetworkRepository, SwapStateController, HttpImpl, LiveCurrencies {
  APPSetting _appSetting;
  HomeStateController({required APPSetting appSetting})
      : _appSetting = appSetting;
  @override
  APPSetting get appSetting => _appSetting;

  void setAppSetting(APPSetting setting) {
    _appSetting = setting;
  }

  Future<void> toggleBrightness() async {
    ThemeController.toggleBrightness();
    notify();
    notify(StateConst.main);
    _appSetting = _appSetting.copyWith(
        appBrightness: ThemeController.appBrightness,
        appColor: ThemeController.appColorHex);
    saveAppSetting(_appSetting);
  }

  Future<void> changeColor(ONUPDATECOLOR onUpdate) async {
    final color = await onUpdate();
    if (color == null) return;
    ThemeController.changeColor(color);
    notify();
    notify(StateConst.main);
    _appSetting = _appSetting.copyWith(
        appBrightness: ThemeController.appBrightness,
        appColor: ThemeController.appColorHex);
    saveAppSetting(_appSetting);
  }

  Future<void> updateProviders(ONUPDATEPROVIDERS onUpdate) async {
    final settings = _appSetting;
    await onUpdate();
    if (settings != _appSetting) {
      await saveAppSetting(_appSetting);
      initSwap();
    }
  }

  @override
  Future<void> changeCurrency(Currency? currency) async {
    if (currency == null || _appSetting.currency == currency) return;
    super.changeCurrency(currency);
    _appSetting = _appSetting.copyWith(currency: currency);
    saveAppSetting(_appSetting);
  }
}
