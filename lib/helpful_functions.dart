import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class StaticFunctions {
  static ImageProvider generateImageProvider(String url) {
    ImageProvider imageProvider;
    try {
      if (kIsWeb) {
        imageProvider = NetworkImage(url);
      } else {
        imageProvider = CachedNetworkImageProvider(url);
      }
    } catch (e) {
      imageProvider = Image.asset('image-placeholder.png').image;
    }
    return imageProvider;
  }
}
