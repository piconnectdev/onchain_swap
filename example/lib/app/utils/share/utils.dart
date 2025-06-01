import 'package:onchain_swap_example/app/native_impl/cross/share.dart';
import 'package:on_chain_bridge/models/models.dart';

class ShareUtils {
  static Future<bool> shareFile(String path, String fileName,
      {String? text, String? subject, FileMimeTypes? mimeType}) async {
    return await ShareImpl.shareFile(path, fileName,
        subject: subject, text: text, mimeType: mimeType);
  }
}
