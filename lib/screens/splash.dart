import 'package:easy_splash_screen/easy_splash_screen.dart';
import 'package:flutter/material.dart';

import '../main.dart';

class splash extends StatefulWidget {
  const splash({Key? key}) : super(key: key);

  @override
  State<splash> createState() => _splashState();
}

class _splashState extends State<splash> {
  @override
  Widget build(BuildContext context) {
    return EasySplashScreen(
      logo: Image.asset("icon/icon.png"),
      title: Text(
        "DRUID",
        style: TextStyle(
          color: Colors.yellow,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Colors.black,
      showLoader: true,
      loadingText:
          Text("Loading...", style: TextStyle(color: Colors.yellowAccent)),
      navigator: MyHomePage(title: 'Report Home Page'),
      durationInSeconds: 5,
    );
  }
}
