import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'home.dart';

class FaceCropperWidget extends StatelessWidget {
  final String? imagePath;
  final String? imageUrl;
  final Rect faceRect;
  final double? width;
  final double? height;
  final BoxShape? shape;
  const FaceCropperWidget({
    super.key,
    this.imagePath,
    this.imageUrl,
    required this.faceRect,
    this.width,
    this.height,
    this.shape,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      width: width,
      height: height,
      decoration: BoxDecoration(
        shape: shape ?? BoxShape.rectangle,
      ),
      alignment: Alignment.center,
      child: FutureBuilder(
        future: ImageUtils.getUiImage(
          imageUrl: imageUrl,
          imagePath: imagePath,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.data != null) {
            // If the Future is complete, display the preview.
            return paintImage(snapshot.data!!);
          } else {
            // Otherwise, display a loading indicator.
            return const CircularProgressIndicator();
          }
        },
      ),
    );
  }

  Widget paintImage(ui.Image image) {
    return CustomPaint(
      painter: FaceImagePainter(
        image,
        faceRect,
      ),
      child: SizedBox(
        width: faceRect.width,
        height: faceRect.height,
      ),
    );
  }
}