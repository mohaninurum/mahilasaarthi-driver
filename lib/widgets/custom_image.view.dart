import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mahilasaarthi/constants/app_images.dart';
import 'package:mahilasaarthi/widgets/busy_indicator.dart';
import 'package:velocity_x/velocity_x.dart';

class CustomImage extends StatelessWidget {
  const CustomImage({
    required this.imageUrl,
    this.height = Vx.dp40,
    this.width,
    this.boxFit,
    this.defaultImage,
    Key? key,
  }) : super(key: key);

  final String imageUrl;
  final double height;
  final double? width;
  final BoxFit? boxFit;
  final String? defaultImage;

  String get formattedUrl {
    String url = imageUrl.trim();
    if (url.isEmpty) return "";
    url = url
        .replaceAll("mahila-sarthi.mytechbro.com", "admin.mahilasaarthi.in")
        .replaceAll("///admin.mahilasaarthi.in//", "admin.mahilasaarthi.in/")
        .replaceAll("https://admin.mahilasaarthi.in//", "https://admin.mahilasaarthi.in/");
    if (!url.startsWith("http")) {
      if (!url.startsWith("/")) {
        url = "/$url";
      }
      url = "https://admin.mahilasaarthi.in$url";
    }
    return url;
  }

  @override
  Widget build(BuildContext context) {
    final cleanUrl = formattedUrl;
    final Widget fallbackWidget = defaultImage != null && defaultImage!.isNotEmpty
        ? Image.asset(
            defaultImage!,
            fit: this.boxFit ?? BoxFit.contain,
            height: this.height,
            width: this.width ?? this.height,
          )
        : SizedBox(
            height: this.height,
            width: this.width ?? this.height,
          );

    if (cleanUrl.isEmpty || !cleanUrl.startsWith("http")) {
      return fallbackWidget;
    }
    return CachedNetworkImage(
      imageUrl: cleanUrl,
      fit: this.boxFit ?? BoxFit.contain,
      progressIndicatorBuilder: (context, imageURL, progress) =>
          BusyIndicator().centered(),
      errorWidget: (context, url, error) => fallbackWidget,
    ).h(this.height).w(this.width ?? this.height);
  }
}
