import 'package:cached_network_image/cached_network_image.dart';
import 'package:cash_register/model/environment.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NetworkImageWidget extends StatelessWidget {
  final String image;
  const NetworkImageWidget({
    super.key,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(9), // Image border
        child: SizedBox.fromSize(
          // child: Image.network("${Environment.imageBaseUrl}$image",
          //     fit: BoxFit.fitHeight),
          child: CachedNetworkImage(
            imageUrl: "${Environment.imageBaseUrl}$image",
            fit: BoxFit.fill,
            progressIndicatorBuilder: (context, url, downloadProgress) =>
                CircularProgressIndicator(value: downloadProgress.progress),
            errorWidget: (context, url, error) => Icon(Icons.error),
          ),
        ),
      ),
    );
  }
}
