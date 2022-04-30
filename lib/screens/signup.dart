import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:report/main.dart';

import 'homescreen.dart';

class Signup extends StatefulWidget {
  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  @override
  final _formkey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Stack(
        children: [
          Center(
              child: GestureDetector(
            onTap: () async {
              await GoogleSignInProvider().googleLogin();
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (ctx) => Homepage()));
            },
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(50),
              ),
              width: width * 0.87,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Row(
                  children: [
                    Text(
                      'Sign up with Google',
                      style: TextStyle(
                          fontFamily: 'Poppins', color: Colors.grey.shade700),
                    )
                  ],
                ),
              ),
            ),
          )),
        ],
      ),
    );
  }
}
