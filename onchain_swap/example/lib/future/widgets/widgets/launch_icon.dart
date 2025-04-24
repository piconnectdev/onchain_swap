import 'package:example/app/uri/utils.dart';
import 'package:example/future/state_managment/state_managment.dart';
import 'package:flutter/material.dart';

class LaunchBrowserIcon extends StatelessWidget {
  const LaunchBrowserIcon(
      {required this.url, this.color, super.key, this.size});
  final String? url;
  final Color? color;
  final double? size;
  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () {
          if (url == null) {
            context.showAlert("url_does_not_exists".tr);
            return;
          }
          UriUtils.lunch(url);
        },
        icon: Icon(Icons.launch, size: size, color: color));
  }
}
