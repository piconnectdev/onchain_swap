import 'package:example/app/native_impl/core/core.dart';
import 'package:mrt_native_support/models/share/share.dart';
import 'package:mrt_native_support/platform_interface.dart';

mixin ShareImpl {
  static Future<bool> shareFile(String path, String fileName,
      {String? text, String? subject, FileMimeTypes? mimeType}) async {
    if (PlatformInterface.isWindows) {
      return await AppNativeMethods.platform.launchUri(path);
    }

    return await AppNativeMethods.platform.share(Share.file(path, fileName,
        subject: subject, text: text, mimeType: mimeType));
  }
}
