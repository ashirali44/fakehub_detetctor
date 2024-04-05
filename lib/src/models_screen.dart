import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:ui' as ui;

class ModelScreen extends StatefulWidget {
  const ModelScreen({super.key});

  @override
  State<ModelScreen> createState() => _ModelScreendState();
}

class _ModelScreendState extends State<ModelScreen> {
  String modelSelected = '';
  XFile? iimageFile;
  List<Face>? facess =[];
  ui.Image? iimage;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: () async {
          final interpreter = await tfl.Interpreter.fromAsset('assets/BaseB0.tflite');

        },
        child: Icon(
            color: Colors.white,
            Icons.arrow_forward_ios
        ),
      ),
      appBar: AppBar(
        title: Text('Choose your model'),
        centerTitle: true,
        elevation: 1,
      ),
      body: Column(
        children: [
          Row(
            children: [
              ChooseModel('FLDD-B0'),
              SizedBox(width: 10,),
              ChooseModel('FLDD-B1'),
            ],
          ),
          SizedBox(height: 10,),
          Row(
            children: [
              ChooseModel('Base-B0'),
              SizedBox(width: 10,),
              ChooseModel('Base-B1'),
            ],
          )
        ],
      ).marginOnly(top: 20,left: 25,right: 25),

    );
  }


  Widget ChooseModel(String name){
    return Expanded(
      child: InkWell(
        onTap: (){
          setState(() {
            modelSelected = name;
          });
        },
        child: Container(
          height: 70,
          color: modelSelected == name ? Colors.black : Colors.white,
          width: MediaQuery.of(context).size.width,
          child: DottedBorder(
            dashPattern: [10, 10],
            radius: Radius.circular(20),
            color: Colors.black,
            strokeWidth: 3,
            child: iimageFile == null
                ? Center(
              child: Text(name,style: GoogleFonts.inter(
                fontWeight : FontWeight.bold,
                fontSize : 20,
                color: modelSelected == name ? Colors.white : Colors.black,
              ),),
            )
                : Image.file(File(iimageFile!.path)),
          ),
        ),
      ),
    );
  }



}

