import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flux/color_pallete.dart';
import 'package:flux/models/account.dart';
import 'package:flux/models/posting.dart';
import 'package:flux/services/account_service.dart';
import 'package:flux/services/post_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

class PostingScreen extends StatefulWidget {
  const PostingScreen({super.key});

  @override
  State<PostingScreen> createState() => _PostingScreenState();
}

class _PostingScreenState extends State<PostingScreen> {
  TextEditingController _descriptionController = TextEditingController();
  late ColorPallete colorPallete;
  late Account account;
  late SharedPreferences prefs;
  bool _isLoading = true;
  File? _imageFile;
  String assetsImage = 'assets/images/logo-terang.png';
  final picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _imageFile = File(pickedImage.path);
      });
    }
  }

  void initialize() async {
    prefs = await SharedPreferences.getInstance().then((value) async {
      colorPallete = value.getBool('isDarkMode') ?? false
          ? DarkModeColorPallete()
          : LightModeColorPallete();
      account = (await AccountService.getAccountByUid(
          FirebaseAuth.instance.currentUser!.uid))!;
      setState(() {
        _isLoading = false;
      });
      return value;
    });
  }

  void _posting() async {
    String description = _descriptionController.text;
    String? postImageUrl;
    if (_imageFile != null) {
      postImageUrl = await PostService.addPostingImage(_imageFile);
    }
    Posting post = Posting(
        postingDescription: description,
        location: 'Palembang',
        likes: [],
        comments: {},
        postedTime: DateTime.now(),
        postId: null,
        posterUid: FirebaseAuth.instance.currentUser!.uid);

    PostService.post(post, FirebaseAuth.instance.currentUser!.uid);
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    super.initState();
    initialize();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Scaffold(
            backgroundColor: colorPallete.backgroundColor,
            appBar: AppBar(
              backgroundColor: colorPallete.backgroundColor,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: 270),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        'Posting',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: colorPallete.fontColor,
                        ),
                      ),
                    ),
                  ),
                  Align(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Text(
                          'X',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ))
                ],
              ),
            ),
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: Text(
                      'Media',
                      style: TextStyle(
                          fontSize: 20, color: colorPallete.fontColor),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      _pickImage();
                    },
                    child: Container(
                      width: 350,
                      height: 350,
                      margin: EdgeInsets.only(top: 10, left: 22, bottom: 10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.black26),
                      child: _imageFile == null
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate_outlined,
                                    color:
                                        colorPallete.fontColor.withOpacity(0.4),
                                    size: 60),
                                Text('Add media',
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: colorPallete.fontColor
                                            .withOpacity(0.4)))
                              ],
                            )
                          : Image.file(_imageFile!),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 20),
                        child: Text(
                          'Pilih Lokasi',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 215),
                        child: IconButton(
                            onPressed: () {}, icon: Icon(Icons.location_on)),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 20, right: 20),
                    child: Divider(
                      color: colorPallete.borderColor,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 20, top: 10),
                    child: Text(
                      'Details',
                      style: TextStyle(
                          fontSize: 20, color: colorPallete.fontColor),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 20, right: 20, top: 10),
                    child: TextField(
                      controller: _descriptionController,
                      cursorColor: colorPallete.textFieldTextColor,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide:
                                  BorderSide(color: colorPallete.borderColor)),
                          filled: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 50),
                          fillColor: colorPallete.textFieldBackgroundColor),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 30, left: 120),
                    child: ElevatedButton(
                        onPressed: () {
                          _posting();
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: colorPallete.backgroundColor,
                            fixedSize: const Size(150, 50)),
                        child: Text(
                          'Post',
                          style: TextStyle(
                              color: colorPallete.fontColor, fontSize: 20),
                        )),
                  )
                ],
              ),
            ));
  }
}
