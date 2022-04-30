import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
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
                              (document.get('type').toString() == "receiver"
                                  ? Alignment.topLeft
                                  : Alignment.topRight),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color:
                                  (document.get('type').toString() == "receiver"
                                      ? Colors.grey.shade200
                                      : Colors.blue[200]),
                            ),
                            padding: EdgeInsets.all(16),
                            child: Text(
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
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
