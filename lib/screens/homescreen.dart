import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'map.dart';
import '/models/basicJson.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  File? image;
  Future getImage() async {
    final image = await ImagePicker()
        .pickImage(source: ImageSource.camera, imageQuality: 80);
    if (image == null) return;
    final imageTemp = File(image.path);
    setState(() {
      this.image = imageTemp;
    });
    print(image.path);
    final imageFile = File(image.path);
    final uploadTask = await FirebaseStorage.instance
        .ref()
        .child(
            'user_photo/${FirebaseAuth.instance.currentUser!.uid}_${DateTime.now().toString()}')
        .putFile(imageFile);
    final imageURL = await uploadTask.ref.getDownloadURL();
    FirebaseFirestore.instance
        .collection('USERS')
        .doc('${FirebaseAuth.instance.currentUser!.uid}')
        .collection('message')
        .doc()
        .set({
      'text': imageURL,
      'type': "image",
      'time': DateTime.now().toString()
    });
  }

  final ImagePicker _picker = ImagePicker();
  var dio = Dio();
  TextEditingController messageController = TextEditingController();
  ScrollController _myController = ScrollController();
  @override
  Widget build(BuildContext context) {
    Query message = FirebaseFirestore.instance
        .collection('USERS')
        .doc('${FirebaseAuth.instance.currentUser!.uid}')
        .collection('message')
        .orderBy('time', descending: true);

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
          appBar: AppBar(
            title: Row(
              children: [
                const Text('Reports and Messages'),
                ElevatedButton(
                    onPressed: () {
                      FirebaseFirestore.instance
                          .collection('USERS')
                          .doc('${FirebaseAuth.instance.currentUser!.uid}')
                          .collection('message')
                          .doc()
                          .set({
                        'text': "lat- $lat and long- $long",
                        'type': "sender",
                        'time': DateTime.now().toString()
                      });
                      FirebaseFirestore.instance
                          .collection('R_AREA')
                          .doc()
                          .set({
                        'lat': lat,
                        'long': long,
                        'type': "location",
                        'time': DateTime.now().toString()
                      });
                    },
                    child: Text('report location'))
              ],
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    addAutomaticKeepAlives: true,
                    cacheExtent: 300,
                    reverse: true,
                    children:
                        snapshot.data!.docs.map((DocumentSnapshot document) {
                      return Container(
                        alignment: Alignment.bottomCenter,
                        padding: EdgeInsets.only(
                            left: 14, right: 14, top: 10, bottom: 10),
                        child: Align(
                          alignment:
                              (document.get('type').toString() == "sender" ||
                                      document.get('type').toString() == "image"
                                  ? Alignment.topRight
                                  : Alignment.topLeft),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color:
                                  (document.get('type').toString() == "receiver"
                                      ? Colors.grey.shade200
                                      : Colors.blue[200]),
                            ),
                            padding: EdgeInsets.all(16),
                            child: (document.get('type').toString() == "image")
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
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(9.0),
                        child: TextField(
                          controller: messageController,
                          decoration: const InputDecoration(
                            hintText: 'type here',
                            labelText: 'Message',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.multiline,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (ctx) => const Map()));
                        },
                        child: const Icon(Icons.location_on),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () => getImage(),
                        child: const Icon(Icons.camera_alt_rounded),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                          onPressed: () {
                            FirebaseFirestore.instance
                                .collection('USERS')
                                .doc(
                                    '${FirebaseAuth.instance.currentUser!.uid}')
                                .collection('message')
                                .doc()
                                .set({
                              'text': messageController.text,
                              'type': "sender",
                              'time': DateTime.now().toString()
                            });
                            messageController.text = "";
                          },
                          child: Text('Send')),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                          onPressed: () async {
                            //print("SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS");
                            Response xs = await dio.post(
                                'http://reportapitest34.azurewebsites.net/data',
                                data: {'UID': "STY"});

                            //late basic_data x = basic_data.fromJson())
                            basic_data x = basic_data.fromJson(xs.data);
                            print(x.UID);
                          },
                          child: Text('aPI')),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
