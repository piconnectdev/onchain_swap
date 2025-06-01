import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:onchain_bridge/models/device/models/platform.dart';

class AppScrollBehavior extends MaterialScrollBehavior {
  AppScrollBehavior({required this.platform});
  final AppPlatform platform;
  late final bool isWindowsOrWeb = platform == AppPlatform.windows ||
      platform == AppPlatform.web ||
      platform == AppPlatform.macos;
  @override
  late final Set<PointerDeviceKind> dragDevices = isWindowsOrWeb
      ? {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
        }
      : super.dragDevices;
}
