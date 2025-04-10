import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../supabase/storage_upload_fetch.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  File? _imageFile;
  String? _imageUrl;

  final ImagePicker _picker = ImagePicker();


  final ImageUpload _imageUpload = ImageUpload();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });

      await _imageUpload.uploadImage(_imageFile);


      final url = await _imageUpload.getImageUrl();
      setState(() {
        _imageUrl = url;
      });

      if (kDebugMode) {
        print("Image uploaded successfully!");
      }
    } else {
      if (kDebugMode) {
        print("Error picking image");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 200,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      _imageUrl != null
                          ? CircleAvatar(
                        radius: 70,
                        backgroundImage: NetworkImage(_imageUrl!),
                      )
                          : CircleAvatar(
                        radius: 70,
                        backgroundImage:AssetImage("assets/images/avatar.png") as ImageProvider,
                      ),
                      Positioned(
                        bottom: 25,
                        right: 12,
                        child: InkWell(
                          onTap: _pickImage,
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.grey[200],
                            child: Icon(
                              Icons.camera_alt,
                              size: 20,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
