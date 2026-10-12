import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../config/api_config.dart';

class FlagImage extends StatelessWidget {
  const FlagImage({
    super.key,
    required this.code,
    this.width = 48,
    this.height = 32,
  });

  final String code;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final placeholder = Container(
      width: width,
      height: height,
      color: colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.flag_outlined,
        size: height * 0.6,
        color: colorScheme.onSurfaceVariant,
      ),
    );

    if (code.isEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: placeholder,
      );
    }

    final size = width > 100 ? 'w320' : 'w160';

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: CachedNetworkImage(
        imageUrl: ApiConfig.flagUrl(size, code),
        width: width,
        height: height,
        fit: BoxFit.cover,
        placeholder: (context, url) => placeholder,
        errorWidget: (context, url, error) => placeholder,
      ),
    );
  }
}
