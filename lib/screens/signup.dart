import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:report/main.dart';

import 'homescreen.dart';

class Signup extends StatefulWidget {
  @override
  _SignupState createState() => _SignupState();
}

var userType = "";

class _SignupState extends State<Signup> {
  @override
  final _formkey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(13.0),
            child: GestureDetector(
              onTap: () async {
                setState(() {
                  userType = "user";
                });
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (ctx) => const Homepage()));
              },
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(50),
                ),
                width: width * 0.87,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: [
                      Text(
                        'send message anonymous',
                        style: TextStyle(
                            fontFamily: 'Poppins', color: Colors.grey.shade700),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () async {
              await GoogleSignInProvider().googleLogin();
              FirebaseFirestore.instance
                  .collection('USERS')
                  .doc('${FirebaseAuth.instance.currentUser!.uid}')
                  .collection('message')
                  .doc()
                  .set({
                'text': "welcome",
                'type': "receiver",
                'time': DateTime.now().toString()
              });

              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (ctx) => const Homepage()));
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
                      'Sign up with Google if admin',
                      style: TextStyle(
                          fontFamily: 'Poppins', color: Colors.grey.shade700),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
