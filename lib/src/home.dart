import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:ui' as ui;

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  XFile? iimageFile;
  List<Face>? facess =[];
  ui.Image? iimage;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('DeepFake Detector'),
        centerTitle: true,
        elevation: 1,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              uploadImage();
            },
            child: Container(
              height: 200,
              width: MediaQuery.of(context).size.width,
              child: DottedBorder(
                dashPattern: [10, 10],
                radius: Radius.circular(20),
                color: Colors.black,
                strokeWidth: 3,
                child: iimageFile == null
                    ? Center(
                        child: Text('No Image Selected'),
                      )
                    : Image.file(File(iimageFile!.path)),
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          InkWell(
            onTap: () {
              detectImage();
            },
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border.all(width: 3, color: Colors.black)),
              width: MediaQuery.of(context).size.width,
              height: 60,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.face,
                      color: Colors.white,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      'Detect Faces',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            height: 50,
          ),
          facess!.length> 0 ? Container(
            width: MediaQuery.of(context).size.width,
            // child: GridView.builder(
            //   itemCount: facess!.length,
            //   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            //       crossAxisCount: 4, crossAxisSpacing: 14.0, mainAxisSpacing: 14.0),
            //   itemBuilder: (BuildContext context, int index) {
            //     return Container(
            //       height: 100,
            //       width: 100,
            //       child:
            //     );
            //   },
            // ),
            child: CustomPaint(
              painter: FacePainter(iimage!, facess!),
            ),
          ) : SizedBox()
        ],
      ).marginOnly(left: 25, right: 25, top: 20),
    );
  }

  Future<void> uploadImage() async {
    var image = (await ImagePicker().pickImage(source: ImageSource.gallery));
    final data = await File(image!.path).readAsBytes();
    await decodeImageFromList(data).then((value) => setState(() {
      iimage = value;
    }));
    setState(() {
      iimageFile = image;
    });
  }

  void detectImage() async {
    final image = InputImage.fromFilePath(iimageFile!.path);
    final faceDetector = GoogleMlKit.vision.faceDetector(FaceDetectorOptions(
        performanceMode: FaceDetectorMode.fast, enableLandmarks: true));
    List<Face> faces = await faceDetector.processImage(image);
    facess = faces;
    setState(() {

    });
    print(faces);

    final List<ui.Image> croppedFaces = [];
    for (Face face in faces) {
      // Get face bounding box
      final Rect boundingBox = face.boundingBox;

      // Extract facial region from original image
      final croppedImage = await _cropImage(image, boundingBox);

      // Convert InputImage to ui.Image for display
      final ui.Image convertedImage = await croppedImage.toUiImage();
      croppedFaces.add(convertedImage);
    }

    // Update state to display cropped faces (assuming you have a way to manage state)
    setState(() {
      // Replace with your logic to display croppedFaces in Image.file widget(s)
    });
  }

  Future<InputImage> _cropImage(InputImage originalImage, Rect boundingBox) async {
    // Option 1: Using a File object (if applicable)
    if (originalImage.path != null) {
      final file = File(originalImage.path!);
      final imageBytes = await file.readAsBytes();
      return await _cropImageFromBytes(imageBytes, boundingBox);
    }

    // Option 2: Assuming alternative method to get image data (replace with your logic)
    // Replace with a function that provides the raw image data based on your image processing library
    // This could involve converting the image to a format like JPEG or PNG and then reading its bytes.
    // final imageBytes = ... (your logic to get image bytes);
    // return await _cropImageFromBytes(imageBytes, boundingBox);

    // Throw an exception if neither option is suitable
    throw Exception("Unsupported InputImage format for cropping");
  }

  Future<InputImage> _cropImageFromBytes(List<int> imageBytes, Rect boundingBox) async {
    final originalImageDecoder = await instantiateImageCodec(imageBytes);
    final originalImageFrame = await originalImageDecoder.getNextFrame();

    // Convert bounding box to crop rectangle (adjust if needed)
    final int cropX = boundingBox.left.toInt();
    final int cropY = boundingBox.top.toInt();
    final int cropWidth = boundingBox.width.toInt();
    final int cropHeight = boundingBox.height.toInt();

    // Check for valid crop area within image bounds
    if (cropX < 0 || cropY < 0 || cropX + cropWidth > originalImageFrame.image.width || cropY + cropHeight > originalImageFrame.image.height) {
      throw Exception("Cropping area exceeds image bounds");
    }

    // Perform image crop
    final image = originalImageFrame.image.copy(
        pixelRatio: originalImageFrame.image.pixelRatio,
        width: cropWidth,
        height: cropHeight,
        x: cropX,
        y: cropY);

    // Convert cropped image to InputImage
    final croppedImage = InputImage!.fromBytes(await image.toByteData(),
        width: cropWidth, height: cropHeight);
    return croppedImage;
  }


}


class FacePainter extends CustomPainter {
  final ui.Image image;
  final List<Face> faces;
  final List<Rect> rects = [];

  FacePainter(this.image, this.faces) {
    for (var i = 0; i < faces.length; i++) {
      rects.add(faces[i].boundingBox);
    }
  }

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Colors.red;

    canvas.drawImage(image, Offset.zero, Paint());
    for (var i = 0; i < faces.length; i++) {
      canvas.drawRect(rects[i], paint);
    }
  }

  @override
  bool shouldRepaint(FacePainter old) {
    return image != old.image  || faces != old.faces;
  }
}