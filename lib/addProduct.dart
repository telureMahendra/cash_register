import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cash_register/Widgets/text_field.dart';
import 'package:cash_register/helper/helper.dart';
import 'package:cash_register/homepage.dart';
import 'package:cash_register/imageCrop.dart';
import 'package:cash_register/products.dart';
import 'package:custom_image_crop/custom_image_crop.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Addproduct extends StatefulWidget {
  const Addproduct({super.key});

  @override
  State<Addproduct> createState() => _AddproductState();
}

class _AddproductState extends State<Addproduct> {
  var size, width, height;
  File? galleryFile;
  late File file;
  final picker = ImagePicker();
  var image, imageBase64;

  late CustomImageCropController controller;

  final TextEditingController productNameController = TextEditingController();
  final TextEditingController productPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();

    controller = CustomImageCropController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _showPicker({
    required BuildContext context,
  }) {
    showModalBottomSheet(
      // barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Library'),
                onTap: () {
                  getImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  getImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future getImage(
    ImageSource img,
  ) async {
    final pickedFile = await picker.pickImage(
      source: img,
      imageQuality: 25,
    );
    XFile? xfilePick = pickedFile;
    setState(
      () {
        if (xfilePick != null) {
          galleryFile = File(pickedFile!.path);
          file = galleryFile!;

          cropImageDialog();

          // loadImage();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Nothing is selected')));
        }
      },
    );
  }

  cropImageDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Container(
          width: width * 0.95,
          height: height * 0.50,
          child: Column(
            children: [
              Expanded(
                child: CustomImageCrop(
                    cropController: controller,
                    forceInsideCropArea: false,
                    clipShapeOnCrop: true,
                    imageFit: CustomImageFit.fillCropSpace,
                    shape: CustomCropShape.Square,
                    image: FileImage(file)),
              ),
              Container(
                height: 80,
                color: Colors.blue,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                        color: Colors.white,
                        iconSize: getadaptiveTextSize(context, 25),
                        icon: const Icon(Icons.refresh),
                        onPressed: controller.reset),
                    IconButton(
                        color: Colors.white,
                        iconSize: getadaptiveTextSize(context, 25),
                        icon: const Icon(Icons.zoom_in),
                        onPressed: () => controller
                            .addTransition(CropImageData(scale: 1.33))),
                    IconButton(
                        color: Colors.white,
                        iconSize: getadaptiveTextSize(context, 25),
                        icon: const Icon(Icons.zoom_out),
                        onPressed: () => controller
                            .addTransition(CropImageData(scale: 0.75))),
                    IconButton(
                        color: Colors.white,
                        iconSize: getadaptiveTextSize(context, 25),
                        icon: const Icon(Icons.rotate_left),
                        onPressed: () => controller
                            .addTransition(CropImageData(angle: -pi / 4))),
                    IconButton(
                        color: Colors.white,
                        iconSize: getadaptiveTextSize(context, 25),
                        icon: const Icon(Icons.rotate_right),
                        onPressed: () => controller
                            .addTransition(CropImageData(angle: pi / 4))),
                    IconButton(
                      color: Colors.white,
                      iconSize: getadaptiveTextSize(context, 25),
                      icon: const Icon(Icons.check),
                      onPressed: () async {
                        image = await controller.onCropImage();

                        imageBase64 = convertIntoBase64FromMemoryImage(image);
                        setState(() {});
                        Navigator.pop(context);
                        // prefs.noSuchMethod("productImage",image);
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        ),
      ),
    );
  }

  String convertIntoBase64(File file) {
    List<int> imageBytes = file.readAsBytesSync();
    String base64File = base64Encode(imageBytes);
    return base64File;
  }

  String convertIntoBase64FromMemoryImage(MemoryImage file) {
    // List<int> imageBytes = file.readAsBytesSync();
    List<int> imageBytes = file.bytes;
    String base64File = base64Encode(imageBytes);
    return base64File;
  }

  // storeImage() async {
  // final prefs = await SharedPreferences.getInstance();
  // prefs.setString("productIam", convertIntoBase64(galleryFile!));
  // loadImage();
  // }

  loadImage() async {
    image = convertIntoBase64(galleryFile!);
    setState(() {});
  }

  loadCropedImage() async {
    image = convertIntoBase64(galleryFile!);
    setState(() {});
  }

  getadaptiveTextSize(BuildContext context, dynamic value) {
    return (value / 710) * MediaQuery.of(context).size.height;
  }

  successful() async {
    final prefs = await SharedPreferences.getInstance();

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        insetPadding: EdgeInsets.only(bottom: 20),

        // title: const Center(
        //   child: Text('Payment Successful'),
        // ),
        // content: Text('Faild To store'),
        content: Container(
            padding: EdgeInsets.only(bottom: 0),
            height: height * 0.268,
            width: width * 0.70,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Lottie.asset('assets/animations/check_animation.json',
                    height: height * 0.10,
                    // controller: _controller,
                    repeat: false,
                    animate: true),
                Container(
                  padding: EdgeInsets.only(bottom: 0),
                  child: Text(
                    'Product Added',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: getadaptiveTextSize(context, 20),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top: 5),
                  width: width * 0.49,
                  height: height * 0.05,
                  child: OutlinedButton(
                    style: TextButton.styleFrom(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.home_outlined,
                          size: getadaptiveTextSize(context, 19),
                          color: const Color.fromARGB(255, 58, 104, 125),
                        ),
                        Text(
                          'Back To Home',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: getadaptiveTextSize(context, 15)),
                        ),
                      ],
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();

                      setState(() {});
                    },
                  ),
                ),
              ],
            )),

