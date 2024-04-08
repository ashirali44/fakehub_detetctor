import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:fakehub_detetctor/src/utils.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tflite/tflite.dart';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:ui' as ui;

class ModelScreen extends StatefulWidget {
  XFile? iimageFile;
  List<dynamic> images;
  List<Face>? facess =[];
  ModelScreen({super.key,required this.iimageFile,required this.facess,required this.images});

  @override
  State<ModelScreen> createState() => _ModelScreendState();
}

class _ModelScreendState extends State<ModelScreen> {

  String modelSelected = '';
  List<dynamic> results= [];
  bool isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }



  void OnModelDetect() async{
    if(modelSelected!=''){
      results.clear();
      setState(() {
        isLoading = true;
      });
      for(int a=0;a<widget.images.length;a++){
        await Tflite.loadModel(
          model: 'assets/'+modelSelected+'.tflite', // Replace with the path to your TensorFlow Lite model
          labels: 'assets/labels.txt',  // Replace with the path to your labels file
        );
        final List<dynamic>? recognitions = await Tflite.runModelOnImage(
          path: widget.images[a],
          numResults: 5,
          threshold: 0.5,
          imageMean: 127.5,
          imageStd: 127.5,
        );
        results.add(recognitions);

        Get.snackbar("Results", recognitions.toString());
      }
      setState(() {
        isLoading = false;
      });

    } else{
      ShowToastMobileApp('No Model selected');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: InkWell(
        onTap: (){
          OnModelDetect();
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

              !isLoading ?  Text(
                'Get Results',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ) : Container(
                  height: 40,
                  width: 40,
                  padding: EdgeInsets.all(10),
                  child: CircularProgressIndicator(color: Colors.black,)),



            ],
          ),
        ),
      ).marginOnly(left: 25,right: 25,bottom: 20),      appBar: AppBar(
        title: Text('Choose your model'),
        centerTitle: true,
        elevation: 1,
      ),
      body: Column(
        children: [
          Row(
            children: [
              ChooseModel('FLDDB0'),
              SizedBox(width: 10,),
              ChooseModel('FLDDB1'),
            ],
          ),
          SizedBox(height: 10,),
          Row(
            children: [
              ChooseModel('BaseB0'),
              SizedBox(width: 10,),
              ChooseModel('BaseB1'),
            ],
          ),

          SizedBox(height: 100,),
          results!.length> 0 ? Expanded(
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: GridView.builder(
                padding: EdgeInsets.only(bottom: 100),
                itemCount: results!.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, crossAxisSpacing: 20.0, mainAxisSpacing: 1,
                  childAspectRatio: 0.5
                ),
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    height: 200,
                    width: 200,
                    child: Column(
                      children: [
                        Container(
                            height:100,
                            width: 100,
                            child: Image.file(File(widget.images[index]))),
                        Text(results[index][0]['label'].toString().toUpperCase(),
                        style: GoogleFonts.inter(
                          fontWeight : FontWeight.bold,
                          fontSize : 17
                        ),),
                        Text("Confidence :" + results[index][0]['confidence'].toString().toUpperCase(),
                          style: GoogleFonts.inter(
                              fontWeight : FontWeight.bold,
                              fontSize : 11
                          ),)
                      ],
                    )
                  );
                },
              ),

            ),
          ) : SizedBox()

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
            child: Center(
              child: Text(name,style: GoogleFonts.inter(
                fontWeight : FontWeight.bold,
                fontSize : 20,
                color: modelSelected == name ? Colors.white : Colors.black,
              ),),
            )
          ),
        ),
      ),
    );
  }



}

