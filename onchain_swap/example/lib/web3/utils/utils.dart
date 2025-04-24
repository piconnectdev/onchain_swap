import 'package:example/app/image/image.dart';

class Web3WalletUtils {
  static final _base64ImageDataRegex =
      RegExp(r'^data:image\/(svg\+xml|webp|png|gif);base64,([A-Za-z0-9+/=]+)$');
  static BaseAPPImage? parseBase64Image(String? dataUri) {
    if (dataUri == null) return null;
    final match = _base64ImageDataRegex.firstMatch(dataUri);
    return APPImageMemory.base64(match?.group(2),
        imageType: dataUri.contains('svg') ? ImageType.svg : ImageType.gpg);
  }

  static BaseAPPImage? parseWalletImage(String? url) {
    return APPImage.network(url) ?? parseBase64Image(url);
  }
}
