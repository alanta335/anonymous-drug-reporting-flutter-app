import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'homescreen.dart';

class listpage extends StatefulWidget {
  const listpage({Key? key}) : super(key: key);

  @override
  State<listpage> createState() => _listpageState();
}

late var id;

class _listpageState extends State<listpage> {
  @override
  Widget build(BuildContext context) {
    Query users = FirebaseFirestore.instance.collection('USERS');

    return StreamBuilder<QuerySnapshot>(
      stream: users.snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: SafeArea(
              child: Center(
                child: Text("loading"),
              ),
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(title: Text("list of users")),
          body: ListView(
            addAutomaticKeepAlives: false,
            cacheExtent: 300,
            reverse: false,
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              return Card(
                child: GestureDetector(
                  onTap: () {
                    id = document.id.toString();
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (ctx) => const Homepage()));
                  },
                  child: ListTile(
                    title: Text('${document.id.toString()}'),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
    // GestureDetector(
    //   onTap: () {
    //     Navigator.pushReplacement(context,
    //         MaterialPageRoute(builder: (ctx) => const Homepage()));
    //   },
    //   child: ListTile(
    //     title: Text("${ids[index]}"),
    //   ),
    // );
  }
}
