import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:fakehub_detetctor/src/utils.dart';
import 'package:flutter/widgets.dart';
import 'package:image/image.dart' as img;

import 'dart:ui';
import 'package:fakehub_detetctor/src/detector.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tflite/tflite.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:fakehub_detetctor/src/models_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:ui' as ui;
import 'package:image/image.dart' as imageLib;

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  XFile? iimageFile;
  List<Face>? facess =[];
  var data;
  ui.Image? iimage;
  List<dynamic> finalCroppedImage= [];



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: InkWell(
        onTap: (){
          if(facess!.length>0){
            Get.to(ModelScreen(
              images: finalCroppedImage,
              iimageFile: iimageFile,facess: facess,
            ));
          }else{
            ShowToastMobileApp('No Faces Detected');
          }
        },
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(width: 3, color: Colors.black)),
          height: 60,
          width: MediaQuery.of(context).size.width,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              Text(
                'Continue',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Icon(
                Icons.arrow_forward,
                color: Colors.black,
              ),

            ],
          ),
        ),
      ).marginOnly(left: 25,right: 25,bottom: 20),
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
                    : Center(child: Image.file(File(iimageFile!.path))),
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          InkWell(
            onTap: () {
             if(iimageFile!=null){
               detectImage();
             }else{
               ShowToastMobileApp('No Image Selected');
             }
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
          facess!.length> 0 ? Expanded(
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: GridView.builder(
                itemCount: facess!.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4, crossAxisSpacing: 14.0, mainAxisSpacing: 14.0),
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    height: 100,
                    width: 100,
                    child: FaceCropperWidget(
                      imagePath: iimageFile!.path,
                      faceRect: facess![index].boundingBox,
                    ),
                  );
                },
              ),

            ),
          ) : SizedBox()
        ],
      ).marginOnly(left: 25, right: 25, top: 20),
    );
  }

  Future<void> uploadImage() async {
    var image = (await ImagePicker().pickImage(source: ImageSource.gallery));
     data = await File(image!.path).readAsBytes();
    await decodeImageFromList(data).then((value) => setState(() {
      iimage = value;
    }));
    setState(() {
      iimageFile = image;
    });
  }

  void detectImage() async {
    facess = [];
    finalCroppedImage = [];
    final image = InputImage.fromFilePath(iimageFile!.path);
    final faceDetector = GoogleMlKit.vision.faceDetector(FaceDetectorOptions(
        performanceMode: FaceDetectorMode.accurate, enableLandmarks: true));
    List<Face> faces = await faceDetector.processImage(image);
    facess = faces;
    setState(() {

    });
    for (int i = 0; i < facess!.length; i++) {
      img.Image cropOne = img.copyCrop(
        img.decodeImage(data!)!,
       x: facess![i].boundingBox.left.toInt(),
       y:  facess![i].boundingBox.top.toInt(),
       height:  facess![i].boundingBox.width.toInt(),
      width:   facess![i].boundingBox.height.toInt(),
      );
    //  finalCroppedImage.add(Image.memory(img.encodePng(cropOne)));
      // Save the image to the local directory
      final directory = await getApplicationDocumentsDirectory();
      String imagePath = '${directory.path}/image$i.png';
      await File(imagePath).writeAsBytes(img.encodePng(cropOne));
      print(imagePath);
      finalCroppedImage.add(imagePath);
    }

    // final interpreter = await tfl.Interpreter.fromAsset('assets/BaseB0.tflite');
    //

    //
    // var output = List.filled(1, [0.0, 0.0]); // Placeholder, replace with actual output structure
    // interpreter.run(inputImage!.buffer.asUint8List(), output);
    // print(output);


  }




}

class FaceImagePainter extends CustomPainter {
  ui.Image resImage;

  Rect rectCrop;

  FaceImagePainter(this.resImage, this.rectCrop);

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final Size imageSize =
    Size(resImage.width.toDouble(), resImage.height.toDouble());
    FittedSizes sizes = applyBoxFit(BoxFit.cover, imageSize, size);

    Rect inputSubRect = rectCrop;
    final Rect outputSubRect =
    Alignment.center.inscribe(sizes.destination, rect);

    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill
      ..strokeWidth = 4;
    canvas.drawRect(rect, paint);

    canvas.drawImageRect(resImage, inputSubRect, outputSubRect, Paint());
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class ImageUtils {
  static Future<ui.Image> getUiImage({
    String? imageUrl,
    String? imagePath,
  }) async {
    Completer<ImageInfo> completer = Completer();
    ImageProvider? img;
    if (imageUrl != null) {
      img = NetworkImage(imageUrl);
    } else if (imagePath != null) {
      img = FileImage(File(imagePath));
    }
    img
        ?.resolve(const ImageConfiguration())
        .addListener(ImageStreamListener((ImageInfo info, bool _) {
      completer.complete(info);
    }));
    ImageInfo imageInfo = await completer.future;
    return imageInfo.image;
  }
}