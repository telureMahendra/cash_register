import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cash_register/common_utils/common_functions.dart';
import 'package:flutter/material.dart';
import 'package:custom_image_crop/custom_image_crop.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CropImage extends StatefulWidget {
  final File file;
  const CropImage({super.key, required this.file});

  @override
  State<CropImage> createState() => _CropImageState();
}

class _CropImageState extends State<CropImage> {
  late CustomImageCropController controller;
  var image = '';

  @override
  void initState() {
    super.initState();

    loadImage();
    controller = CustomImageCropController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  loadImage() async {
    final prefs = await SharedPreferences.getInstance();
    image = prefs.getString("image").toString();
    setState(() {});
  }

  String convertIntoBase64(File file) {
    List<int> imageBytes = file.readAsBytesSync();
    String base64File = base64Encode(imageBytes);
    return base64File;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Crop Image"),
        actions: [ElevatedButton(onPressed: () {}, child: Text("Save"))],
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: CustomImageCrop(
                cropController: controller,
                forceInsideCropArea: false,
                clipShapeOnCrop: true,
                imageFit: CustomImageFit.fillCropSpace,
                shape: CustomCropShape.Square,
                image: FileImage(widget.file)

                // MemoryImage(Base64Decoder().convert(image)),

                // const AssetImage(
                //     'assets/test.png'),
                //  Image.memory(
                //     Base64Decoder().convert(image),
                //     fit: BoxFit.fitWidth,
                //   ),
                ),
          ),
          Container(
            height: 80,
            color: Colors.blue,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                    color: Colors.white,
                    iconSize: getAdaptiveTextSize(context, 25),
                    icon: const Icon(Icons.refresh),
                    onPressed: controller.reset),
                IconButton(
                    color: Colors.white,
                    iconSize: getAdaptiveTextSize(context, 25),
                    icon: const Icon(Icons.zoom_in),
                    onPressed: () =>
                        controller.addTransition(CropImageData(scale: 1.33))),
                IconButton(
                    color: Colors.white,
                    iconSize: getAdaptiveTextSize(context, 25),
                    icon: const Icon(Icons.zoom_out),
                    onPressed: () =>
                        controller.addTransition(CropImageData(scale: 0.75))),
                IconButton(
                    color: Colors.white,
                    iconSize: getAdaptiveTextSize(context, 25),
                    icon: const Icon(Icons.rotate_left),
                    onPressed: () => controller
                        .addTransition(CropImageData(angle: -pi / 4))),
                IconButton(
                    color: Colors.white,
                    iconSize: getAdaptiveTextSize(context, 25),
                    icon: const Icon(Icons.rotate_right),
                    onPressed: () =>
                        controller.addTransition(CropImageData(angle: pi / 4))),
                IconButton(
                  color: Colors.white,
                  iconSize: getAdaptiveTextSize(context, 25),
                  icon: const Icon(Icons.crop),
                  onPressed: () async {
                    final image = await controller.onCropImage();
                    final prefs = await SharedPreferences.getInstance();
                    // prefs.noSuchMethod("productImage",image);
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}
