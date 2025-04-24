import 'dart:async';
import 'dart:ui' as ui;
import 'package:example/app/error/exception/app.dart';
import 'package:example/app/http/impl/impl.dart';
import 'package:example/app/http/models/models.dart';
import 'package:example/app/image/image.dart';
import 'package:example/app/types/types.dart';
import 'package:example/app/utils/platform/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_svg/svg.dart';

class ErrorImageStreamCompleter extends ImageStreamCompleter {
  ErrorImageStreamCompleter();
}

class CacheNetworkMemoryImageProvider
    extends ImageProvider<CacheNetworkMemoryImageProvider> with HttpImpl {
  final BaseAPPImage? url;
  CacheNetworkMemoryImageProvider(this.url);
  factory CacheNetworkMemoryImageProvider.network(String? url) {
    return CacheNetworkMemoryImageProvider(APPImage.network(url));
  }

  @override
  ImageStreamCompleter loadImage(
      CacheNetworkMemoryImageProvider key, ImageDecoderCallback decode) {
    final url = this.url;
    if (url == null) return ErrorImageStreamCompleter();
    StreamController<ImageChunkEvent>? chunkEvent;
    chunkEvent = StreamController<ImageChunkEvent>();
    chunkEvent.add(
        ImageChunkEvent(cumulativeBytesLoaded: 0, expectedTotalBytes: 100));
    switch (url.type) {
      case ContentType.network:
      case ContentType.asset:
      case ContentType.favIcon:
        final Future<ui.Codec> codec = _loadAsync(
            decode: decode,
            url: url as APPImage,
            onStreamResponse: (cumulativeBytesLoaded, expectedTotalBytes) {
              chunkEvent?.add(ImageChunkEvent(
                  cumulativeBytesLoaded: cumulativeBytesLoaded,
                  expectedTotalBytes: expectedTotalBytes));
            },
            onDone: () {
              chunkEvent?.close();
              chunkEvent = null;
            });
        return MultiFrameImageStreamCompleter(
            codec: codec,
            scale: 1.0,
            debugLabel: url.uri,
            informationCollector: () sync* {
              yield ErrorDescription('Tag: $url');
            },
            chunkEvents: chunkEvent?.stream);
      default:
        final Future<ui.Codec> codec = _loadBase64(
            decode: decode,
            image: url as APPImageMemory,
            onStreamResponse: (cumulativeBytesLoaded, expectedTotalBytes) {
              chunkEvent?.add(ImageChunkEvent(
                  cumulativeBytesLoaded: cumulativeBytesLoaded,
                  expectedTotalBytes: expectedTotalBytes));
            },
            onDone: () {
              chunkEvent?.close();
              chunkEvent = null;
            });
        return MultiFrameImageStreamCompleter(
            codec: codec,
            scale: 1.0,
            informationCollector: () sync* {
              yield ErrorDescription('Tag: $url');
            },
            chunkEvents: chunkEvent?.stream);
    }
  }

  Future<ui.ImmutableBuffer> svgStringToPngBytes(
      List<int> svgBytes, double targetWidth, double targetHeight) async {
    final PictureInfo pictureInfo = await vg.loadPicture(
        SvgBytesLoader(Uint8List.fromList(svgBytes)), null);
    final ui.Picture picture = pictureInfo.picture;
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final ui.Canvas canvas = Canvas(recorder,
        Rect.fromPoints(Offset.zero, Offset(targetWidth, targetHeight)));
    canvas.scale(targetWidth / pictureInfo.size.width,
        targetHeight / pictureInfo.size.height);
    canvas.drawPicture(picture);
    final ui.Image imgByteData = await recorder
        .endRecording()
        .toImage(targetWidth.ceil(), targetHeight.ceil());
    final ByteData? bytesData =
        await imgByteData.toByteData(format: ui.ImageByteFormat.png);
    pictureInfo.picture.dispose();
    if (bytesData == null) {
      throw AppExceptionConst.failedToLoadImage;
    }
    return ui.ImmutableBuffer.fromUint8List(bytesData.buffer.asUint8List());
  }

  Future<ui.Codec> _loadAsync(
      {required ImageDecoderCallback decode,
      required OnStreamReapose onStreamResponse,
      required DynamicVoid onDone,
      required APPImage url}) async {
    final fetch = await makeStream(uri: url.uri, onProgress: onStreamResponse);
    String header = String.fromCharCodes(fetch.result.take(100));
    ui.ImmutableBuffer buffer;
    switch (url.type) {
      case ContentType.asset:
        final bytes = await PlatformUtils.loadAssets(url.uri);
        buffer =
            await ui.ImmutableBuffer.fromUint8List(Uint8List.fromList(bytes));
        break;
      default:
        if (header.contains("<svg")) {
          buffer = await svgStringToPngBytes(fetch.result, 1024, 1024);
        } else {
          buffer = await ui.ImmutableBuffer.fromUint8List(
              Uint8List.fromList(fetch.result));
        }
        break;
    }

    return await decode(buffer);
  }

  Future<ui.Codec> _loadBase64(
      {required ImageDecoderCallback decode,
      required OnStreamReapose onStreamResponse,
      required DynamicVoid onDone,
      required APPImageMemory image}) async {
    ui.ImmutableBuffer buffer;
    switch (image.imageType) {
      case ImageType.svg:
        buffer = await svgStringToPngBytes(image.bytes, 1024, 1024);
        break;
      default:
        buffer = await ui.ImmutableBuffer.fromUint8List(
            Uint8List.fromList(image.bytes));
    }

    return await decode(buffer);
  }

  @override
  Future<CacheNetworkMemoryImageProvider> obtainKey(
      ImageConfiguration configuration) {
    return SynchronousFuture<CacheNetworkMemoryImageProvider>(this);
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is CacheNetworkMemoryImageProvider && other.url == url;
  }

  @override
  int get hashCode => url.hashCode;

  @override
  String toString() =>
      '${objectRuntimeType(this, 'CacheImageProvider')}("$url")';
}
