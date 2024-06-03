import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flux/color_pallete.dart';
import 'package:flux/models/account.dart';
import 'package:flux/screen/main_screen.dart';
import 'package:flux/services/account_service.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

class EditDataScreen extends StatefulWidget {
  String usernameProfile = '';
  String phoneNumberProfile = '';
  String bioProfile = '';
  String imageLinkProfile = '';
  EditDataScreen(
      {super.key,
      required this.usernameProfile,
      required this.phoneNumberProfile,
      required this.bioProfile,
      required this.imageLinkProfile});

  @override
  State<EditDataScreen> createState() => _InputDataScreenState();
}

class _InputDataScreenState extends State<EditDataScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  late ColorPallete colorPallete;
  late Account account;
  late SharedPreferences prefs;
  bool _isLoading = true;
  File? _imageFile;
  String? _imageUrl;

  final picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedImage!.path,
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Cropper',
            statusBarColor: colorPallete.fontColor,
            activeControlsWidgetColor: colorPallete.heroColor,
            toolbarColor: colorPallete.postBackgroundColor,
            toolbarWidgetColor: colorPallete.fontColor,
            initAspectRatio: CropAspectRatioPreset.square,
            hideBottomControls: true,
            lockAspectRatio: true),
      ],
    );
    if (croppedFile != null) {
      setState(() {
        _imageFile = File(croppedFile.path);
        _imageUrl = '';
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
    _imageUrl = widget.imageLinkProfile;
    _usernameController.text = widget.usernameProfile;
    _bioController.text = widget.bioProfile;
    _phoneNumberController.text = widget.phoneNumberProfile;
  }

  void _setData() async {
    String username = _usernameController.text.trim();
    String phoneNumber = _phoneNumberController.text.trim();
    String bio = _bioController.text.trim();

    if (_imageFile != null) {
      _imageUrl = await AccountService.addPhotoProfile(_imageFile);
    }

    if (username.isNotEmpty && phoneNumber.isNotEmpty && bio.isNotEmpty) {
      if (_imageUrl != null) {
        await AccountService.edit(
            FirebaseAuth.instance.currentUser!.uid,
            username,
            phoneNumber,
            bio,
            account.followings,
            account.followers,
            _imageUrl,
            account.posts,
            null);
      }
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => const MainScreen(index: 0),
      ));
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
            appBar: AppBar(
                automaticallyImplyLeading: false,
                backgroundColor: colorPallete.backgroundColor,
                title: Align(
                  alignment: Alignment.topRight,
                  child: InkWell(
                    onTap: () => _setData(),
                    child: Text(
                      'Save',
                      style: TextStyle(color: colorPallete.fontColor),
                    ),
                  ),
                )),
            backgroundColor: colorPallete.backgroundColor,
            body: ListView(
              children: [
                Padding(
                    padding: const EdgeInsets.only(top: 70, bottom: 40),
                    child: GestureDetector(
                      onTap: () {
                        _pickImage();
                      },
                      child: _imageFile != null
                          ? CircleAvatar(
                              minRadius: 70,
                              maxRadius: 70,
                              child: ClipOval(
                                child: Image(
                                  image: FileImage(_imageFile!),
                                  fit: BoxFit.fill,
                                ),
                              ))
                          : _imageUrl == ''
                              ? CircleAvatar(
                                  minRadius: 70,
                                  maxRadius: 70,
                                  child: ClipOval(
                                    child: Image(
                                      image: colorPallete.logo,
                                      fit: BoxFit.fill,
                                    ),
                                  ))
                              : CircleAvatar(
                                  minRadius: 70,
                                  maxRadius: 70,
                                  child: ClipOval(
                                    child: Image(
                                      image: NetworkImage(_imageUrl!),
                                      fit: BoxFit.fill,
                                    ),
                                  )),
                    )),
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Text(
                    'Username',
                    style:
                        TextStyle(color: colorPallete.fontColor, fontSize: 20),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 40, right: 40),
                  child: TextFormField(
                    style: TextStyle(color: colorPallete.textFieldTextColor),
                    controller: _usernameController,
                    decoration: InputDecoration(
                        fillColor: colorPallete.textFieldBackgroundColor,
                        border: const UnderlineInputBorder(),
                        hintText: 'Username....',
                        suffixIcon: const Icon(Icons.edit_note_sharp),
                        hintStyle:
                            TextStyle(color: colorPallete.textFieldTextColor)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20, top: 20),
                  child: Text(
                    'Phone Number',
                    style:
                        TextStyle(color: colorPallete.fontColor, fontSize: 20),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 40, right: 40),
                  child: TextFormField(
                    style: TextStyle(color: colorPallete.textFieldTextColor),
                    controller: _phoneNumberController,
                    decoration: InputDecoration(
                        fillColor: colorPallete.textFieldBackgroundColor,
                        border: const UnderlineInputBorder(),
                        hintText: 'Phone Number....',
                        hintStyle:
                            TextStyle(color: colorPallete.textFieldTextColor),
                        suffixIcon: const Icon(Icons.edit_note_sharp)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20, top: 20),
                  child: Text(
                    'Bio',
                    style:
                        TextStyle(color: colorPallete.fontColor, fontSize: 20),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 40, right: 40, bottom: 150),
                  child: TextFormField(
                    controller: _bioController,
                    style: TextStyle(color: colorPallete.textFieldTextColor),
                    decoration: InputDecoration(
                        fillColor: colorPallete.textFieldBackgroundColor,
                        border: const UnderlineInputBorder(),
                        hintText: 'Bio....',
                        suffixIcon: const Icon(Icons.edit_note_sharp),
                        hintStyle:
                            TextStyle(color: colorPallete.textFieldTextColor)),
                  ),
                )
              ],
            ),
          );
  }
}
