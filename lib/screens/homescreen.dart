import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  File? image;
  Future getImage() async {
    //for the image picking and uploading it to firebase as string?

    final image = await ImagePicker()
        .pickImage(source: ImageSource.camera, maxHeight: 480, maxWidth: 640);
    if (image == null) return;
    final imageTemp = File(image.path);
    setState(() {
      this.image = imageTemp;
    });
    print(image.path);
    List<int> imageBytes = await image.readAsBytes();
    print(imageBytes);
    String base64Image = base64Encode(imageBytes);
    FirebaseFirestore.instance
        .collection('USERS')
        .doc('${FirebaseAuth.instance.currentUser!.uid}')
        .collection('message')
        .doc()
        .set({
      'text': base64Image,
      'type': "image",
      'time': DateTime.now().toString()
    });
  }

  final ImagePicker _picker = ImagePicker();

  TextEditingController messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Query message = FirebaseFirestore.instance
        .collection('USERS')
        .doc('${FirebaseAuth.instance.currentUser!.uid}')
        .collection('message')
        .orderBy('time', descending: false);

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
            title: Text('Visited Database'),
          ),
          body: SafeArea(
            child: Column(
              children: [
                // ##########FOR PREVIEW OF IMAGE
                // (image != null)
                //     ? Image.file(
                //         image!,
                //         width: 160,
                //         height: 160,
                //         fit: BoxFit.cover,
                //       )
                //     : const SizedBox(),
                Expanded(
                  child: ListView(
                    addAutomaticKeepAlives: false,
                    cacheExtent: 300,
                    reverse: false,
                    children:
                        snapshot.data!.docs.map((DocumentSnapshot document) {
                      return Container(
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
                                ? Image.memory(
                                    Base64Decoder().convert(
                                        document.get('text').toString()),
                                    width: 140,
                                    height: 320,
                                  ) //imgDec(document.get('text').toString())
                                : Text(
                                    document.get('text'),
                                    // ignore: prefer_const_constructors
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
                    ElevatedButton(
                        onPressed: () => getImage(),
                        child: Icon(Icons.camera_alt_rounded)),
                    ElevatedButton(
                        onPressed: () {
                          FirebaseFirestore.instance
                              .collection('USERS')
                              .doc('${FirebaseAuth.instance.currentUser!.uid}')
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
