import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:report/screens/signup.dart';
import 'map.dart';
import 'package:dio/dio.dart';

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  void initState() {
    super.initState();

    // uidFetch();
  }

  File? image;
  String? imeiNo, platformVersion;

  // ignore: non_constant_identifier_names

  MaterialColor getcolor(int priority) {
    if (priority == 0) {
      return Colors.grey;
    } else if (priority == 1) {
      return Colors.blue;
    } else {
      return Colors.red;
    }
  }

  Future getImage() async {
    final image = await ImagePicker()
        .pickImage(source: ImageSource.camera, imageQuality: 80);
    if (image == null) return;
    final imageTemp = File(image.path);
    setState(() {
      this.image = imageTemp;
    });
    final imageFile = File(image.path);
  }

  final ImagePicker _picker = ImagePicker();
  var dio = Dio();
  TextEditingController messageController = TextEditingController();
  ScrollController _myController = ScrollController();
  @override
  Widget build(BuildContext context) {
    print(uid);
    Query message = FirebaseFirestore.instance
        .collection('USERS')
        .doc('${uid}')
        .collection('message')
        .orderBy('time', descending: true);
    var bs = ElevatedButton.styleFrom(
        padding: EdgeInsets.all(15),
        primary: Colors.white,
        shape: CircleBorder());
    return StreamBuilder<QuerySnapshot>(
      stream: message.snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          print("error");
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: SafeArea(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }
        return Scaffold(
          body: SafeArea(
            child: Stack(children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    image: DecorationImage(
                  image: AssetImage("asset/icon2.png"),
                  fit: BoxFit.cover,
                )),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView(
                          addAutomaticKeepAlives: true,
                          cacheExtent: 300,
                          reverse: true,
                          children: snapshot.data!.docs
                              .map((DocumentSnapshot document) {
                            return Container(
                              alignment: Alignment.bottomCenter,
                              padding: EdgeInsets.only(
                                  left: 14, right: 14, top: 10, bottom: 10),
                              child: Align(
                                alignment: (document.get('type').toString() ==
                                            "sender" ||
                                        document.get('type').toString() ==
                                            "image"
                                    ? Alignment.topRight
                                    : Alignment.topLeft),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: getcolor(document.get('priority')),
                                  ),
                                  padding: EdgeInsets.all(16),
                                  child: (document.get('type').toString() ==
                                          "image")
                                      ? Image.network(
                                          document.get('text').toString(),
                                        )
                                      : Text(
                                          document.get('text'),
                                          style: TextStyle(fontSize: 15),
                                        ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      TextField(
                        controller: messageController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50)),
                          fillColor: Colors.white,
                          filled: true,
                          hintText: 'type here',
                          labelText: 'Message',
                        ),
                        keyboardType: TextInputType.multiline,
                      ),
                      SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Expanded(
                              child: ElevatedButton(
                                style: bs,
                                child: Icon(Icons.report, color: Colors.black),
                                onPressed: () {
                                  FirebaseFirestore.instance
                                      .collection('USERS')
                                      .doc('$uid')
                                      .set({});

                                  FirebaseFirestore.instance
                                      .collection('USERS')
                                      .doc('$uid')
                                      .collection('message')
                                      .doc()
                                      .set({
                                    'text': "lat- $lat and long- $long",
                                    'priority': 0,
                                    'type': "sender",
                                    'time': DateTime.now().toString()
                                  });
                                  FirebaseFirestore.instance
                                      .collection('R_AREA')
                                      .doc()
                                      .set(
                                    {
                                      'priority': 0,
                                      'lat': lat,
                                      'long': long,
                                      'type': "location",
                                      'time': DateTime.now().toString()
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                              style: bs,
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (ctx) => const Map()));
                              },
                              child: const Icon(Icons.location_on,
                                  color: Colors.black),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                              style: bs,
                              onPressed: () async {
                                await getImage();
                                if (image != null) {
                                  final uploadTask = await FirebaseStorage
                                      .instance
                                      .ref()
                                      .child(
                                          'user_photo/${uid}_${DateTime.now().toString()}')
                                      .putFile(image!);
                                  final imageURL =
                                      await uploadTask.ref.getDownloadURL();
                                  print(uid);
                                  var jsn = jsonEncode({"st": imageURL});
                                  Response fd = await dio.post(
                                      "https://reportapitest34.azurewebsites.net/face",
                                      data: jsn);
                                  var pri;
                                  (fd.data > 0) ? pri = 2 : pri = 1;
                                  FirebaseFirestore.instance
                                      .collection('USERS')
                                      .doc('$uid')
                                      .set({});
                                  FirebaseFirestore.instance
                                      .collection('USERS')
                                      .doc('$uid')
                                      .collection('message')
                                      .doc()
                                      .set({
                                    'text': imageURL,
                                    'priority': pri,
                                    'type': "image",
                                    'time': DateTime.now().toString()
                                  });
                                } else {
                                  print("image error!");
                                }
                              },
                              child: const Icon(Icons.camera_alt_rounded,
                                  color: Colors.black),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                              style: bs,
                              onPressed: () async {
                                var sx =
                                    jsonEncode({"st": messageController.text});
                                Response x = await dio.post(
                                    "https://reportapitest34.azurewebsites.net/spam",
                                    data: sx);
                                print(x.data);
                                if (x.data == false) {
                                  FirebaseFirestore.instance
                                      .collection('USERS')
                                      .doc('$uid')
                                      .set({});

                                  FirebaseFirestore.instance
                                      .collection('USERS')
                                      .doc('$uid')
                                      .collection('message')
                                      .doc()
                                      .set({
                                    'text': messageController.text,
                                    'type': "sender",
                                    'priority': 0,
                                    'time': DateTime.now().toString()
                                  });
                                  messageController.text = "";
                                }
                              },
                              child: Icon(Icons.send, color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ]),
          ),
        );
      },
    );
  }
}
