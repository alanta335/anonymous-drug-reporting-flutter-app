import 'package:flutter/material.dart';
import 'chatMessageModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    Query message = FirebaseFirestore.instance
        .collection('USERS')
        .doc('${FirebaseAuth.instance.currentUser!.uid}')
        .collection('message');

    return StreamBuilder<QuerySnapshot>(
      stream: message.snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          print("error");
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: SafeArea(
              child: Center(child: Text("loading")),
            ),
          );
        }
        print(snapshot.hasData);

        return Scaffold(
          appBar: AppBar(
            title: Text('Visited Database'),
          ),
          body: ListView(
            addAutomaticKeepAlives: false,
            cacheExtent: 300,
            reverse: false,
            //physics: ,
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              return Card(
                child: ListTile(
                  title: Text('${document.get('text')}'),
                ),
              );
            }).toList(),
          ),
        );
        //   if (snapshot.hasError) {
        //     print("error");
        //   }
        //   print(snapshot.data);
        //   if (snapshot.hasData) {
        //     final messages =
        //         snapshot.data!.docs.map((DocumentSnapshot document) {
        //       print(document);
        //       final item = {
        //         "messageText": document.get('text'),
        //         "messageType": document.get('type'),
        //       };
        //       print(item);
        //       return item;
        //     }).toList();
        //     return Scaffold(
        //       body: SafeArea(
        //         child: Padding(
        //           padding: const EdgeInsets.all(8.0),
        //           child: Column(
        //             children: [
        //               Expanded(
        //                 child: ListView.builder(
        //                   itemCount: messages.length,
        //                   padding: EdgeInsets.only(top: 10, bottom: 10),
        //                   itemBuilder: (ctx, index) {
        //                     return Container(
        //                       padding: EdgeInsets.only(
        //                           left: 14, right: 14, top: 10, bottom: 10),
        //                       child: Align(
        //                         alignment: (messages[index]["messageType"] ==
        //                                 "receiver"
        //                             ? Alignment.topLeft
        //                             : Alignment.topRight),
        //                         child: Container(
        //                           decoration: BoxDecoration(
        //                             borderRadius: BorderRadius.circular(20),
        //                             color: (messages[index]["messageType"] ==
        //                                     "receiver"
        //                                 ? Colors.grey.shade200
        //                                 : Colors.blue[200]),
        //                           ),
        //                           padding: EdgeInsets.all(16),
        //                           child: Text(
        //                             messages[index]["messageText"],
        //                             style: TextStyle(fontSize: 15),
        //                           ),
        //                         ),
        //                       ),
        //                     );
        //                   },
        //                 ),
        //               ),
        //               Row(
        //                 children: [
        //                   Expanded(
        //                     child: TextField(
        //                       decoration:
        //                           InputDecoration(hintText: 'Enter message'),
        //                     ),
        //                   ),
        //                   ElevatedButton(onPressed: () {}, child: Text('Send')),
        //                 ],
        //               )
        //             ],
        //           ),
        //         ),
        //       ),
        //     );
        //   }
        //   return Scaffold(
        //     body: SafeArea(
        //       child: Center(
        //         child: CircularProgressIndicator(),
        //       ),
        //     ),
        //   );
      },
    );
  }
}
