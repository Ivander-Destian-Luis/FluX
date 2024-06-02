import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flux/color_pallete.dart';
import 'package:flux/models/account.dart';
import 'package:flux/models/alert.dart';
import 'package:flux/models/posting.dart';
import 'package:flux/services/location_service.dart';
import 'package:flux/services/notification_service.dart';
import 'package:flux/services/post_service.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

class PostingScreen extends StatefulWidget {
  const PostingScreen({super.key});

  @override
  State<PostingScreen> createState() => _PostingScreenState();
}

class _PostingScreenState extends State<PostingScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  final picker = ImagePicker();

  late ColorPallete colorPallete;
  late Account account;
  late SharedPreferences prefs;
  File? _imageFile;
  Position? position;

  bool _isLoading = true;
  String? _location;

  Future<void> _pickImage() async {
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _imageFile = File(pickedImage.path);
      });
    }
  }

  void _pickLocation() async {
    position = await LocationService.getCurrentPosition();
    List<Placemark> placemarks = await GeocodingPlatform.instance!
        .placemarkFromCoordinates(position!.latitude, position!.longitude);
    setState(() {
      _location = "${placemarks[0].subAdministrativeArea}";
    });
  }

  void initialize() async {
    prefs = await SharedPreferences.getInstance().then((value) async {
      colorPallete = value.getBool('isDarkMode') ?? false
          ? DarkModeColorPallete()
          : LightModeColorPallete();

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
      location: _location,
      likes: [],
      latitude: position?.latitude,
      longitude: position?.longitude,
      comments: {},
      postedTime: DateTime.now(),
      postId: null,
      posterUid: FirebaseAuth.instance.currentUser!.uid,
      postingImageUrl: postImageUrl,
    );

    int statusCode =
        await PostService.post(post, FirebaseAuth.instance.currentUser!.uid);

    if (statusCode == 200) {
      Navigator.pushReplacementNamed(context, '/main');
    } else {
      print("LOL");
    }
  }

  void _notify() async {
    Alert notif = Alert(
      uid: FirebaseAuth.instance.currentUser!.uid,
      notificationId: null,
      notificationContext: 'has posted a new Flux',
      notifiedTime: DateTime.now(),
      readBy: [],
    );

    int statusCode = await NotificationService.notify(
        notif, FirebaseAuth.instance.currentUser!.uid);

    if (statusCode == 200) {
      Navigator.pushReplacementNamed(context, '/main');
    } else {
      print("LOL");
    }
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Posting',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: colorPallete.fontColor,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _posting();
                      _notify();
                    },
                    child: Text(
                      'Post',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colorPallete.textLinkColor),
                    ),
                  )
                ],
              ),
            ),
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Media',
                        style: TextStyle(
                            fontSize: 20, color: colorPallete.fontColor),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      _pickImage();
                    },
                    child: Container(
                      width: 350,
                      height: 350,
                      margin: const EdgeInsets.only(top: 10, bottom: 10),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Text(
                          _location == null ? "Pilih Lokasi" : _location!,
                          style: TextStyle(
                              fontSize: 16, color: colorPallete.fontColor),
                        ),
                      ),
                      IconButton(
                          onPressed: () async {
                            _pickLocation();
                          },
                          icon: Icon(
                            Icons.location_on,
                            color: colorPallete.fontColor,
                          )),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: Divider(
                      color: colorPallete.borderColor,
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 20, top: 10, bottom: 10),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Details',
                        style: TextStyle(
                            fontSize: 20, color: colorPallete.fontColor),
                      ),
                    ),
                  ),
                  Container(
                    constraints: const BoxConstraints(
                      minHeight: 150,
                    ),
                    decoration: BoxDecoration(
                      color: colorPallete.textFieldBackgroundColor,
                      border: Border.all(color: colorPallete.borderColor),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      maxLines: null,
                      controller: _descriptionController,
                      cursorColor: colorPallete.textFieldTextColor,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ));
  }
}
