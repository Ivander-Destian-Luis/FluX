import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flux/services/authentication_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: ElevatedButton(
              child: Text('Press Me pls'),
              onPressed: () async {
                await AuthenticationService.logout().whenComplete(() {
                  Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => route.isFirst);
                },);
              },
            ),
          ),
        ],
      ),
    );
  }
}
