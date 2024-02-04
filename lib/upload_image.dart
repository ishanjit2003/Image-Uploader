import 'dart:io';
import 'package:http/http.dart' as http0;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class UploadImage extends StatefulWidget {
  const UploadImage({Key? key}) : super(key: key);

  @override
  State<UploadImage> createState() => _UploadImageState();
}

class _UploadImageState extends State<UploadImage> {
  File? image;
  final picker = ImagePicker();
  bool showSpinner = false;

  Future<void> _pickImage() async {
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery,imageQuality: 80);

    if (pickedFile != null) {
      setState(() {
        image = File(pickedFile.path);
      });
    }
    else{
      Text('No image selected');
    }
  }

  Future<void> upload()async{
    setState(() {
      showSpinner=true;
    });

    var stream=new http0.ByteStream(image!.openRead());

    stream.cast();

    var length=await image!.length();
    var uri=Uri.parse('https://fakestoreapi.com/products');
    var request=http0.MultipartRequest('POST',uri);
    request.fields['title']="static title";
    var multipart=new http0.MultipartFile('image', stream, length);
    request.files.add(multipart);

    var response= await request.send();

    if(response.statusCode==200) {
      setState(() {
        showSpinner = false;
      });
      print('image uploaded');
    }

    else {
      setState(() {
        showSpinner = false;
      });
      print('failed');
    }

  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: showSpinner,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Uploader'),
          backgroundColor: Colors.cyanAccent,
        ),
        body: Column(
          children: [
            Container(
              child: image == null
                  ? Text('Pick an image')
                  : Container(
                child: Center(
                  child: Image.file(image!),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Pick Image'),
            ),
            ElevatedButton(
              onPressed: upload,
              child: Text('Upload'),
            ),
          ],
        ),
      ),
    );
  }
}
