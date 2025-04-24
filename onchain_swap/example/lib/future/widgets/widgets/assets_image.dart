import 'package:onchain_swap/onchain_swap.dart';
import 'package:example/app/image/image.dart';
import 'package:example/future/image/memory_image.dart';
import 'package:flutter/material.dart';
import 'package:example/future/state_managment/state_managment.dart';

class CircleAssetImageView extends StatelessWidget {
  const CircleAssetImageView(this.image,
      {this.onProgress,
      this.onError,
      this.radius = 120,
      super.key,
      this.onNull = "U",
      this.imageColor});
  final BaseAPPImage? image;
  final double radius;
  final String onNull;
  final FuncWidgetContext? onProgress;
  final FuncWidgetContext? onError;
  final Color? imageColor;

  @override
  Widget build(BuildContext context) {
    if (image == null) {
      return _CircleAPPImageView(
          radius: radius, onNull: onNull, child: onError?.call(context));
    }
    return ClipOval(
      child: Image(
          color: imageColor,
          fit: BoxFit.fitWidth,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress != null && onProgress != null) {
              return onProgress!.call(context);
            }
            if (loadingProgress == null) {
              return _CircleAPPImageView(
                  radius: radius, onNull: onNull, child: child);
            }
            return _CircleAPPImageView(
                radius: radius, onNull: onNull, child: null);
          },
          image: CacheNetworkMemoryImageProvider(image),
          errorBuilder: (context, error, stackTrace) {
            return _CircleAPPImageView(
                radius: radius, onNull: onNull, child: onError?.call(context));
          }),
    );
  }
}

class CircleAPPImageView extends StatelessWidget {
  const CircleAPPImageView(this.url,
      {this.onProgress,
      this.onError,
      this.radius = 120,
      super.key,
      this.onNull = "U",
      this.imageColor});
  final String? url;
  final double radius;
  final String onNull;
  final FuncWidgetContext? onProgress;
  final FuncWidgetContext? onError;
  final Color? imageColor;

  @override
  Widget build(BuildContext context) {
    if (url == null) {
      return _CircleAPPImageView(
          radius: radius, onNull: onNull, child: onError?.call(context));
    }
    return ClipOval(
      child: Image(
          color: imageColor,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress != null && onProgress != null) {
              return onProgress!.call(context);
            }
            if (loadingProgress == null) {
              return _CircleAPPImageView(
                  radius: radius, onNull: onNull, child: child);
            }
            return _CircleAPPImageView(
                radius: radius, onNull: onNull, child: null);
          },
          image: CacheNetworkMemoryImageProvider.network(url),
          errorBuilder: (context, error, stackTrace) {
            return _CircleAPPImageView(
                radius: radius, onNull: onNull, child: onError?.call(context));
          }),
    );
  }
}

class _CircleAPPImageView extends StatelessWidget {
  const _CircleAPPImageView(
      {this.child, required this.radius, required this.onNull});
  final double radius;
  final String onNull;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final size = radius * 2;
    return ClipOval(
      child: Container(
        decoration: BoxDecoration(
            color: child != null
                ? context.colors.transparent
                : context.colors.primaryContainer,
            shape: BoxShape.circle),
        width: size,
        height: size,
        child: Center(
          child: child ??
              Text(
                onNull,
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: radius),
              ),
        ),
      ),
    );
  }
}

class CircleTokenImageView extends StatelessWidget {
  const CircleTokenImageView(this.token,
      {this.imageColor, this.radius = 40, super.key});
  final BaseSwapAsset? token;
  final double radius;
  final Color? imageColor;

  @override
  Widget build(BuildContext context) {
    String symbol = token == null
        ? "U"
        : (token!.symbol.isEmpty ? "" : token!.symbol[0]).toUpperCase();
    return CircleAPPImageView(
      token?.logoUrl,
      onNull: symbol,
      radius: radius,
      imageColor: imageColor,
    );
  }
}

class CircleServiceProviderImageView extends StatelessWidget {
  const CircleServiceProviderImageView(this.provider,
      {this.radius = 40, super.key});
  final SwapServiceProvider? provider;
  final double radius;

  @override
  Widget build(BuildContext context) {
    String symbol = provider?.name.nullOnEmpty?[0].toUpperCase() ?? "U";
    return CircleAPPImageView(provider?.logoUrl,
        onNull: symbol, radius: radius);
  }
}

class CircleNetworkImageView extends StatelessWidget {
  const CircleNetworkImageView(this.network, {this.radius = 40, super.key});
  final SwapNetwork? network;
  final double radius;

  @override
  Widget build(BuildContext context) {
    String symbol = network?.name.nullOnEmpty?[0].toUpperCase() ?? "U";
    return CircleAPPImageView(network?.logoUrl, onNull: symbol, radius: radius);
  }
}
