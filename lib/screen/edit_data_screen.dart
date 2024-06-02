import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flux/color_pallete.dart';
import 'package:flux/models/account.dart';
import 'package:flux/screen/main_screen.dart';
import 'package:flux/services/account_service.dart';
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
  TextEditingController _usernameController = TextEditingController();
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
    if (pickedImage != null) {
      setState(() {
        _imageFile = File(pickedImage.path);
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
            account.posts);
      }
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => const MainScreen(),
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
                backgroundColor: colorPallete.backgroundColor,
                title: Align(
                  alignment: Alignment.topRight,
                  child: InkWell(
                    child: Text('Save'),
                    onTap: () => _setData(),
                  ),
                )),
            backgroundColor: colorPallete.backgroundColor,
            body: ListView(
              children: [
                Padding(
                    padding: EdgeInsets.only(top: 70, bottom: 40),
                    child: GestureDetector(
                        onTap: () {
                          _pickImage();
                        },
                        child: _imageFile != null
                            ? CircleAvatar(
                                minRadius: 70,
                                maxRadius: 70,
                                backgroundImage: FileImage(_imageFile!),
                              )
                            : _imageFile != null
                                ? CircleAvatar(
                                    minRadius: 70,
                                    maxRadius: 70,
                                    backgroundImage:
                                        AssetImage('${colorPallete.logo}'),
                                  )
                                : CircleAvatar(
                                    minRadius: 70,
                                    maxRadius: 70,
                                    backgroundImage: NetworkImage(_imageUrl!),
                                  ))),
                Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: Text(
                    'Username',
                    style:
                        TextStyle(color: colorPallete.fontColor, fontSize: 20),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 40, right: 40),
                  child: TextFormField(
                    style: TextStyle(color: colorPallete.textFieldTextColor),
                    controller: _usernameController,
                    decoration: InputDecoration(
                        fillColor: colorPallete.textFieldBackgroundColor,
                        border: UnderlineInputBorder(),
                        hintText: 'Username....',
                        suffixIcon: Icon(Icons.edit_note_sharp),
                        hintStyle:
                            TextStyle(color: colorPallete.textFieldTextColor)),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 20, top: 20),
                  child: Text(
                    'Phone Number',
                    style:
                        TextStyle(color: colorPallete.fontColor, fontSize: 20),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 40, right: 40),
                  child: TextFormField(
                    style: TextStyle(color: colorPallete.textFieldTextColor),
                    controller: _phoneNumberController,
                    decoration: InputDecoration(
                        fillColor: colorPallete.textFieldBackgroundColor,
                        border: UnderlineInputBorder(),
                        hintText: 'Phone Number....',
                        hintStyle:
                            TextStyle(color: colorPallete.textFieldTextColor),
                        suffixIcon: Icon(Icons.edit_note_sharp)),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 20, top: 20),
                  child: Text(
                    'Bio',
                    style:
                        TextStyle(color: colorPallete.fontColor, fontSize: 20),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 40, right: 40, bottom: 150),
                  child: TextFormField(
                    controller: _bioController,
                    style: TextStyle(color: colorPallete.textFieldTextColor),
                    decoration: InputDecoration(
                        fillColor: colorPallete.textFieldBackgroundColor,
                        border: UnderlineInputBorder(),
                        hintText: 'Bio....',
                        suffixIcon: Icon(Icons.edit_note_sharp),
                        hintStyle:
                            TextStyle(color: colorPallete.textFieldTextColor)),
                  ),
                )
              ],
            ),
          );
  }
}