        actions: [],
      ),
    );
  }

  void saveProduct() async {
    final prefs = await SharedPreferences.getInstance();

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: Lottie.asset('assets/animations/loader.json',
                height: MediaQuery.of(context).size.height * 0.17,
                // controller: _controller,
                repeat: true,
                animate: true),
          );
        },
      );

      print("in try block");

      final response = await http.post(
        Uri.parse(BASE_URL + '/product'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'userId': '${prefs.getInt('userId')}'
        },
        body: jsonEncode(<String, dynamic>{
          'productName': productNameController.text.toString(),
          'price': productPriceController.text.toString(),
          'image': imageBase64,
          'user': {
            'userId': '${prefs.getInt('userId')}',
          }
        }),
      );

      Navigator.pop(context);
      if (response.statusCode == 200 || response.statusCode == 201) {
        // If the server did return a 201 CREATED response,
        // then parse the JSON.
        successful();
      } else {
        // If the server did not return a 201 CREATED response,
        // then throw an exception.
        showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            // title: const Text('Error'),

            insetPadding: EdgeInsets.all(0),
            content: Container(
              height: 220,
              padding: EdgeInsets.all(2),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.asset('assets/animations/warning.json',
                      height: MediaQuery.of(context).size.height * 0.17,
                      // controller: _controller,
                      repeat: true,
                      animate: true),
                  Text(
                    '${response.body.toString()}',
                    style:
                        TextStyle(fontSize: getadaptiveTextSize(context, 15)),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                style: TextButton.styleFrom(),
                child: Text(
                  'Ok',
                  style: TextStyle(fontSize: getadaptiveTextSize(context, 20)),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
        sleep(Duration(seconds: 1));
      }
    } on SocketException catch (e) {
      // Handle network errors
      Navigator.pop(context);
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          // title: const Text('Error'),
          content: Container(
            height: 220,
            padding: EdgeInsets.all(2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset('assets/animations/warning.json',
                    height: MediaQuery.of(context).size.height * 0.17,
                    // controller: _controller,
                    repeat: true,
                    animate: true),
                Text(
                  'Network Error',
                  style: TextStyle(fontSize: getadaptiveTextSize(context, 15)),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Ok',
                  style: TextStyle(fontSize: getadaptiveTextSize(context, 15))),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    } catch (e) {
      print(e);
      Navigator.pop(context);
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          content: Container(
            height: 220,
            padding: EdgeInsets.all(2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.asset('assets/animations/warning.json',
                    height: MediaQuery.of(context).size.height * 0.17,
                    // controller: _controller,
                    repeat: true,
                    animate: true),
                Text(
                  'Server not Responding $e',
                  style: TextStyle(fontSize: getadaptiveTextSize(context, 15)),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text(
                'Ok',
                style: TextStyle(fontSize: getadaptiveTextSize(context, 15)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    width = size.width;
    height = size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Product',
          style: TextStyle(color: Colors.white, fontFamily: 'Becham'),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: SizedBox(
              height: height * 0.150,
              child: image == null
                  ? Image.asset("assets/images/noImage.png")
                  : Image.memory(
                      Base64Decoder().convert(imageBase64),
                      fit: BoxFit.fitWidth,
                    ),

              // : CircleAvatar(
              //     radius: 10, // Image radius
              //     backgroundImage: NetworkImage('imageUrl'),
              //   ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6), // <-- Radius
                ),
              ),
              onPressed: () {
                _showPicker(context: context);
              },
              child: Container(
                width: width,
                padding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                child: Center(
                  child: Text(
                    "Select Product Image",
                    style: TextStyle(
                      fontSize: getadaptiveTextSize(context, 13),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: TextFormField(
              maxLength: 30,
              style: const TextStyle(fontSize: 20),
              controller: productNameController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.shopping_bag, color: Colors.black54),
                hintText: 'Enter Product Name',
                hintStyle: const TextStyle(color: Colors.black45, fontSize: 18),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(10),
                ),
                border: InputBorder.none,
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                  borderRadius: BorderRadius.circular(15),
                ),
                filled: true,
                fillColor: const Color(0xFFedf0f8),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 20,
                ),
              ),
              keyboardType: TextInputType.text,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please Enter Product Name';
                }
                return null;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: TextFormField(
              // maxLength: 30,
              style: const TextStyle(fontSize: 20),
              controller: productPriceController,
              decoration: InputDecoration(
                prefixIcon:
                    Icon(Icons.currency_rupee_sharp, color: Colors.black54),
                hintText: 'Enter Product Price',
                hintStyle: const TextStyle(color: Colors.black45, fontSize: 18),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(10),
                ),
                border: InputBorder.none,
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                  borderRadius: BorderRadius.circular(15),
                ),
                filled: true,
                fillColor: const Color(0xFFedf0f8),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 20,
                ),
              ),
              keyboardType: TextInputType.number,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter Price';
                }
                return null;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6), // <-- Radius
                ),
              ),
              onPressed: () {
                // _showPicker(context: context);
                saveProduct();
              },
              child: Container(
                width: width,
                padding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                child: Center(
                  child: Text(
                    "Add Product",
                    style: TextStyle(
                      fontSize: getadaptiveTextSize(context, 13),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
